import torch
import torch.nn as nn
import json

ART = "./model"
META = f"{ART}/meta.json"
CKPT = f"{ART}/best.pt"

meta = json.load(open(META, "r", encoding="utf-8"))
ckpt = torch.load(CKPT, map_location="cpu")

ex_cols = ckpt["ex_cols"]
in_dim = ckpt["in_dim"]
num_ex = ckpt["num_ex"]

class UnifiedMTL(nn.Module):
    def __init__(self, in_dim, num_ex, d=256, joint_d=256, drop=0.15):
        super().__init__()
        self.encoder = nn.Sequential(
            nn.Linear(in_dim, d), nn.ReLU(), nn.Dropout(drop),
            nn.Linear(d, d), nn.ReLU(), nn.Dropout(drop)
        )
        self.ex_embed = nn.Parameter(torch.randn(num_ex, d) * 0.02)
        self.head_cls = nn.Sequential(nn.Linear(d*3, joint_d), nn.ReLU(), nn.Linear(joint_d, 1))
        self.head_reg = nn.Sequential(
            nn.Linear(d*3, joint_d), nn.ReLU(),
            nn.Linear(joint_d, 128), nn.ReLU(),
            nn.Linear(128, 8)
        )

    def forward(self, x):
        B = x.size(0)
        h = self.encoder(x)
        E = self.ex_embed
        C = E.size(0)
        h_exp = h.unsqueeze(1).expand(B, C, h.size(1))
        E_exp = E.unsqueeze(0).expand(B, C, E.size(1))
        joint = torch.cat([h_exp, E_exp, h_exp*E_exp], dim=2)
        logits = self.head_cls(joint).squeeze(-1)
        reg = torch.sigmoid(self.head_reg(joint))
        return logits, reg

# Load model
model = UnifiedMTL(in_dim, num_ex).eval()
model.load_state_dict(ckpt["state_dict"])
