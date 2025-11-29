import os, re, json, argparse, numpy as np, pandas as pd, joblib
from typing import List, Tuple
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
import torch, torch.nn as nn, torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader

# -------------------------
# Parsing sets/reps/load
# -------------------------
def parse_srw(cell) -> Tuple[float,float,float]:
    if pd.isna(cell): 
        return (np.nan, np.nan, np.nan)
    try:
        parts = [p.strip() for p in str(cell).split("|")]
        reps, weights = [], []
        for p in parts:
            nums = re.findall(r"(-?\d+\.?\d*)", p)
            if len(nums) >= 2:
                r = float(nums[0])
                w = abs(float(nums[1]))  # assisted machines -> abs
                reps.append(r); weights.append(w)
        if len(reps) == 0:
            return (np.nan, np.nan, np.nan)
        return (len(reps), float(np.median(reps)), float(np.median(weights)) if len(weights)>0 else np.nan)
    except Exception:
        return (np.nan, np.nan, np.nan)

# -------------------------
# Multi-label from name
# -------------------------
def build_labels(df, max_labels=200):
    ex_series = df["exercise_name"].astype(str).str.strip().str.lower().str.replace(r"[^a-z0-9]+","_", regex=True)
    unique_ex = sorted(ex_series.unique().tolist())
    if len(unique_ex) > max_labels:
        unique_ex = unique_ex[:max_labels]
    label_cols = [f"exercise_{ex}" for ex in unique_ex]
    for ex in unique_ex:
        df[f"exercise_{ex}"] = 0
    for i in df.index:
        ex = ex_series.iloc[i]
        if ex in unique_ex:
            df.at[i, f"exercise_{ex}"] = 1
    return df, label_cols

# -------------------------
# Feature list
# -------------------------
def build_features(df):
    feature_candidates = [
        "age","height_cm","weight_kg","bmi","bmr","bodyFatPct","resting_hr",
        "bp_systolic","bp_diastolic","cholesterol","blood_sugar_fasting",
        "max_pushups","max_weight_lifted_kg","workout_frequency_per_week",
        "avg_hr","max_hr","calories","duration_min",
        "gender","experience_level","activity_level",
        "equipment","target_muscle","secondary_muscles",
    ]
    return [c for c in feature_candidates if c in df.columns]

# -------------------------
# Dataset
# -------------------------
class RecDataset(Dataset):
    def __init__(self, X, y_cls, y_reg):
        self.X = X.astype("float32")
        self.yc = y_cls.astype("float32")
        self.yr = y_reg.astype("float32")
    def __len__(self): return self.X.shape[0]
    def __getitem__(self, i):
        return (torch.from_numpy(self.X[i]),
                torch.from_numpy(self.yc[i]),
                torch.from_numpy(self.yr[i]))

# -------------------------
# Model
# -------------------------
class MTLNet(nn.Module):
    def __init__(self, in_dim, num_exercises, hidden=256):
        super().__init__()
        self.trunk = nn.Sequential(
            nn.Linear(in_dim, hidden), nn.ReLU(), nn.Dropout(0.15),
            nn.Linear(hidden, hidden), nn.ReLU(), nn.Dropout(0.15),
        )
        self.head_cls = nn.Linear(hidden, num_exercises)
        # Regression head -> we will apply sigmoid for scaled targets [0,1]
        self.head_reg = nn.Sequential(nn.Linear(hidden,128), nn.ReLU(), nn.Linear(128,3))
    def forward(self, x):
        h = self.trunk(x)
        logits = self.head_cls(h)
        reg_raw = self.head_reg(h)
        reg_scaled = torch.sigmoid(reg_raw)  # in [0,1]
        return logits, reg_scaled

# -------------------------
# Metrics
# -------------------------
def precision_recall_at_k(logits, y_true, K=5):
    p = torch.sigmoid(logits)
    K = min(K, p.shape[1])
    topk = torch.topk(p, k=K, dim=1).indices
    pr, rc = [], []
    for i in range(p.shape[0]):
        pred = set(topk[i].tolist())
        true = set(torch.nonzero(y_true[i]).squeeze(1).tolist())
        pr.append(0.0 if len(pred)==0 else len(pred & true)/len(pred))
        rc.append(0.0 if len(true)==0 else len(pred & true)/len(true))
    return float(np.mean(pr)), float(np.mean(rc))

# -------------------------
# Train
# -------------------------
def main(excel_path, artifacts, epochs=80, batch_size=128, lr=1e-3,
         max_labels=200, use_focal=False, focal_alpha=0.25, focal_gamma=2.0,
         load_cap_kg=200.0):

    os.makedirs(artifacts, exist_ok=True)
    df = pd.read_excel(excel_path)

    # Parse regression targets in-memory
    if "sets/reps/weight/timeresteachset" in df.columns:
        parsed = df["sets/reps/weight/timeresteachset"].apply(parse_srw)
        df["_sets"] = [t[0] for t in parsed]
        df["_reps"] = [t[1] for t in parsed]
        df["_load_kg"] = [t[2] for t in parsed]
    else:
        df["_sets"], df["_reps"], df["_load_kg"] = np.nan, np.nan, np.nan

    # Fill defaults then clip to ranges
    sets_min, sets_max = 1.0, 5.0
    reps_min, reps_max = 5.0, 20.0
    load_min, load_max = 0.0, float(load_cap_kg)

    df["sets"] = pd.to_numeric(df["_sets"], errors="coerce").fillna(3).clip(sets_min, sets_max)
    df["reps"] = pd.to_numeric(df["_reps"], errors="coerce").fillna(10).clip(reps_min, reps_max)
    df["load_kg"] = pd.to_numeric(df["_load_kg"], errors="coerce").fillna(10.0).clip(load_min, load_max)

    # Multi-label targets from exercise_name
    df, ex_cols = build_labels(df, max_labels=max_labels)
    df = df[df[ex_cols].sum(axis=1) > 0].reset_index(drop=True)

    # Features & preprocessor
    features = build_features(df)
    Xdf = df[features].copy()
    num_cols = [c for c in Xdf.columns if pd.api.types.is_numeric_dtype(Xdf[c])]
    cat_cols = [c for c in Xdf.columns if pd.api.types.is_object_dtype(Xdf[c])]
    pre = ColumnTransformer([
        ("num", Pipeline([("imp", SimpleImputer(strategy="median")),
                          ("sc", StandardScaler())]), num_cols),
        ("cat", Pipeline([("imp", SimpleImputer(strategy="most_frequent")),
                          ("oh", OneHotEncoder(handle_unknown="ignore"))]), cat_cols),
    ], remainder="drop")
    X_all_sp = pre.fit_transform(Xdf)
    X_all = X_all_sp.toarray() if hasattr(X_all_sp, "toarray") else np.asarray(X_all_sp)

    # Targets
    y_cls = df[ex_cols].values.astype("float32")

    # Scale regression to [0,1]
    y_reg_scaled = np.column_stack([
        (df["sets"].values - sets_min) / (sets_max - sets_min),
        (df["reps"].values - reps_min) / (reps_max - reps_min),
        (df["load_kg"].values - load_min) / max(1e-6, (load_max - load_min)),
    ]).astype("float32")

    # Split
    X_tr, X_va, yc_tr, yc_va, yr_tr, yr_va = train_test_split(
        X_all, y_cls, y_reg_scaled, test_size=0.2, random_state=42
    )

    tr_dl = DataLoader(RecDataset(X_tr, yc_tr, yr_tr), batch_size=batch_size, shuffle=True)
    va_dl = DataLoader(RecDataset(X_va, yc_va, yr_va), batch_size=batch_size, shuffle=False)

    # Model & optimizer
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = MTLNet(in_dim=X_all.shape[1], num_exercises=len(ex_cols)).to(device)
    opt = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=1e-4)

    # Class weights (pos_weight) to reduce imbalance
    pos = yc_tr.sum(axis=0) + 1e-6
    neg = (yc_tr.shape[0] - yc_tr.sum(axis=0)) + 1e-6
    pos_weight = torch.tensor(neg / pos, dtype=torch.float32, device=device)

    bce = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
    huber = nn.SmoothL1Loss()

    # Optional focal (wrapped over logits)
    def focal_bce_with_logits(logits, targets, alpha=0.25, gamma=2.0):
        bce_raw = F.binary_cross_entropy_with_logits(logits, targets, reduction="none")
        p = torch.sigmoid(logits)
        pt = p*targets + (1-p)*(1-targets)
        loss = alpha * (1-pt).pow(gamma) * bce_raw
        return loss.mean()

    best_p5, best_path = -1.0, os.path.join(artifacts, "best.pt")
    for epoch in range(1, epochs+1):
        model.train(); tr_loss = 0.0
        for xb, ycb, yrb in tr_dl:
            xb, ycb, yrb = xb.to(device), ycb.to(device), yrb.to(device)
            opt.zero_grad()
            logits, reg_scaled = model(xb)
            cls_loss = focal_bce_with_logits(logits, ycb, alpha=0.25, gamma=2.0) if use_focal else bce(logits, ycb)
            reg_loss = huber(reg_scaled, yrb)
            loss = 1.0*cls_loss + 0.25*reg_loss
            loss.backward(); opt.step()
            tr_loss += loss.item()
        tr_loss /= max(1, len(tr_dl))

        model.eval()
        with torch.no_grad():
            v_loss = 0.0; p5s = []; r5s = []; cos_all = []
            for xb, ycb, yrb in va_dl:
                xb, ycb, yrb = xb.to(device), ycb.to(device), yrb.to(device)
                logits, reg_scaled = model(xb)
                cls_loss = focal_bce_with_logits(logits, ycb, alpha=0.25, gamma=2.0) if use_focal else bce(logits, ycb)
                reg_loss = huber(reg_scaled, yrb)
                loss = 1.0*cls_loss + 0.25*reg_loss
                v_loss += loss.item()
                p5, r5 = precision_recall_at_k(logits, ycb, K=5)
                p = torch.sigmoid(logits)
                cos = ( (p/(p.norm(dim=1,keepdim=True)+1e-8)) * (ycb/(ycb.norm(dim=1,keepdim=True)+1e-8)) ).sum(dim=1).mean().item()
                p5s.append(p5); r5s.append(r5); cos_all.append(cos)
            v_loss /= max(1, len(va_dl))
            p5_mean = float(np.mean(p5s)); r5_mean = float(np.mean(r5s)); cos_mean = float(np.mean(cos_all))

        print(f"Epoch {epoch:02d} | train_loss {tr_loss:.4f} | val_loss {v_loss:.4f} | p@5 {p5_mean:.3f} | r@5 {r5_mean:.3f} | cosine {cos_mean:.3f}")

        if p5_mean > best_p5:
            best_p5 = p5_mean
            torch.save({"state_dict": model.state_dict(),
                        "in_dim": X_all.shape[1],
                        "num_ex": len(ex_cols),
                        "ex_cols": ex_cols}, best_path)
            with open(os.path.join(artifacts, "BEST.txt"), "w") as f:
                f.write(f"best_p@5={best_p5:.6f}\npath={best_path}\n")

    # Save artifacts
    joblib.dump(pre, os.path.join(artifacts, "preprocessor.joblib"))
    meta = {
        "exercise_columns": ex_cols,
        "regression_columns": ["sets","reps","load_kg"],
        "classification_mode": "multilabel_bce",
        "num_features_after_preprocessor": int(X_all.shape[1]),
        "features_used": features,
        "reg_scale": {
            "sets":  [float(sets_min), float(sets_max)],
            "reps":  [float(reps_min), float(reps_max)],
            "load":  [float(load_min), float(load_max)]
        },
        "best_checkpoint": best_path,
        "note": "BCE with pos_weight; regression scaled with sigmoid."
    }
    with open(os.path.join(artifacts, "meta.json"), "w", encoding="utf-8") as fp:
        json.dump(meta, fp, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--excel_path", default="data/merged_omni_health_dataset.xlsx")
    ap.add_argument("--artifacts", default="artifacts_omni_mlbce")
    ap.add_argument("--epochs", type=int, default=80)
    ap.add_argument("--batch_size", type=int, default=128)
    ap.add_argument("--lr", type=float, default=1e-3)
    ap.add_argument("--max_labels", type=int, default=200)
    ap.add_argument("--use_focal", action="store_true", help="Dùng focal BCE thay vì BCE thường")
    ap.add_argument("--focal_alpha", type=float, default=0.25)
    ap.add_argument("--focal_gamma", type=float, default=2.0)
    ap.add_argument("--load_cap_kg", type=float, default=200.0)
    args = ap.parse_args()
    main(args.excel_path, args.artifacts, args.epochs, args.batch_size, args.lr,
         args.max_labels, args.use_focal, args.focal_alpha, args.focal_gamma,
         args.load_cap_kg)
