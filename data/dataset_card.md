# Dataset Card — Nairobi Motorcycle Transit Comparison Dataset

**Project:** MotoTrack — Moto Taxi Trip, Fuel and Maintenance Cost Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL  
**Phase:** II — Data sourcing, quality assessment and logical design

| Document control | |
|---|---|
| Version | 1.0 |
| Status | Final — Phase II |
| Author | Irakiza Blaise (29289) |
| Date | 15 November 2026 |
| Related documents | `docs/design/normalization.md`, `docs/design/erd.png`, `docs/design/data_dictionary.md`, `docs/design/phase_ii_checklist.md` |

## Contents

1. [Source and licence](#1-source-and-licence)
2. [Raw storage and integrity](#2-raw-storage-and-integrity)
3. [Format and size](#3-format-and-size)
4. [What one record represents](#4-what-one-record-represents)
5. [Date collected and coverage](#5-date-collected-and-coverage)
6. [Personal data and anonymisation](#6-personal-data-and-anonymisation)
7. [Data-quality assessment (counts)](#7-data-quality-assessment-counts)
8. [Quality issues that drive the logical design](#8-quality-issues-that-drive-the-logical-design)
9. [What will be cleaned in Phase IV (not done here)](#9-what-will-be-cleaned-in-phase-iv-not-done-here)
10. [Limitations](#10-limitations)
11. [Citation](#11-citation)

## 1. Source and licence

| Item | Detail |
|---|---|
| Dataset | Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023) |
| Publisher | Mendeley Data |
| DOI | `10.17632/nv3rkn24zv.1` |
| URL | https://data.mendeley.com/datasets/nv3rkn24zv |
| Licence | CC BY 4.0 |
| Related article | Mbutura et al. (2025), *Data in Brief*, 61, 111805. https://doi.org/10.1016/j.dib.2025.111805 |
| Study area | Nairobi, Kenya |
| Time zone | UTC+3 (East Africa Time) |

The dataset compares fuel (ICE) motorcycles with electric motorcycles in a baseline phase and a transition phase. Financial values are in Kenyan Shillings (KES). Blank CSV cells represent missing values; they are not zeros.

## 2. Raw storage and integrity

The untouched download is stored in `data/raw/`:

```
data/raw/
├── Nairobi Motorcycle Transit Comparison Dataset Fuel vs. Electric Vehicle Performance Tracking (2023).zip
├── daily_data/
│   ├── baseline-fuel-motorcycle-daily-data.csv
│   ├── transition-control-fuel-motorcycle-daily-data.csv
│   ├── transition-treatment-electric-motorcycle-daily-data.csv
│   └── README.txt
└── trip_data/
    ├── baseline-fuel-motorcycle-trip-data.csv
    ├── transition-control-fuel-motorcycle-trip-data.csv
    ├── transition-treatment-electric-motorcycle-trip-data.csv
    └── README.txt
```

A SHA-256 comparison against `data/original/` confirms that every file in `data/raw/` is byte-for-byte identical to the downloaded copy. No raw file has been edited, sorted, deduplicated, renamed or cleaned.

## 3. Format and size

| Item | Value |
|---|---|
| Format | ZIP archive containing six UTF-8 comma-separated CSV files and two README files |
| ZIP size | 3.82 MB (3,818,480 bytes) |
| Uncompressed CSV size | 14.98 MB (14,975,355 bytes across six CSVs) |
| Data rows | **128,785** (126,067 trip rows + 2,718 daily rows) |
| Unique fields across files | 23 |
| Daily files | 3 files; 10 columns for fuel, 9 columns for electric |
| Trip files | 3 files; 15 columns in each |
| Header | One header row per CSV |
| Encoding | UTF-8; no byte-order mark; no quoted fields; comma delimiter |
| Missing values | Empty cells |

### File inventory

| File | Records | Columns | Distinct `user_id` | Dates covered | Meaning |
|---|---:|---:|---:|---|---|
| `baseline-fuel-motorcycle-daily-data.csv` | 1,480 | 10 | 118 | 2023-11-13 → 2023-11-26 | Daily summary, baseline fuel cohort |
| `transition-control-fuel-motorcycle-daily-data.csv` | 1,150 | 10 | 108 | 2023-12-10 → 2023-12-21 | Daily summary, transition control fuel cohort |
| `transition-treatment-electric-motorcycle-daily-data.csv` | 88 | 9 | 9 | 2023-12-10 → 2023-12-21 | Daily summary, transition treatment electric cohort |
| `baseline-fuel-motorcycle-trip-data.csv` | 68,325 | 15 | 118 | 2023-11-13 → 2023-11-26 | Trip-level GPS records, baseline fuel cohort |
| `transition-control-fuel-motorcycle-trip-data.csv` | 54,087 | 15 | 108 | 2023-12-10 → 2023-12-21 | Trip-level GPS records, transition control fuel cohort |
| `transition-treatment-electric-motorcycle-trip-data.csv` | 3,655 | 15 | 9 | 2023-12-10 → 2023-12-21 | Trip-level GPS records, transition treatment electric cohort |
| **Total** | **128,785** | | **119 distinct overall** | 26 distinct dates | |

## 4. What one record represents

- **Daily record:** one tracked motorcycle unit's aggregated activity for one calendar date. It contains daily distance, travel time, idle time, revenue, maintenance cost and the energy-cost fields for that unit's powertrain.
- **Trip record:** one GPS-tracked trip segment made by one tracked motorcycle unit. It contains start and end date/time, duration, distance, idle time, coordinates, and average, moving-average and maximum speeds.
- **Tracked unit:** an anonymised `user_id` within one cohort. The same `user_id` can appear in more than one cohort, so a unit is identified by the combination of rider identifier and cohort, not by `user_id` alone.

## 5. Date collected and coverage

| Item | Value |
|---|---|
| Collection year | 2023 |
| Local copy date | 2026-11-07 (filesystem timestamp on the raw CSVs) |
| Baseline phase | 2023-11-13 → 2023-11-26 (14 days) |
| Transition phase | 2023-12-10 → 2023-12-21 (12 days) |
| Distinct dates across the dataset | 26 |
| Daily and trip date sets | Identical: all 26 dates appear in both daily and trip data |
| Users in daily data | 119 |
| Users in trip data | 119 |
| Users appearing in both | 119 (0 daily-only, 0 trip-only) |
| Users appearing in more than one daily cohort | **107 of 119** |
| Electric users also present in control/baseline | **9 of 9** |

### Unit-day coverage gaps

Expected unit-days = distinct users × days in the phase.

| Cohort | Expected unit-days | Actual daily rows | Absent unit-days |
|---|---:|---:|---:|
| Baseline fuel | 118 × 14 = 1,652 | 1,480 | **172 (10.4%)** |
| Transition control fuel | 108 × 12 = 1,296 | 1,150 | **146 (11.3%)** |
| Transition treatment electric | 9 × 12 = 108 | 88 | **20 (18.5%)** |

These are gaps in coverage, not confirmed data errors. A rider may simply not have worked on a given day.

## 6. Personal data and anonymisation

- The dataset uses a numeric `user_id` as a pseudonymous rider/unit identifier. It contains **no names, phone numbers, national ID numbers, e-mail addresses or motorcycle registration plates**.
- The publisher states that start and end coordinates for the first and last trips of each day were intentionally removed to protect riders' home locations.
- No additional anonymisation was necessary. The raw files were **not modified**.
- The `user_id` values are retained as `source_user_id` in the logical design because they are needed to link daily and trip records. They are not displayed as personal identities.

## 7. Data-quality assessment (counts)

### 7.1 Missing values

| File | Column | Missing | % of file | Notes |
|---|---|---:|---:|---|
| Baseline daily | `revenue_kes` | 266 | 18.0% | Same 266 rows also miss maintenance and all fuel fields |
| Baseline daily | `maintenance_kes` | 266 | 18.0% | |
| Baseline daily | `fuel_cost_kes` | 266 | 18.0% | |
| Baseline daily | `fuel_unit_cost_kes_per_l` | 266 | 18.0% | |
| Baseline daily | `fuel_amount_l` | 266 | 18.0% | |
| Control daily | `revenue_kes` | 209 | 18.2% | Same 209 rows also miss maintenance and all fuel fields |
| Control daily | `maintenance_kes` | 209 | 18.2% | |
| Control daily | `fuel_cost_kes` | 209 | 18.2% | |
| Control daily | `fuel_unit_cost_kes_per_l` | 209 | 18.2% | |
| Control daily | `fuel_amount_l` | 209 | 18.2% | |
| Electric daily | `revenue_kes` | 4 | 4.5% | Same 4 rows also miss maintenance and all electric fields |
| Electric daily | `maintenance_kes` | 4 | 4.5% | |
| Electric daily | `battery_swap_cost_kes` | 48 | 54.5% | |
| Electric daily | `kwh_charging` | 60 | 68.2% | |
| Baseline trip | `start_lat`, `start_lon`, `end_lat`, `end_lon` | 1,480 each | 2.2% each | 2,954 trip rows have at least one coordinate missing (4.3%) |
| Control trip | `start_lat`, `start_lon`, `end_lat`, `end_lon` | 1,150 each | 2.1% each | 2,288 trip rows have at least one coordinate missing (4.2%) |
| Electric trip | `start_lat`, `start_lon`, `end_lat`, `end_lon` | 88 each | 2.4% each | 174 trip rows have at least one coordinate missing (4.8%) |

All other daily and trip columns are complete: **0 missing `user_id`, dates, times, distance, duration, idle time, speeds, or max speed**.

Rows where **all cost/energy fields are blank**:

| Cohort | Rows with all cost/energy blank | % of cohort |
|---|---:|---:|
| Baseline fuel daily | 266 | 18.0% |
| Control fuel daily | 209 | 18.2% |
| Electric treatment daily | 4 | 4.5% |

### 7.2 Duplicates and key problems

| Check | Count | Detail |
|---|---:|---|
| Exact duplicate rows inside each individual CSV | **0** | No repeated CSV lines in any of the six files |
| Identical daily rows on the seven columns shared by the control and electric files | **3** | Three control/electric pairs match on `user_id`, `date`, `distance_km`, `duration_min`, `idle_time_min`, `revenue_kes` and `maintenance_kes` (revenue and maintenance are blank in both rows). There are **0 byte-identical full rows across files** because the fuel and electric layouts have different column counts |
| Duplicate daily `(user_id, date)` keys across cohorts | **88 groups / 88 extra rows** | The control and electric files share 88 rider/date pairs. Three pairs match on all seven shared columns; 81 match on distance, duration and idle time but differ on revenue/maintenance; 4 differ on the common measures too |
| Duplicate daily `(user_id, date)` keys within one cohort | **0** | The pair is unique inside each file |
| Duplicate trip keys `(user_id, start_date, start_time, end_date, end_time, distance_km)` across cohorts | **3,655 groups / 3,655 extra rows** | Exactly the electric trip row count. 3,654 of 3,655 pairs are identical on all 15 trip fields; 1 pair differs |
| Duplicate trip keys when the cohort is included | **0** | The cohort discriminator separates the files |
| Duplicate trip keys within one cohort | **0** | |
| Users appearing in more than one daily cohort | **107** | See Section 5 |
| Electric users also present in control and baseline | **9 of 9** | User IDs: 579236, 629227, 629740, 662555, 662819, 662983, 663045, 680968, 769744 |

**Consequence:** `user_id` is not a unique identifier for a tracked unit, and a trip/daily key without the cohort will collapse 3,655 electric trips and 88 daily rows. The logical design therefore uses `RIDER`, `COHORT` and a `RIDER_UNIT` junction table, and it includes the cohort in the unit identity.

### 7.3 Value and range checks

No non-numeric tokens were found in numeric columns: **0**. However, every numeric field is stored as text in the CSV and must be converted with `TO_NUMBER` in Phase IV. Blanks must become `NULL`, not zero.

| Check | Baseline | Control | Electric | Total / notes |
|---|---:|---:|---:|---|
| Negative distance / duration / idle / revenue / maintenance / fuel / battery / kWh / speed | 0 | 0 | 0 | Negative latitude is valid (Nairobi is south of the equator) |
| Invalid dates | 0 | 0 | 0 | All dates match `YYYY-MM-DD` |
| Invalid times | 0 | 0 | 0 | All times match `HH:MM:SS` |
| End timestamp before start timestamp | 0 | 0 | 0 | |
| Trip duration differs from timestamps by more than 1 minute | 1 | 0 | 0 | One baseline inconsistency |
| Trip `start_date` different from `end_date` | 36 | 15 | 4 | 55 cross-midnight trips; date and time must be combined into a timestamp |
| Trip `max_speed_kmh` below `avg_speed_kmh` | 176 | 123 | 8 | 307 logical inconsistencies |
| Trip average or moving-average speed above 100 km/h | 18 | 1 | 0 | 19 total; 11 baseline values are above 200 km/h, maximum 2,004.29 km/h |
| Trip distance = 0 km | 25 | 72 | 0 | 97 zero-distance trips |
| Trip distance > 50 km | 3 | 0 | 0 | 3 baseline outliers |
| Trip duration > 180 min | 10 | 2 | 2 | 14 outliers |
| Out-of-range latitude/longitude | 0 | 0 | 0 | No coordinate outside valid ranges |
| Daily revenue > 20,000 KES | 13 | 11 | 0 | 24 outliers; 7 are above 50,000 KES (maximum 87,000) |
| Daily maintenance > 5,000 KES | 2 | 5 | 0 | 7 outliers; maximum 8,500 |
| Daily fuel cost > 5,000 KES | 1 | 0 | 0 | Maximum 12,000 |
| Daily duration > 720 min | 3 | 0 | 0 | Maximum 1,066.34 min |
| Daily idle time > 720 min | 4 | 0 | 0 | Maximum 1,198.85 min |
| Daily revenue = 0 | 37 | 103 | 5 | 145 rows; not necessarily an error |
| Daily maintenance = 0 | 894 | 717 | 63 | 1,674 rows; zero is a valid cost |
| Fuel amount = 0 L | 0 | 105 | — | 105 control rows record zero litres |

The fuel unit price is effectively constant within each phase: **214.30 KES/L** in all 1,214 non-null baseline rows and **217.36 KES/L** in all 941 non-null control rows. This is a data characteristic, not a key attribute.

### 7.4 Categories and spellings

| Check | Result |
|---|---|
| Free-text categorical fields | **0** — the files contain IDs, dates, times and numeric measures only |
| Spelling variants of the same category | **0** — there is no district/name/category text column to misspell |
| Cohort labels | **3**: `BASELINE`, `CONTROL`, `TREATMENT` |
| Powertrain labels | **2**: `FUEL`, `ELECTRIC` |
| Study-phase labels | **2**: `BASELINE`, `TRANSITION` |
| Where cohort/phase/powertrain come from | **The file name**, not a column. They must be derived consistently during the load |
| Inconsistent cohort/date combinations | **0** — baseline dates only occur in the baseline file; transition dates only in the two transition files |

### 7.5 Type conversions required in Phase IV

| Source representation | Target representation | Action |
|---|---|---|
| `user_id` numeric-looking text | text | Keep as text to preserve the source identifier exactly |
| `date` text `YYYY-MM-DD` | date | `TO_DATE(...,'YYYY-MM-DD')` |
| `start_date` + `start_time` | timestamp | Concatenate and convert with `TO_TIMESTAMP(...,'YYYY-MM-DD HH24:MI:SS')` |
| `end_date` + `end_time` | timestamp | Concatenate and convert with `TO_TIMESTAMP(...,'YYYY-MM-DD HH24:MI:SS')` |
| All numeric measures and costs | number | `TO_NUMBER(NULLIF(TRIM(value),''))` |
| Empty cell | `NULL` | `NULLIF(TRIM(value),'')`; never convert blanks to zero |
| File name | cohort, phase, powertrain | Derive from the six known file names |

## 8. Quality issues that drive the logical design

1. **`user_id` is not unique across cohorts.** 107 of 119 users appear in more than one cohort, and all 9 electric users also appear in control/baseline. The design therefore separates `RIDER` (the anonymised person identifier) from `COHORT` (the study group) and uses `RIDER_UNIT` as the junction table.
2. **The cohort must be part of every operational key.** Without it, 88 daily rows and 3,655 trip rows would be treated as duplicates.
3. **The six files repeat the same structure.** Cohort, phase and powertrain are encoded in the file name and must be mapped to one `COHORT` row per file, not stored as repeated text in every daily/trip row.
4. **The daily file is an aggregate of the trip file.** One unit-day contains many trips (a repeating group). The design separates `DAILY_OPERATIONS` from `TRIPS`.
5. **Energy costs are conditional on the powertrain.** Fuel and electric cost fields are mutually exclusive. They are split into `FUEL_DAILY_COSTS` and `ELECTRIC_DAILY_COSTS` to remove the conditional/transitive dependency and the wide NULL columns.
6. **Coordinates are deliberately incomplete.** They must be optional in `TRIPS`.
7. **There is no per-trip revenue or fare.** Revenue exists only at daily level. The logical design does not invent a trip fare.
8. **There is no event-level maintenance detail.** The daily `maintenance_kes` is an aggregate. `MAINTENANCE_EVENTS` is included for future/manual event entries but is not populated from this dataset, to avoid double counting.

## 9. What will be cleaned in Phase IV (not done here)

- Convert text dates, times and numbers to Oracle date/timestamp/number types.
- Convert blank cells to `NULL`; never to zero.
- Derive `cohort_name`, `study_phase` and `powertrain_type` from the six file names.
- Distinguish units by `(source_user_id, cohort_name)`.
- Keep the 3,655 electric/control duplicate trips as separate rows because they belong to different units; do not deduplicate them across cohorts.
- Decide how to handle the 88 daily control/electric same-user/date overlaps; keep both because they belong to different units.
- Review, but do not silently correct, the outliers and logical inconsistencies listed in Section 7.3.
- Preserve the raw files unchanged; all cleaning happens in staging and load scripts.

## 10. Limitations

- The dataset does not provide rider names, phone numbers, registration plates or other personal details; only the anonymised `user_id` is available.
- The daily and trip data are separate facts. There is no trip identifier in the daily file, so a strict daily-to-trip foreign key cannot be enforced. Daily totals may not reconcile exactly with the sum of trip rows.
- Revenue is available only at daily level. Per-trip fare cannot be derived reliably.
- Maintenance is available only as a daily total; individual maintenance events are not supplied.
- The 9 electric users overlap the fuel control and baseline groups. This is a real many-to-many participation pattern and is modelled explicitly.
- Coordinates for the first and last trips of each day are missing by design.
- The trip data contains apparent GPS/speed anomalies (for example, a maximum average speed of 2,004.29 km/h) that require review before analysis.
- The dataset is Nairobi-specific and is not a Rwanda dataset.

## 11. Citation

Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). *Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023)*. Mendeley Data, V1. https://doi.org/10.17632/nv3rkn24zv.1

Licence: CC BY 4.0.
