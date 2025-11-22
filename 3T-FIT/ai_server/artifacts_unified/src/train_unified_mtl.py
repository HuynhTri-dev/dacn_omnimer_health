"""
train_unified_mtl.py
One unified model for:
 - Multi-label exercise scoring (classification)
 - Per-exercise intensity (8-dim regression, scaled [0,1])

Fixes:
 - Rare classes (count==1) -> move to TRAIN only.
 - Dynamic stratified split: ensure test_size >= #classes and train_size >= #classes,
   otherwise fallback to non-stratified split.

Artifacts:
  artifacts_unified/
    - best.pt
    - preprocessor.joblib
    - meta.json
"""

import os, re, json, argparse, numpy as np, pandas as pd, joblib
import torch, torch.nn as nn, torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline

# ------------------ utils ------------------
def norm_ex_name(s: str):
    return str(s).strip().lower().replace(" ", "_").replace("-", "_")

def parse_srw(cell):
    if pd.isna(cell): return (np.nan, np.nan, np.nan, np.nan)
    try:
        parts = [p.strip() for p in str(cell).split("|")]
        reps, weights, rests = [], [], []
        for p in parts:
            nums = re.findall(r"(-?\d+\.?\d*)", p)
            if len(nums) >= 2:
                reps.append(float(nums[0]))
                weights.append(abs(float(nums[1])))
            m = re.search(r"rest\s*[:=]\s*(\d+\.?\d*)", p, flags=re.I)
            if m: rests.append(float(m.group(1)))
        sets_cnt = len(reps) if reps else np.nan
        med_reps = float(np.median(reps)) if reps else np.nan
        med_kg   = float(np.median(weights)) if weights else np.nan
        med_rest = float(np.median(rests)) if rests else np.nan
        return (sets_cnt, med_reps, med_kg, med_rest)
    except Exception:
        return (np.nan, np.nan, np.nan, np.nan)

# ------------------ dataset ------------------
class UniDataset(Dataset):
    def __init__(self, X, y_cls, y_reg8, reg_mask8, gt_idx):
        self.X = X.astype("float32")
        self.yc = y_cls.astype("float32")          # [N, C]
        self.y8 = y_reg8.astype("float32")         # [N, 8] scaled [0,1]
        self.m8 = reg_mask8.astype("float32")      # [N, 8] 1 if label present
        self.gi = gt_idx.astype("int64")           # [N] index of GT exercise
    def __len__(self): return self.X.shape[0]
    def __getitem__(self, i):
        return (torch.from_numpy(self.X[i]),
                torch.from_numpy(self.yc[i]),
                torch.from_numpy(self.y8[i]),
                torch.from_numpy(self.m8[i]),
                torch.tensor(self.gi[i]))

# ------------------ model ------------------
class UnifiedMTL(nn.Module):
    def __init__(self, in_dim, num_ex, d=256, joint_d=256, drop=0.15):
        super().__init__()
        self.encoder = nn.Sequential(
            nn.Linear(in_dim, d), nn.ReLU(), nn.Dropout(drop),
            nn.Linear(d, d),     nn.ReLU(), nn.Dropout(drop)
        )
        self.ex_embed = nn.Parameter(torch.randn(num_ex, d) * 0.02)  # learnable embeddings

        # heads on joint = [h, e, h*e]
        self.head_cls = nn.Sequential(
            nn.Linear(d*3, joint_d), nn.ReLU(), nn.Linear(joint_d, 1)
        )
        self.head_reg = nn.Sequential(
            nn.Linear(d*3, joint_d), nn.ReLU(),
            nn.Linear(joint_d, 128), nn.ReLU(),
            nn.Linear(128, 8)  # sigmoid later
        )

    def forward(self, x):
        B = x.size(0)
        h = self.encoder(x)                 # [B, d]
        E = self.ex_embed                   # [C, d]
        C = E.size(0)

        h_exp = h.unsqueeze(1).expand(B, C, h.size(1))      # [B, C, d]
        E_exp = E.unsqueeze(0).expand(B, C, E.size(1))      # [B, C, d]
        joint = torch.cat([h_exp, E_exp, h_exp * E_exp], dim=2)  # [B, C, 3d]

        logits = self.head_cls(joint).squeeze(-1)           # [B, C]
        reg = torch.sigmoid(self.head_reg(joint))           # [B, C, 8]
        return logits, reg

# ------------------ metrics ------------------
def precision_recall_at_k(logits, y_true, K=5):
    p = torch.sigmoid(logits)
    K = min(K, p.shape[1])
    topk = torch.topk(p, k=K, dim=1).indices
    pr, rc = [], []
    for i in range(p.shape[0]):
        pred = set(topk[i].tolist())
        true = set(torch.nonzero(y_true[i]).squeeze(1).tolist())
        inter = len(pred & true)
        pr.append(inter / max(1, len(pred)))
        rc.append(inter / max(1, len(true)))
    return float(np.mean(pr)), float(np.mean(rc))

# ------------------ main ------------------
def main(excel_path, artifacts, epochs=80, batch_size=128, lr=1e-3, load_cap_kg=200.0):
    os.makedirs(artifacts, exist_ok=True)
    df = pd.read_excel(excel_path)

    # 1) Build labels
    ex_series = df["exercise_name"].astype(str).map(norm_ex_name)
    unique_ex = sorted(ex_series.unique().tolist())
    ex_cols = [f"exercise_{s}" for s in unique_ex]
    for s in unique_ex:
        df[f"exercise_{s}"] = (ex_series == s).astype(int)

    name2idx = {s: i for i, s in enumerate(unique_ex)}
    gt_idx = ex_series.map(name2idx).astype(int).values   # [N]

    # 2) Parse regression columns (8 targets)
    sets_cnt, med_reps, med_kg, med_rest = [], [], [], []
    if "sets/reps/weight/timeresteachset" in df.columns:
        parsed = df["sets/reps/weight/timeresteachset"].apply(parse_srw)
        for s,r,w,t in parsed:
            sets_cnt.append(s); med_reps.append(r); med_kg.append(w); med_rest.append(t)
    else:
        sets_cnt = [np.nan]*len(df); med_reps = [np.nan]*len(df); med_kg = [np.nan]*len(df); med_rest = [np.nan]*len(df)

    y8_raw = np.column_stack([
        pd.to_numeric(sets_cnt, errors="coerce"),
        pd.to_numeric(med_reps, errors="coerce"),
        pd.to_numeric(med_kg, errors="coerce"),
        pd.to_numeric(df.get("distance_km", np.nan), errors="coerce"),
        pd.to_numeric(df.get("duration_min", np.nan), errors="coerce"),
        pd.to_numeric(med_rest, errors="coerce"),
        pd.to_numeric(df.get("avg_hr", np.nan), errors="coerce"),
        pd.to_numeric(df.get("max_hr", np.nan), errors="coerce"),
    ]).astype("float32")

    scales = {
        "sets":     (1.0, 5.0),
        "reps":     (5.0, 20.0),
        "kg":       (0.0, float(load_cap_kg)),
        "km":       (0.0, 20.0),
        "min":      (0.0, 120.0),
        "minRest":  (0.0, 5.0),
        "avgHR":    (60.0, 180.0),
        "peakHR":   (100.0, 200.0),
    }
    keys = ["sets","reps","kg","km","min","minRest","avgHR","peakHR"]

    ymask = (~np.isnan(y8_raw)).astype("float32")

    y8 = np.zeros_like(y8_raw, dtype="float32")
    for idx, k in enumerate(keys):
        lo, hi = scales[k]
        col = y8_raw[:, idx]
        col = np.clip(col, lo, hi, where=~np.isnan(col))
        col = np.where(np.isnan(col), 0.0, (col - lo) / max(1e-6, (hi - lo)))
        y8[:, idx] = col

    # 3) Features & preprocessor
    feat_candidates = [
        "age","height_cm","weight_kg","bmi","bmr","bodyFatPct","resting_hr",
        "bp_systolic","bp_diastolic","cholesterol","blood_sugar_fasting",
        "max_pushups","max_weight_lifted_kg","workout_frequency_per_week",
        "avg_hr","max_hr","calories","duration_min",
        "gender","experience_level","activity_level",
        "equipment","target_muscle","secondary_muscles",
    ]
    feat_used = [c for c in feat_candidates if c in df.columns]
    Xdf = df[feat_used].copy()

    num_cols = [c for c in Xdf.columns if pd.api.types.is_numeric_dtype(Xdf[c])]
    cat_cols = [c for c in Xdf.columns if pd.api.types.is_object_dtype(Xdf[c])]

    pre = ColumnTransformer([
        ("num", Pipeline([("imp", SimpleImputer(strategy="median")),
                          ("sc",  StandardScaler())]), num_cols),
        ("cat", Pipeline([("imp", SimpleImputer(strategy="most_frequent")),
                          ("oh",  OneHotEncoder(handle_unknown="ignore"))]), cat_cols),
    ], remainder="drop")

    X_all_sp = pre.fit_transform(Xdf)
    X_all = X_all_sp.toarray() if hasattr(X_all_sp, "toarray") else np.asarray(X_all_sp)

    y_cls = df[ex_cols].values.astype("float32")  # [N, C]

    # ---------------- SAFE STRATIFIED SPLIT ----------------
    counts = np.bincount(gt_idx, minlength=len(ex_cols))
    mask_strat = counts[gt_idx] >= 2       # lớp có >= 2 mẫu
    mask_rare  = ~mask_strat               # lớp đơn

    X_str, X_rare   = X_all[mask_strat], X_all[mask_rare]
    yc_str, yc_rare = y_cls[mask_strat], y_cls[mask_rare]
    y8_str, y8_rare = y8[mask_strat], y8[mask_rare]
    m8_str, m8_rare = ymask[mask_strat], ymask[mask_rare]
    gi_str, gi_rare = gt_idx[mask_strat], gt_idx[mask_rare]

    n_samples = X_str.shape[0]
    n_classes = len(np.unique(gi_str))

    if n_classes >= 2 and n_samples >= 2 * n_classes:
        # tính test_size động: >= n_classes và chừa đủ train >= n_classes
        default_test = int(np.ceil(0.2 * n_samples))
        min_test = n_classes
        max_test = n_samples - n_classes
        if max_test < min_test:
            # không thể phân tầng an toàn
            strat_ok = False
        else:
            test_size = max(min_test, default_test)
            test_size = min(test_size, max_test)
            strat_ok = True
    else:
        strat_ok = False

    if strat_ok:
        X_tr, X_va, yc_tr, yc_va, y8_tr, y8_va, m8_tr, m8_va, gi_tr, gi_va = train_test_split(
            X_str, yc_str, y8_str, m8_str, gi_str,
            test_size=test_size, random_state=42, stratify=gi_str
        )
    else:
        # fallback: không stratify
        fallback_test = max(1, int(np.ceil(0.2 * max(1, n_samples))))
        X_tr, X_va, yc_tr, yc_va, y8_tr, y8_va, m8_tr, m8_va, gi_tr, gi_va = train_test_split(
            X_str, yc_str, y8_str, m8_str, gi_str,
            test_size=fallback_test, random_state=42, stratify=None
        )

    # cộng thêm rare classes vào TRAIN
    if X_rare.shape[0] > 0:
        X_tr  = np.vstack([X_tr,  X_rare])
        yc_tr = np.vstack([yc_tr, yc_rare])
        y8_tr = np.vstack([y8_tr, y8_rare])
        m8_tr = np.vstack([m8_tr, m8_rare])
        gi_tr = np.concatenate([gi_tr, gi_rare])

    print(f"[Info] Rare classes (count==1): {(counts==1).sum()} moved to TRAIN only.")
    print(f"[Info] Stratified part: samples={n_samples}, classes={n_classes}, "
          f"mode={'stratified' if strat_ok else 'non-stratified'}")
    # ------------------------------------------------------

    # 5) model & losses
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = UnifiedMTL(in_dim=X_all.shape[1], num_ex=len(ex_cols), d=256, joint_d=256).to(device)
    opt = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=1e-4)

    # pos_weight tính trên TRAIN
    pos = yc_tr.sum(axis=0) + 1e-6
    neg = (yc_tr.shape[0] - yc_tr.sum(axis=0)) + 1e-6
    pos_weight = torch.tensor(neg / pos, dtype=torch.float32, device=device)
    bce = nn.BCEWithLogitsLoss(pos_weight=pos_weight)

    def masked_reg_loss(pred_reg_bcex8, y8_true, mask8, gi):
        B = pred_reg_bcex8.size(0)
        idx = gi.view(B,1,1).expand(B,1,8)                # [B,1,8]
        pred_gt = pred_reg_bcex8.gather(1, idx).squeeze(1)  # [B,8]
        diff = F.smooth_l1_loss(pred_gt, y8_true, reduction="none")
        diff = diff * mask8
        return diff.sum() / (mask8.sum() + 1e-8)

    tr_dl = DataLoader(UniDataset(X_tr, yc_tr, y8_tr, m8_tr, gi_tr), batch_size=batch_size, shuffle=True)
    va_dl = DataLoader(UniDataset(X_va, yc_va, y8_va, m8_va, gi_va), batch_size=batch_size, shuffle=False)

    best_p5, best_path = -1.0, os.path.join(artifacts, "best.pt")
    for epoch in range(1, epochs+1):
        model.train(); tr_loss = 0.0
        for xb, ycb, y8b, m8b, gib in tr_dl:
            xb, ycb, y8b, m8b, gib = xb.to(device), ycb.to(device), y8b.to(device), m8b.to(device), gib.to(device)
            opt.zero_grad()
            logits, reg = model(xb)
            cls_loss = bce(logits, ycb)
            reg_loss = masked_reg_loss(reg, y8b, m8b, gib)
            loss = 1.0*cls_loss + 0.25*reg_loss
            loss.backward(); opt.step()
            tr_loss += loss.item()
        tr_loss /= max(1, len(tr_dl))

        model.eval(); va_loss = 0.0; p5s=[]; r5s=[]; coss=[]
        with torch.no_grad():
            for xb, ycb, y8b, m8b, gib in va_dl:
                xb, ycb, y8b, m8b, gib = xb.to(device), ycb.to(device), y8b.to(device), m8b.to(device), gib.to(device)
                logits, reg = model(xb)
                cls_loss = bce(logits, ycb)
                reg_loss = masked_reg_loss(reg, y8b, m8b, gib)
                loss = 1.0*cls_loss + 0.25*reg_loss
                va_loss += loss.item()
                p5, r5 = precision_recall_at_k(logits, ycb, K=5)
                p5s.append(p5); r5s.append(r5)
                p = torch.sigmoid(logits)
                cos = ((p/(p.norm(dim=1,keepdim=True)+1e-8)) * (ycb/(ycb.norm(dim=1,keepdim=True)+1e-8))).sum(dim=1).mean().item()
                coss.append(cos)
        va_loss /= max(1, len(va_dl))
        p5m, r5m, cosm = float(np.mean(p5s)), float(np.mean(r5s)), float(np.mean(coss))
        print(f"Epoch {epoch:02d} | train {tr_loss:.4f} | val {va_loss:.4f} | p@5 {p5m:.3f} | r@5 {r5m:.3f} | cos {cosm:.3f}")

        if p5m > best_p5:
            best_p5 = p5m
            torch.save({
              "state_dict": model.state_dict(),
              "in_dim": int(X_all.shape[1]),
              "num_ex": len(ex_cols),
              "ex_cols": ex_cols,
              "d": 256, "joint_d": 256
            }, best_path)
            with open(os.path.join(artifacts, "BEST.txt"), "w") as f:
                f.write(f"best_p@5={best_p5:.6f}\n")

    # save artifacts
    joblib.dump(pre, os.path.join(artifacts, "preprocessor.joblib"))
    with open(os.path.join(artifacts, "meta.json"), "w", encoding="utf-8") as fp:
        json.dump({
            "features_used": feat_used,
            "exercise_columns": ex_cols,
            "scales": {k: [float(v[0]), float(v[1])] for k,v in scales.items()},
            "regression_dims": ["sets","reps","kg","km","min","minRest","avgHR","peakHR"],
            "note": "Unified model: BCE multi-label + masked SmoothL1 on GT class. Rare classes in TRAIN only. Dynamic stratified split."
        }, fp, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--excel_path", default="data/merged_omni_health_dataset.xlsx")
    ap.add_argument("--artifacts", default="artifacts_unified")
    ap.add_argument("--epochs", type=int, default=80)
    ap.add_argument("--batch_size", type=int, default=128)
    ap.add_argument("--lr", type=float, default=1e-3)
    ap.add_argument("--load_cap_kg", type=float, default=200.0)
    args = ap.parse_args()
    main(args.excel_path, args.artifacts, args.epochs, args.batch_size, args.lr, args.load_cap_kg)
