import joblib
import pandas as pd
import numpy as np
import json

ART = "./model"
PRE = f"{ART}/preprocessor.joblib"
META = f"{ART}/meta.json"

pre = joblib.load(PRE)
meta = json.load(open(META, "r", encoding="utf-8"))
features = meta["features_used"]
sc = meta["scales"]

def inv(v, lo, hi): 
    return float(v) * (hi - lo) + lo

def cardio_like(name: str):
    s = name.lower()
    return any(k in s for k in ["run","jog","bike","cycle","row","swim","elliptical","walking","cycling"])

def cast_to_pre_schema(df: pd.DataFrame) -> pd.DataFrame:
    for c in features:
        if c not in df.columns:
            df[c] = np.nan
    df = df[features]

    num_cols = [c for name, _, cols in pre.transformers_ if name=="num" for c in cols]
    cat_cols = [c for name, _, cols in pre.transformers_ if name=="cat" for c in cols]

    for c in num_cols:
        if c in df.columns:
            df[c] = pd.to_numeric(df[c], errors="coerce")
    for c in cat_cols:
        if c in df.columns:
            df[c] = df[c].astype("object")
    return df
