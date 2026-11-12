"""Build the small tutorial dataset from the full simulated BAL study.

All data is simulated; no row describes a real person.

Source (local only, gitignored): data/bal/bal-project/data/
Output (committed):              tutorials/data/

- bal_metadata.xlsx     MetaData sheet for a random subset of participants.
                        Surname, Firstname and BirthDate are dropped; Age is
                        added from cleaned_baseline.csv (age_at_visit), because
                        the raw birth dates mix ambiguous day/month formats.
- bal_cell_counts.xlsx  Baseline, Month3, Month6 and Month12 sheets for the
                        same participants.
- bal_baseline.csv      Matching rows of the cleaned baseline table.

Cell values are copied as-is so the raw files keep their original messiness.

Run from the project root:  uv run python tutorials/data/_build_tutorial_data.py
"""

import csv
import random
from pathlib import Path

from openpyxl import Workbook, load_workbook

N_PARTICIPANTS = 500
SEED = 2026

SRC = Path("data/bal/bal-project/data")
OUT = Path("tutorials/data")
DROP_META = {"Surname", "Firstname", "BirthDate"}


def read_rows(path, sheet):
    ws = load_workbook(path, read_only=True)[sheet]
    rows = ws.iter_rows(values_only=True)
    header = list(next(rows))
    return header, [list(r) for r in rows]


def main():
    OUT.mkdir(parents=True, exist_ok=True)

    # Age at visit per participant, from the cleaned table.
    with open(SRC / "clean/cleaned_baseline.csv", newline="") as f:
        baseline = list(csv.DictReader(f))
    age = {r["pt_id"]: r["age_at_visit"] for r in baseline}

    meta_header, meta_rows = read_rows(SRC / "raw/metadata.xlsx", "MetaData")
    id_col = meta_header.index("Pt_ID")

    # Participants with metadata, an age, and a baseline BAL visit.
    bal_path = SRC / "raw/bal.xlsx"
    _, bal_baseline = read_rows(bal_path, "Baseline")
    bal_ids = {r[0] for r in bal_baseline}
    eligible = sorted(
        {r[id_col] for r in meta_rows} & set(age) & bal_ids, key=str
    )
    random.seed(SEED)
    keep = set(random.sample(eligible, N_PARTICIPANTS))

    # Metadata: drop identifying columns, add Age after Sex.
    keep_cols = [i for i, h in enumerate(meta_header) if h not in DROP_META]
    sex_pos = [meta_header[i] for i in keep_cols].index("Sex") + 1
    wb = Workbook()
    ws = wb.active
    ws.title = "MetaData"
    header = [meta_header[i] for i in keep_cols]
    header.insert(sex_pos, "Age")
    ws.append(header)
    n_meta = 0
    for r in meta_rows:
        if r[id_col] in keep:
            row = [r[i] for i in keep_cols]
            a = age[r[id_col]]
            row.insert(sex_pos, int(a) if a not in ("", "NA") else None)
            ws.append(row)
            n_meta += 1
    wb.save(OUT / "bal_metadata.xlsx")

    # Cell counts: one sheet per visit, same participants.
    wb = Workbook()
    wb.remove(wb.active)
    counts = {}
    for sheet in ["Baseline", "Month3", "Month6", "Month12"]:
        h, rows = read_rows(bal_path, sheet)
        ws = wb.create_sheet(sheet)
        ws.append(h)
        sel = [r for r in rows if r[0] in keep]
        for r in sel:
            ws.append(r)
        counts[sheet] = len(sel)
    wb.save(OUT / "bal_cell_counts.xlsx")

    # Cleaned baseline CSV.
    sel = [r for r in baseline if r["pt_id"] in keep]
    with open(OUT / "bal_baseline.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(baseline[0].keys()))
        w.writeheader()
        w.writerows(sel)

    print(f"participants: {len(keep)}  metadata rows: {n_meta}")
    print(f"cell count rows: {counts}  baseline csv rows: {len(sel)}")


if __name__ == "__main__":
    main()
