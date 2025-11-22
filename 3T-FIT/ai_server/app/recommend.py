import numpy as np
from preprocess import cast_to_pre_schema, inv, cardio_like, sc
from model import model, ex_cols
import torch
import pandas as pd
from preprocess import pre

def recommend(profile: dict, top_k: int = 5) -> dict:
    Xdf = cast_to_pre_schema(pd.DataFrame([profile]))
    X_trans = pre.transform(Xdf)
    if hasattr(X_trans, "toarray"): X_trans = X_trans.toarray()
    X = torch.tensor(X_trans.astype("float32"))

    with torch.no_grad():
        logits, reg = model(X)
        probs = torch.sigmoid(logits).numpy()[0]
        reg = reg.numpy()[0]

    top_idx = np.argsort(-probs)[:top_k]
    plan = []
    avgHRs, peakHRs, prob_list = [], [], []

    for i in top_idx:
        name = ex_cols[i].replace("exercise_", "")
        y = reg[i]
        sets    = max(1, int(round(inv(y[0], *sc["sets"]))))
        reps    = int(round(inv(y[1], *sc["reps"])))
        kg      = max(0.0, inv(y[2], *sc["kg"]))
        km      = max(0.0, inv(y[3], *sc["km"]))
        minutes = max(0.0, inv(y[4], *sc["min"]))
        rest    = max(0.0, inv(y[5], *sc["minRest"]))
        avgHR   = int(round(inv(y[6], *sc["avgHR"])))
        peakHR  = int(round(inv(y[7], *sc["peakHR"])))

        if "max_weight_lifted_kg" in profile and profile["max_weight_lifted_kg"]:
            kg = min(kg, 0.9 * float(profile["max_weight_lifted_kg"]))

        sets_list = []
        if cardio_like(name):
            for _ in range(sets):
                sets_list.append({"reps": 0, "kg": 0.0, "km": round(km,2), "min": round(minutes,1), "minRest": round(rest,1)})
        else:
            for _ in range(sets):
                sets_list.append({"reps": int(reps), "kg": round(kg,1), "km": 0.0, "min": 0.0, "minRest": round(rest,1)})

        plan.append({"name": name, "sets": sets_list})
        avgHRs.append(avgHR)
        peakHRs.append(peakHR)
        prob_list.append(float(probs[i]))

    suitability = float(np.mean(prob_list)) if prob_list else 0.0
    return {
        "exercises": plan,
        "suitabilityScore": round(suitability, 4),
        "predictedAvgHR": int(np.mean(avgHRs)) if avgHRs else 0,
        "predictedPeakHR": int(np.max(peakHRs)) if peakHRs else 0
    }
