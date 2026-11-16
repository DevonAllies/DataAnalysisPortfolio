# Build the cleaned tutorial datasets used by the statistics tutorials.
#
#   Rscript scripts/build_clean_data.R
#
# Reads the deliberately messy files in tutorials/data/ (bal_metadata.xlsx,
# bal_cell_counts.xlsx) and writes:
#   tutorials/data/bal_metadata_clean.csv     one row per participant
#   tutorials/data/bal_cell_counts_clean.csv  one row per participant per visit
#
# The metadata rules match Tutorial 3 (tutorials/03-clean-data-in-r), plus the
# columns that tutorial leaves as exercises. Keep the two in step: if a rule
# changes in the tutorial, change it here and rerun.
#
# General rules: never guess at a typo (814 is not "fixed" to 81.4); set
# impossible values to NA instead, and flag rows whose columns contradict each
# other (review_* columns) rather than changing them.

suppressPackageStartupMessages({
  library(readr)
  library(readxl)
  library(dplyr)
  library(purrr)
  library(stringr)
  library(lubridate)
  library(janitor)
  library(here)
})

data_dir      <- here("tutorials", "data")
missing_codes <- c("", "N/A", "ND", ".", "-", "not done")

# Helpers --------------------------------------------------------------------

clean_yes_no <- function(x) {
  x <- str_to_lower(x)
  case_when(
    x %in% c("y", "yes") ~ "Yes",
    x %in% c("n", "no")  ~ "No"
  )
}

clean_pos_neg <- function(x) {
  x <- str_to_lower(x)
  case_when(
    x %in% c("pos", "positive") ~ "Positive",
    x %in% c("neg", "negative") ~ "Negative"
  )
}

# Day-month-year first; month-first only when day-month-year is impossible
parse_dates <- function(x) {
  coalesce(dmy(x, quiet = TRUE), mdy(x, quiet = TRUE))
}

plausible <- function(x, lower, upper) {
  case_when(
    between(x, lower, upper) ~ x,
    TRUE                     ~ NA
  )
}

# The mean of two values; if one is missing, the other one
mean_of_two <- function(a, b) (coalesce(a, b) + coalesce(b, a)) / 2

# Stop if a recode left values unmatched (new NAs that weren't NA before)
check_no_new_na <- function(before, after, column) {
  lost <- unique(before[!is.na(before) & is.na(after)])
  if (length(lost) > 0) {
    stop(column, ": unmatched values: ", paste(lost, collapse = ", "), call. = FALSE)
  }
  after
}

# Metadata -------------------------------------------------------------------

raw <- read_excel(file.path(data_dir, "bal_metadata.xlsx"), sheet = "MetaData",
                  col_types = "text")

metadata <- raw |>
  type_convert(na = missing_codes, col_types = cols()) |>
  clean_names() |>
  mutate(pt_id = str_to_upper(str_trim(pt_id))) |>
  distinct()

stopifnot(nrow(metadata) == n_distinct(metadata$pt_id))

referral_lookup <- tribble(
  ~referral_key,     ~referral_site,
  "bellville",       "Bellville CHC",
  "bv",              "Bellville CHC",
  "claremont",       "Claremont CHC",
  "cchc",            "Claremont CHC",
  "delft",           "Delft CHC",
  "dchc",            "Delft CHC",
  "eerste river",    "Eerste River Hospital",
  "erh",             "Eerste River Hospital",
  "elsies river",    "Elsies River CHC",
  "erchc",           "Elsies River CHC",   # assumption: no Eerste River CHC exists in the data
  "khayelitsha",     "Khayelitsha District Hospital",
  "kdh",             "Khayelitsha District Hospital",
  "mitchells plain", "Mitchells Plain District Hospital",
  "mitchells plein", "Mitchells Plain District Hospital",
  "mp",              "Mitchells Plain District Hospital",
  "ottery",          "Ottery CHC",
  "retreat",         "Retreat CHC",
  "somerset",        "Somerset Hospital",
  "woodstock",       "Woodstock CHC",
  "ws",              "Woodstock CHC"
)

m <- metadata

m <- m |>
  mutate(
    sex        = check_no_new_na(sex, case_when(
                   str_to_lower(sex) %in% c("f", "female") ~ "Female",
                   str_to_lower(sex) %in% c("m", "male")   ~ "Male"), "sex"),
    hiv_status = check_no_new_na(hiv_status, clean_pos_neg(hiv_status), "hiv_status"),
    drug_use   = check_no_new_na(drug_use, clean_yes_no(drug_use), "drug_use"),
    vaping     = check_no_new_na(vaping, clean_yes_no(vaping), "vaping"),
    art        = check_no_new_na(art, clean_yes_no(art), "art")
  )

# Smoking: "no" is treated as Never (decision, as in Tutorial 3)
smoking_raw <- str_to_lower(m$smoking_status)
m$smoking_status <- check_no_new_na(m$smoking_status, case_when(
  smoking_raw == "yes"                            ~ "Current",
  smoking_raw %in% c("ex", "ex-smoker", "former") ~ "Former",
  smoking_raw %in% c("never", "no")               ~ "Never"
), "smoking_status")

# Drug type: "tik" is South African slang for crystal meth
drug_raw <- str_to_lower(m$drug_type)
m$drug_type <- case_when(
  drug_raw == "tik" ~ "Crystal meth",
  TRUE              ~ str_to_sentence(drug_raw)
)

# Vaping type: Juul is a brand of pod device, so it's grouped with Pod
vape_raw <- str_to_lower(m$vaping_type)
m$vaping_type <- check_no_new_na(m$vaping_type, case_when(
  vape_raw %in% c("pod", "juul") ~ "Pod",
  vape_raw == "e-cigarette"      ~ "E-cigarette",
  vape_raw == "vape pen"         ~ "Vape pen"
), "vaping_type")

# Smear grade: ordered categories
smear_raw <- str_remove_all(str_to_lower(m$smear_grade), "\\s")
m$smear_grade <- check_no_new_na(m$smear_grade, case_when(
  smear_raw %in% c("0", "neg", "negative")  ~ "Negative",
  smear_raw %in% c("scant", "scanty")       ~ "Scanty",
  smear_raw %in% c("1+", "+1", "oneplus")   ~ "1+",
  smear_raw %in% c("2+", "+2", "twoplus")   ~ "2+",
  smear_raw %in% c("3+", "+3", "threeplus") ~ "3+"
), "smear_grade")

# Chest X-ray: exact match for normal ("abnormal - other" contains "normal")
cxr <- str_to_lower(m$cxr_finding)
m$cxr_finding <- check_no_new_na(m$cxr_finding, case_when(
  cxr %in% c("normal", "nad", "no abnormality") ~ "Normal",
  str_detect(cxr, "cavit")                      ~ "Cavitation",
  str_detect(cxr, "infiltrate|consolidation")   ~ "Infiltrate/consolidation",
  cxr == "pleural effusion"                     ~ "Pleural effusion",
  cxr == "fibrosis"                             ~ "Fibrosis",
  str_detect(cxr, "other")                      ~ "Other abnormality"
), "cxr_finding")

# IGRA result
igra_raw <- str_to_lower(m$igra_result)
m$igra_result <- check_no_new_na(m$igra_result, case_when(
  igra_raw %in% c("pos", "positive") ~ "Positive",
  igra_raw %in% c("neg", "negative") ~ "Negative",
  igra_raw == "indeterminate"        ~ "Indeterminate",
  igra_raw == "borderline"           ~ "Borderline"
), "igra_result")

# GeneXpert: RIF result only applies when MTB is detected, so derive it
m <- m |>
  mutate(
    gene_xpert_res = case_when(
      str_to_lower(gene_xpert_res) == "mtb detected"     ~ "MTB detected",
      str_to_lower(gene_xpert_res) == "mtb not detected" ~ "MTB not detected",
      TRUE                                               ~ gene_xpert_res
    ),
    gene_xpert_rif = case_when(
      gene_xpert_res == "MTB detected" ~ gene_xpert_rif,
      TRUE                             ~ "Not applicable"
    )
  )

# ART regimen: TLD or efavirenz-based (TEE and similar)
regimen_raw <- str_to_lower(m$art_regimen)
m$art_regimen <- check_no_new_na(m$art_regimen, case_when(
  regimen_raw %in% c("tld", "tdf/3tc/dtg", "tdf+3tc+dtg",
                     "tenofovir/lamivudine/dolutegravir") ~ "TLD",
  regimen_raw %in% c("tee", "tdf+ftc+efv", "tenofovir/emtricitabine/efavirenz",
                     "efv-based", "efavirenz-based")      ~ "Efavirenz-based"
), "art_regimen")

# Ethnicity: fix capitals only. "Mixed" and "mixed race" are kept apart from
# "Coloured": whether they mean the same group is for the study team to say.
eth_raw <- str_to_lower(m$ethnicity)
m$ethnicity <- check_no_new_na(m$ethnicity, case_when(
  eth_raw == "black african"             ~ "Black African",
  eth_raw == "coloured"                  ~ "Coloured",
  eth_raw == "white"                     ~ "White",
  eth_raw == "asian"                     ~ "Asian",
  eth_raw %in% c("mixed", "mixed race")  ~ "Mixed race"
), "ethnicity")

# Referral clinic: rules first, then a lookup table for what's left
m <- m |>
  mutate(referral_key = referral_source |>
           str_to_lower() |>
           str_remove_all("'") |>
           str_remove(" (chc|community health( centre)?|hosp(ital)?|district hospital|dhc)$")) |>
  left_join(referral_lookup, by = "referral_key")
stopifnot(!anyNA(m$referral_site))

# Dates, measurements and derived values
m <- m |>
  mutate(
    date_seen        = parse_dates(date_seen),
    art_start_date   = parse_dates(art_start_date),
    igra_value_iu_ml = round(igra_value_iu_ml, 2),
    across(starts_with("height"), \(x) plausible(x, 100, 220)),
    across(starts_with("weight"), \(x) plausible(x, 25, 250)),
    height_cm = round(mean_of_two(height_1_cm, height_2_cm), 1),
    weight_kg = round(mean_of_two(weight_1_kg, weight_2_kg), 1),
    bmi       = round(weight_kg / (height_cm / 100)^2, 1),
    review_hiv = hiv_status == "Negative" & (!is.na(cd4_count) | !is.na(art)),
    review_bmi = !is.na(bmi) & bmi < 13
  )
stopifnot(!anyNA(m$date_seen), all(m$study_group == m$tb_diagnosis))

metadata_clean <- m |>
  select(
    pt_id, date_seen, sex, age, ethnicity, height_cm, weight_kg, bmi,
    tb_diagnosis, hiv_status, cd4_count, viral_load_cp_ml, art, art_regimen, art_start_date,
    smoking_status, drug_use, drug_type, vaping, vaping_type,
    gene_xpert_res, gene_xpert_rif, smear_grade, cxr_finding,
    igra_result, igra_value_iu_ml, referral_site, review_hiv, review_bmi
  ) |>
  arrange(pt_id)

# Cell counts ----------------------------------------------------------------

cells_path <- file.path(data_dir, "bal_cell_counts.xlsx")

cells <- excel_sheets(cells_path) |>
  set_names() |>
  map(\(sheet) read_excel(cells_path, sheet = sheet, col_types = "text")) |>
  list_rbind(names_to = "visit") |>
  type_convert(na = c(missing_codes, "ASAP", "unknown", "not recorded"), col_types = cols()) |>
  clean_names() |>
  mutate(pt_id = str_to_upper(str_trim(pt_id)))

stopifnot(nrow(cells) == nrow(distinct(cells, visit, pt_id)))

# Bronchoscopist: strip titles, then match the surname. Garbled entries
# ("Malason", "Therson", "de Vman") are matched by their start; the mapping
# agrees with bal_baseline.csv for every baseline row.
dr <- cells$dr_name |>
  str_to_lower() |>
  str_remove("^(dr|prof)\\.?\\s+")
cells$dr_name <- check_no_new_na(cells$dr_name, case_when(
  dr == "adams"                ~ "Dr. Adams",
  dr == "botha"                ~ "Dr. Botha",
  dr == "hendricks"            ~ "Dr. Hendricks",
  dr == "jacobs"               ~ "Dr. Jacobs",
  dr == "naidoo"               ~ "Dr. Naidoo",
  dr == "smith"                ~ "Dr. Smith",
  dr == "van der merwe"        ~ "Dr. Van Der Merwe",
  str_detect(dr, "^mala")      ~ "Prof. Malan",
  str_detect(dr, "^ther")      ~ "Prof. Theron",
  str_detect(dr, "^de v")      ~ "Prof. de Villiers"
), "dr_name")

# Lobe: abbreviations (RUL, lll), "R upper", "left lower lobe"
lobe <- cells$lobe |>
  str_to_lower() |>
  str_remove(" lobe$") |>
  str_replace("^l ", "left ") |>
  str_replace("^r ", "right ")
cells$lobe <- check_no_new_na(cells$lobe, case_when(
  lobe %in% c("rul", "right upper")  ~ "Right upper",
  lobe %in% c("rml", "right middle") ~ "Right middle",
  lobe %in% c("rll", "right lower")  ~ "Right lower",
  lobe %in% c("lul", "left upper")   ~ "Left upper",
  lobe %in% c("lll", "left lower")   ~ "Left lower"
), "lobe")

# Pellet colour: "red-tinged" is recorded as Bloody in bal_baseline.csv
pellet <- str_to_lower(cells$pellet_colour)
cells$pellet_colour <- case_when(
  pellet == "red-tinged" ~ "Bloody",
  TRUE                   ~ str_to_sentence(pellet)
)

diff <- str_to_lower(cells$diff_method)
cells$diff_method <- check_no_new_na(cells$diff_method, case_when(
  diff %in% c("auto", "automated") ~ "Automated",
  diff == "manual"                 ~ "Manual",
  diff == "both"                   ~ "Both"
), "diff_method")

notes <- str_to_lower(cells$notes)
cells$processing_delayed <- case_when(
  str_detect(notes, "delay|late")                            ~ TRUE,
  notes %in% c("no issues", "processed on time", "sample adequate") ~ FALSE
)

# Bronchoscopy dates. A date such as 03/09/2018 is valid read either way, so
# a month-first entry can't be spotted on its own. Visits follow a schedule
# (0, 3, 6, 12 months), so for participants whose visits come out of order,
# choose the reading of their ambiguous dates that puts the visits in order
# and closest to the schedule. Everyone else keeps the day-first reading.
schedule_days <- c(Baseline = 0, Month3 = 91, Month6 = 182, Month12 = 365)

fix_visit_dates <- function(visit, date_text) {
  dmy_read <- dmy(date_text, quiet = TRUE)
  mdy_read <- mdy(date_text, quiet = TRUE)
  dates <- coalesce(dmy_read, mdy_read)
  ord <- order(schedule_days[visit])
  if (!is.unsorted(dates[ord], strictly = TRUE)) return(dates)

  ambiguous <- which(!is.na(dmy_read) & !is.na(mdy_read) & dmy_read != mdy_read)
  options <- expand.grid(rep(list(c(FALSE, TRUE)), length(ambiguous)))
  best <- dates
  best_score <- Inf
  for (i in seq_len(nrow(options))) {
    candidate <- dates
    swap <- ambiguous[unlist(options[i, ])]
    candidate[swap] <- mdy_read[swap]
    if (is.unsorted(candidate[ord], strictly = TRUE)) next
    gaps     <- diff(as.numeric(candidate[ord]))
    expected <- diff(schedule_days[visit][ord])
    score    <- sum((gaps - expected)^2)
    if (score < best_score) {
      best <- candidate
      best_score <- score
    }
  }
  best
}

cells <- cells |>
  group_by(pt_id) |>
  mutate(bronc_date = fix_visit_dates(visit, bronc_date)) |>
  ungroup()

cell_types <- c("macrophages", "lymphocytes", "neutrophils",
                "eosinophils", "basophils", "mast_cells")

cells <- cells |>
  mutate(
    visit         = factor(visit, levels = c("Baseline", "Month3", "Month6", "Month12")),
    lab_tech      = str_to_sentence(lab_tech),
    cytospin      = check_no_new_na(cytospin, clean_yes_no(cytospin), "cytospin"),
    # 999 is a missing code; recovered volume can't exceed what was instilled
    vol_pbs_out_ml = case_when(vol_pbs_out_ml <= vol_pbs_in_ml ~ vol_pbs_out_ml),
    vials_frozen   = case_when(vials_frozen != 999 ~ vials_frozen),
    time_to_process_min = case_when(time_to_process_min > 0 ~ time_to_process_min),
    # Cell numbers: 999 is a missing code, negatives are impossible, and live
    # or dead cells can't exceed the total (these are typos such as a missing
    # decimal point; set to NA rather than guessed)
    total_cells = case_when(total_cells > 999 ~ total_cells),
    live_cells  = case_when(live_cells > 999 & (is.na(total_cells) | live_cells <= total_cells) ~ live_cells),
    dead_cells  = case_when(dead_cells > 999 & (is.na(total_cells) | dead_cells <= total_cells) ~ dead_cells),
    across(ends_with("_percent"), \(x) plausible(x, 0, 100))
  )

# Absolute counts are total_cells * percent / 10000 in this dataset. Keep a
# recorded count only when it agrees (within 5%) with the cleaned total and
# percentage; otherwise it rests on a bad value and is set to NA.
for (cell in cell_types) {
  pct <- cells[[paste0(cell, "_percent")]]
  abs <- cells[[paste0(cell, "_abs")]]
  expected <- cells$total_cells * pct / 10000
  cells[[paste0(cell, "_abs")]] <- case_when(
    abs(abs - expected) <= 0.05 * pmax(expected, 1) ~ abs
  )
}

percent_total <- rowSums(select(cells, ends_with("_percent")))

cells_clean <- cells |>
  mutate(review_differential = !is.na(percent_total) & abs(percent_total - 100) > 2) |>
  select(
    pt_id, visit, bronc_date, dr_name, lab_tech, lobe,
    vol_pbs_in_ml, vol_pbs_out_ml, pellet_colour,
    live_cells, dead_cells, total_cells, time_to_process_min, processing_delayed,
    diff_method, ends_with("_percent"), ends_with("_abs"),
    cytospin, vials_frozen, review_differential
  ) |>
  arrange(pt_id, visit)

stopifnot(all(cells_clean$pt_id %in% metadata_clean$pt_id))

# Write ----------------------------------------------------------------------

write_csv(metadata_clean, file.path(data_dir, "bal_metadata_clean.csv"), na = "")
write_csv(cells_clean, file.path(data_dir, "bal_cell_counts_clean.csv"), na = "")

message("Wrote ", nrow(metadata_clean), " participants and ",
        nrow(cells_clean), " visits to ", data_dir)
