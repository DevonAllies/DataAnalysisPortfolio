"""Simulate plasma cytokine data for the tutorial participants.

Every value is invented: no row describes a real person, and the effects
below are simulation settings, not findings.

The layout copies the 27-analyte multiplex export in the full study
(data/bal/bal-project/data/raw/luminex.xlsx): the same columns (Pt_ID, Visit,
27 cytokines, Notes), the same visits, and the same out-of-range codes with
each analyte's lower and upper limits. None of that file's measurements are
used. Unlike that file, which has one sheet per whole-blood stimulation
condition, this has a single sheet of unstimulated plasma.

Participants and visits come from the cleaned tutorial data, so the output
joins onto bal_metadata_clean.csv by Pt_ID.

Output (tutorials/data/):
- bal_plasma_cytokines.xlsx  "Plasma" sheet, deliberately messy like a raw
                             export (out-of-range codes, odd ID case, notes)

Run from the project root:  uv run python scripts/simulate_plasma_cytokines.py
"""

from pathlib import Path

import numpy as np
import pandas as pd
from openpyxl import Workbook

SEED = 2026
DATA = Path("tutorials/data")
VISITS = ["Baseline", "Month3", "Month6"]

# Analyte: (simulated median in pg/mL, log-scale SD, module, lower limit, upper limit)
# Limits are the assay's reportable range, as in the original export's OOR codes.
ANALYTES = {
    "IL-1b":      (2.5,  0.9, "inflammatory", 0.89, 14753.0),
    "IL-1ra":     (180,  0.8, "interferon",   1.06, 15759.0),
    "IL-2":       (3.0,  1.0, "interferon",   0.79, 21492.0),
    "IL-4":       (2.0,  0.9, "type2",        0.63, 31333.0),
    "IL-5":       (4.0,  0.9, "type2",        1.56, 28573.0),
    "IL-6":       (6.0,  1.0, "inflammatory", 2.68, 26769.0),
    "IL-7":       (9.0,  0.8, "growth",       3.92, 5083.0),
    "IL-8":       (12,   0.9, "inflammatory", 0.54, 28505.0),
    "IL-9":       (18,   0.9, "type2",        1.70, 15849.0),
    "IL-10":      (7.0,  1.0, "interferon",   4.80, 27556.0),
    "IL-12(p70)": (7.0,  1.0, "interferon",   3.49, 29976.0),
    "IL-13":      (6.0,  0.9, "type2",        4.05, 5693.0),
    "IL-15":      (5.0,  0.8, "interferon",   0.69, 8318.0),
    "IL-17A":     (6.0,  1.0, "growth",       1.45, 19327.0),
    "Eotaxin":    (70,   0.7, "type2",        4.06, 30679.0),
    "FGF-basic":  (35,   0.8, "growth",       2.19, 25289.0),
    "G-CSF":      (45,   0.9, "inflammatory", 2.84, 11711.0),
    "GM-CSF":     (9.0,  1.0, "growth",       4.83, 17202.0),
    "IFN-y":      (12,   1.0, "interferon",   1.70, 23527.0),
    "IP-10":      (450,  0.8, "interferon",   2.69, 28486.0),
    "MCP-1":      (45,   0.7, "inflammatory", 3.91, 18903.0),
    "MIP-1a":     (7.0,  0.9, "inflammatory", 3.22, 22826.0),
    "MIP-1b":     (90,   0.7, "inflammatory", 2.01, 5084.0),
    "PDGF-BB":    (450,  1.0, "growth",       3.57, 22228.0),
    "RANTES":     (3200, 0.8, "growth",       2.04, 30432.0),
    "TNF-a":      (16,   0.8, "inflammatory", 1.92, 13699.0),
    "VEGF":       (55,   1.0, "growth",       1.58, 22112.0),
}

# Simulated effects on the natural-log scale (0.69 = doubling). Every other
# analyte has no group effect at all, so a 27-analyte screen has true nulls.
ACTIVE_TB = {"IP-10": 1.2, "IFN-y": 0.7, "IL-1ra": 0.6, "IL-6": 0.6,
             "TNF-a": 0.5, "IL-10": 0.4, "MCP-1": 0.3}
LTBI = {"IP-10": 0.2}
INDETERMINATE = {"IP-10": 0.4, "IFN-y": 0.2}
HIV_POSITIVE = {"IP-10": 0.5, "IL-10": 0.3, "TNF-a": 0.2}
# Share of the active TB effect left at each visit (falls during follow-up)
TB_EFFECT_BY_VISIT = {"Baseline": 1.0, "Month3": 0.6, "Month6": 0.3}

MODULE_SD = 0.45      # shared person-level variation within a module (correlation)
PERSON_SD = 0.35      # person-level variation per analyte (carries across visits)
SHARE_OF_NOISE = 0.6  # remaining visit-to-visit noise, as a share of each analyte's SD

NOTES = ["Plate re-run", "High CV noted", "Dilution 1:2", "ND"]


def below_code(limit, rng):
    style = rng.choice(["OOR <{}", "<{}", "< {}"], p=[0.6, 0.25, 0.15])
    return style.format(f"{limit:g}")


def above_code(limit, rng):
    style = rng.choice(["OOR >{}", "> {}"], p=[0.7, 0.3])
    return style.format(f"{limit:.1f}")


def main():
    rng = np.random.default_rng(SEED)

    metadata = pd.read_csv(DATA / "bal_metadata_clean.csv")
    cells = pd.read_csv(DATA / "bal_cell_counts_clean.csv")
    samples = (cells.loc[cells["visit"].isin(VISITS), ["pt_id", "visit"]]
               .merge(metadata[["pt_id", "tb_diagnosis", "hiv_status"]], on="pt_id"))
    samples["visit"] = pd.Categorical(samples["visit"], VISITS, ordered=True)
    samples = samples.sort_values(["pt_id", "visit"]).reset_index(drop=True)

    people = samples["pt_id"].unique()
    modules = sorted({m for *_, m, _, _ in ANALYTES.values()})
    module_effect = {m: dict(zip(people, rng.normal(0, MODULE_SD, len(people)))) for m in modules}

    rows = []
    person_effect = {a: dict(zip(people, rng.normal(0, PERSON_SD, len(people)))) for a in ANALYTES}
    for s in samples.itertuples(index=False):
        row = {"Pt_ID": s.pt_id, "Visit": s.visit}
        for analyte, (median, sd, module, low, high) in ANALYTES.items():
            log_value = (np.log(median)
                         + module_effect[module][s.pt_id]
                         + person_effect[analyte][s.pt_id]
                         + rng.normal(0, sd * SHARE_OF_NOISE))
            if s.tb_diagnosis == "Active TB":
                log_value += ACTIVE_TB.get(analyte, 0) * TB_EFFECT_BY_VISIT[s.visit]
            elif s.tb_diagnosis == "LTBI":
                log_value += LTBI.get(analyte, 0)
            elif s.tb_diagnosis == "Indeterminate":
                log_value += INDETERMINATE.get(analyte, 0)
            if s.hiv_status == "Positive":
                log_value += HIV_POSITIVE.get(analyte, 0)

            value = float(np.exp(log_value))
            if value < low:
                row[analyte] = below_code(low, rng)
            elif value > high:
                row[analyte] = above_code(high, rng)
            else:
                row[analyte] = round(value, 2)
        row["Notes"] = rng.choice(NOTES) if rng.random() < 0.18 else None
        rows.append(row)

    out = pd.DataFrame(rows)

    # A few IDs typed in lower case, as in the raw exports
    lower = rng.random(len(out)) < 0.01
    out.loc[lower, "Pt_ID"] = out.loc[lower, "Pt_ID"].str.lower()

    wb = Workbook()
    ws = wb.active
    ws.title = "Plasma"
    ws.append(list(out.columns))
    for record in out.itertuples(index=False):
        ws.append([None if (isinstance(v, float) and np.isnan(v)) else v for v in record])
    wb.save(DATA / "bal_plasma_cytokines.xlsx")

    print(f"Wrote {len(out)} plasma samples for {len(people)} participants "
          f"to {DATA / 'bal_plasma_cytokines.xlsx'}")


if __name__ == "__main__":
    main()
