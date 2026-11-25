"""Build the example data-capture workbook for the Excel article.

An example to learn from, not a template to fill in: it shows layout rules,
drop-down lists, range and date checks, an ID-format and duplicate check,
input messages, the three error-alert styles, a data dictionary and sheet
protection, with notes on how each was set up.

The five example rows come from the simulated tutorial data
(tutorials/data/bal_metadata_clean.csv): no row describes a real person.

Output: writing/excel-for-data-capture/bal-capture-example.xlsx
Run from the project root:  uv run python scripts/build_excel_capture_example.py
"""

from datetime import date
from pathlib import Path

import pandas as pd
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill, Protection
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.datavalidation import DataValidation

OUT = Path("writing/excel-for-data-capture/bal-capture-example.xlsx")
FIRST, LAST = 2, 501          # data rows that carry the rules (room for 500 participants)
HEADER_FILL = PatternFill("solid", fgColor="0F4C5C")
HEADER_FONT = Font(bold=True, color="FFFFFF")

# Allowed values, one list per categorical column (kept on their own sheet so
# they can be changed in one place)
LISTS = {
    "sex": ["Female", "Male"],
    "tb_diagnosis": ["Active TB", "LTBI", "Indeterminate", "Control"],
    "hiv_status": ["Negative", "Positive"],
    "smear_grade": ["Negative", "Scanty", "1+", "2+", "3+"],
    "referral_site": sorted([
        "Bellville CHC", "Claremont CHC", "Delft CHC", "Eerste River Hospital",
        "Elsies River CHC", "Khayelitsha District Hospital",
        "Mitchells Plain District Hospital", "Ottery CHC", "Retreat CHC",
        "Somerset Hospital", "Woodstock CHC",
    ]),
}

# Column, description, type, rule, units, validation (or None)
COLUMNS = [
    ("pt_id", "Participant ID", "Text", "SP followed by 5 digits, e.g. SP00013; must be unique", ""),
    ("date_seen", "Date of the study visit", "Date", "2016-01-01 to today; type as YYYY-MM-DD", ""),
    ("sex", "Sex recorded at enrolment", "Category", "Choose from the list", ""),
    ("age", "Age at the visit", "Whole number", "0 to 120", "years"),
    ("tb_diagnosis", "TB diagnosis", "Category", "Choose from the list", ""),
    ("hiv_status", "HIV status", "Category", "Choose from the list", ""),
    ("cd4_count", "CD4 count (HIV-positive participants only)", "Whole number", "0 to 5000; leave blank if not measured", "cells/µL"),
    ("weight_kg", "Body weight", "Decimal", "20 to 200 expected; outside this, Excel asks you to check", "kg"),
    ("smear_grade", "Sputum smear grade", "Category", "Choose from the list", ""),
    ("referral_site", "Clinic that referred the participant", "Category", "Choose from the list", ""),
    ("notes", "Free-text comments", "Text", "Up to 250 characters; never put data here that belongs in a column", ""),
]


def header(ws, row, values, widths=None):
    for col, value in enumerate(values, start=1):
        cell = ws.cell(row=row, column=col, value=value)
        cell.fill, cell.font = HEADER_FILL, HEADER_FONT
        cell.alignment = Alignment(vertical="top", wrap_text=True)
    if widths:
        for col, width in enumerate(widths, start=1):
            ws.column_dimensions[get_column_letter(col)].width = width


def rule(ws, sqref, title, prompt, error, style="stop", **kwargs):
    dv = DataValidation(
        showInputMessage=True, promptTitle=title[:32], prompt=prompt[:255],
        showErrorMessage=True, errorTitle=title[:32], error=error[:255],
        errorStyle=style, **kwargs,
    )
    dv.add(sqref)
    ws.add_data_validation(dv)


def main():
    wb = Workbook()

    # --- Read me -----------------------------------------------------------
    readme = wb.active
    readme.title = "Read me"
    readme.column_dimensions["A"].width = 110
    notes = [
        ("Example data-capture workbook", True),
        ("An example to learn from and adapt, not a template to fill in. Every value is simulated.", False),
        ("", False),
        ("What's in it", True),
        ("Data: one row per participant, one value per cell, with a validation rule on every column (click a cell to see its input message).", False),
        ("Lists: the allowed values for each drop-down. Change a list here and every drop-down that uses it changes too.", False),
        ("Data dictionary: what each column means, its type, its allowed values and its units.", False),
        ("", False),
        ("How the rules were set (Data > Data Validation in Excel)", True),
        ("pt_id: Custom formula =AND(LEN(A2)=7, LEFT(A2,2)=\"SP\", ISNUMBER(--MID(A2,3,5)), COUNTIF($A$2:$A$501,A2)=1). Checks the format and that the ID isn't already used.", False),
        ("date_seen: Date, between 2016-01-01 and =TODAY(). Cells are formatted YYYY-MM-DD so dates can't be read in the wrong order.", False),
        ("sex, tb_diagnosis, hiv_status, smear_grade, referral_site: List, with the source set to a range on the Lists sheet.", False),
        ("age: Whole number between 0 and 120.  cd4_count: Whole number between 0 and 5000, blanks allowed.", False),
        ("weight_kg: Decimal between 20 and 200, with the Warning style: unusual values ask 'Continue?' instead of being refused.", False),
        ("notes: Text length up to 250, with the Information style: a reminder that can be dismissed.", False),
        ("", False),
        ("Error-alert styles", True),
        ("Stop refuses the value (impossible values). Warning asks whether to continue (unusual values). Information only informs.", False),
        ("", False),
        ("Limits: validation doesn't make the data clean", True),
        ("Rules only check values typed into a cell. Pasted or filled values skip them completely, with no message.", False),
        ("Data > Data Validation > Circle Invalid Data highlights cells that break the rules, including pasted ones. Run it before sharing the file.", False),
        ("Rules can't catch values that are possible but wrong, such as a real date that's the wrong date.", False),
        ("So check the data again when it's read into R or Python.", False),
        ("", False),
        ("Protection", True),
        ("The Data sheet is protected (no password) so the header row can't be changed by accident; the data cells are unlocked. Review > Unprotect Sheet removes it.", False),
    ]
    for i, (text, bold) in enumerate(notes, start=1):
        cell = readme.cell(row=i, column=1, value=text)
        cell.font = Font(bold=bold, size=14 if i == 1 else 11)
        cell.alignment = Alignment(wrap_text=True, vertical="top")

    # --- Lists -------------------------------------------------------------
    lists = wb.create_sheet("Lists")
    header(lists, 1, list(LISTS), widths=[16, 16, 16, 16, 34])
    ranges = {}
    for col, (name, values) in enumerate(LISTS.items(), start=1):
        for row, value in enumerate(values, start=2):
            lists.cell(row=row, column=col, value=value)
        letter = get_column_letter(col)
        ranges[name] = f"Lists!${letter}$2:${letter}${len(values) + 1}"

    # --- Data dictionary ---------------------------------------------------
    dic = wb.create_sheet("Data dictionary")
    header(dic, 1, ["Column", "Description", "Type", "Allowed values", "Units"], widths=[16, 42, 14, 60, 12])
    for row, (name, desc, kind, allowed, units) in enumerate(COLUMNS, start=2):
        if name in LISTS:
            allowed = ", ".join(LISTS[name])
        for col, value in enumerate([name, desc, kind, allowed, units], start=1):
            dic.cell(row=row, column=col, value=value).alignment = Alignment(wrap_text=True, vertical="top")
    note_row = len(COLUMNS) + 3
    dic.cell(row=note_row, column=1, value="Missing values: leave the cell blank. Don't use codes such as 999, NA or -, and don't explain gaps with colour.")

    # --- Data --------------------------------------------------------------
    ws = wb.create_sheet("Data", 1)
    names = [c[0] for c in COLUMNS]
    header(ws, 1, names, widths=[11, 12, 9, 7, 14, 11, 11, 11, 12, 30, 40])
    ws.freeze_panes = "A2"

    # Five example rows from the simulated tutorial data
    meta = pd.read_csv("tutorials/data/bal_metadata_clean.csv")
    example = pd.concat([meta[meta["cd4_count"].notna()].head(3), meta[meta["hiv_status"] == "Negative"].head(2)])
    for r, rec in enumerate(example.itertuples(index=False), start=FIRST):
        values = [rec.pt_id, date.fromisoformat(rec.date_seen), rec.sex, int(rec.age), rec.tb_diagnosis,
                  rec.hiv_status, None if pd.isna(rec.cd4_count) else int(rec.cd4_count),
                  None if pd.isna(rec.weight_kg) else float(rec.weight_kg), rec.smear_grade, rec.referral_site, None]
        for c, v in enumerate(values, start=1):
            ws.cell(row=r, column=c, value=v)

    col = {n: get_column_letter(i) for i, n in enumerate(names, start=1)}
    span = lambda n: f"{col[n]}{FIRST}:{col[n]}{LAST}"

    for r in range(FIRST, LAST + 1):
        ws[f"{col['date_seen']}{r}"].number_format = "yyyy-mm-dd"
        ws[f"{col['pt_id']}{r}"].number_format = "@"     # stored as text, never converted

    a = col["pt_id"]
    rule(ws, span("pt_id"), "Participant ID",
         "SP followed by 5 digits, e.g. SP00013. Each ID only once.",
         "The ID must be SP followed by 5 digits, and not already used in this sheet.",
         type="custom",
         formula1=f'AND(LEN({a}{FIRST})=7,LEFT({a}{FIRST},2)="SP",ISNUMBER(--MID({a}{FIRST},3,5)),COUNTIF(${a}${FIRST}:${a}${LAST},{a}{FIRST})=1)')
    rule(ws, span("date_seen"), "Visit date",
         "Type the date as YYYY-MM-DD, e.g. 2018-08-18. From 2016-01-01 to today.",
         "The visit date must be a date from 2016-01-01 to today.",
         type="date", operator="between", formula1="DATE(2016,1,1)", formula2="TODAY()")
    for name, label in [("sex", "Sex"), ("tb_diagnosis", "TB diagnosis"), ("hiv_status", "HIV status"),
                        ("smear_grade", "Smear grade"), ("referral_site", "Referral site")]:
        rule(ws, span(name), label, "Choose from the drop-down list.",
             "Choose a value from the list. The allowed values are on the Lists sheet.",
             type="list", formula1=ranges[name], allow_blank=False)
    rule(ws, span("age"), "Age", "Age in whole years, 0 to 120.",
         "Age must be a whole number from 0 to 120.",
         type="whole", operator="between", formula1="0", formula2="120")
    rule(ws, span("cd4_count"), "CD4 count", "Cells per µL, 0 to 5000. Leave blank if not measured.",
         "CD4 count must be a whole number from 0 to 5000.",
         type="whole", operator="between", formula1="0", formula2="5000", allow_blank=True)
    rule(ws, span("weight_kg"), "Weight", "Weight in kg. Values outside 20 to 200 are unusual.",
         "This weight is outside 20 to 200 kg. Check it was entered correctly before continuing.",
         style="warning", type="decimal", operator="between", formula1="20", formula2="200", allow_blank=True)
    rule(ws, span("notes"), "Notes", "Comments only, up to 250 characters. Data belongs in its own column.",
         "Notes are limited to 250 characters.",
         style="information", type="textLength", operator="lessThanOrEqual", formula1="250", allow_blank=True)

    # Protect the sheet so the header can't be edited; unlock the data cells
    for row in ws.iter_rows(min_row=FIRST, max_row=LAST, max_col=len(names)):
        for cell in row:
            cell.protection = Protection(locked=False)
    ws.protection.sheet = True
    ws.protection.formatCells = False   # allow resizing and formatting
    ws.protection.formatColumns = False

    OUT.parent.mkdir(parents=True, exist_ok=True)
    wb.save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
