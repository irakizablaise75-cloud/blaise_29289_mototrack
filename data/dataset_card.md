# Dataset Card — MotoTrack Daily Operating Data

**Project:** MotoTrack: Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL

## 1. Source

**Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)**

- DOI: `10.17632/nv3rkn24zv.1`
- URL: https://data.mendeley.com/datasets/nv3rkn24zv
- Contributors: Martin Kitetu, Alois Mbutura, Halloran Stratford, MJ Booysen
- Publisher: Mendeley Data, version 1, published 3 March 2025
- Licence: CC BY 4.0
- Format: CSV (UTF-8, comma-separated, one header row per file)
- Size: 174,826 bytes total — baseline 94,693; transition-control 73,165; transition-treatment electric 4,934; source README 2,034
- Collection period: 13 November 2023 – 21 December 2023 (baseline 13–26 Nov; transition 10–21 Dec)
- Date retrieved: 7 November 2026 (files downloaded from the Mendeley Data record above)

## 2. Working data

MotoTrack loads the three original daily summary CSVs under `data/raw/daily_data/`. One row represents one rider's daily operation in one study group.

| Source file | Source group | Rows | Riders in group | Date range |
|---|---|---:|---:|---|
| `baseline-fuel-motorcycle-daily-data.csv` | `BASELINE_FUEL` | 1,480 | 118 | 2023-11-13 to 2023-11-26 |
| `transition-control-fuel-motorcycle-daily-data.csv` | `TRANSITION_CONTROL_FUEL` | 1,150 | 108 | 2023-12-10 to 2023-12-21 |
| `transition-treatment-electric-motorcycle-daily-data.csv` | `TRANSITION_TREATMENT_ELECTRIC` | 88 | 9 | 2023-12-10 to 2023-12-21 |
| **Total** | | **2,718** | **119 distinct rider IDs; 235 rider/group pairs** | **2023-11-13 to 2023-12-21** |

The source group is assigned during loading from the staging table. It is required because a rider may occur in multiple groups, and a rider/date alone is not the unique daily key.

## 3. Fields and mapping

All three source files contain `user_id`, `date`, `distance_km`, `duration_min`, `idle_time_min`, `revenue_kes` and `maintenance_kes`. The two fuel files add three fuel fields; the electric file adds two electric fields. Every source field maps to exactly one target column.

| Source field | Target (table.column) | Logical type | Meaning | Cleaning / conversion rule |
|---|---|---|---|---|
| `user_id` | `RIDERS.RIDER_CODE` | Text (identifier) | Anonymised rider identifier | Trim; insert distinct values once; daily rows link through the generated `rider_id` |
| file name | `SOURCE_GROUP.GROUP_CODE` → `DAILY_OPERATIONS.SOURCE_GROUP` | Code (lookup FK) | Study group | Map each staging table to its fixed group code |
| `date` | `DAILY_OPERATIONS.OPERATING_DATE` | Date | Calendar day | Parse as `YYYY-MM-DD`; flag values that do not match |
| `distance_km` | `DAILY_OPERATIONS.DISTANCE_KM` | Numeric | Daily distance, km | Trim; blank → `NULL`; must be ≥ 0 |
| `duration_min` | `DAILY_OPERATIONS.DURATION_MIN` | Numeric | Daily travel time, minutes | Trim; blank → `NULL`; must be ≥ 0 |
| `idle_time_min` | `DAILY_OPERATIONS.IDLE_TIME_MIN` | Numeric | Momentary-stop time, minutes | Trim; blank → `NULL`; must be ≥ 0 |
| `revenue_kes` | `DAILY_OPERATIONS.REVENUE_KES` | Numeric | Daily revenue, KES | Trim; blank → `NULL`; must be ≥ 0 |
| `maintenance_kes` | `DAILY_OPERATIONS.MAINTENANCE_KES` | Numeric | Daily maintenance total, KES | Trim; blank → `NULL`; must be ≥ 0 |
| `fuel_cost_kes` | `DAILY_OPERATIONS.FUEL_COST_KES` | Numeric | Fuel cost, KES | Fuel groups only; blank → `NULL` |
| `fuel_unit_cost_kes_per_l` | `DAILY_OPERATIONS.FUEL_UNIT_COST_KES_PER_L` | Numeric | Fuel price, KES/litre | Fuel groups only; blank → `NULL` |
| `fuel_amount_l` | `DAILY_OPERATIONS.FUEL_AMOUNT_L` | Numeric | Fuel used, litres | Fuel groups only; blank → `NULL` |
| `battery_swap_cost_kes` | `DAILY_OPERATIONS.BATTERY_SWAP_COST_KES` | Numeric | Battery-swap cost, KES | Electric group only; blank → `NULL` |
| `kwh_charging` | `DAILY_OPERATIONS.KWH_CHARGING` | Numeric | Energy charged, kWh | Electric group only; blank → `NULL` |

No source field maps to `SOURCE_GROUP` attributes, `MAINTENANCE_EVENTS`, `MAINTENANCE_TYPE` or `AUDIT_LOG`; those are seeded or populated by later application use and by the audit trigger. The original daily files do **not** contain a trip count, so MotoTrack does not import trip-level files or derive trip counts.

**Cleaning checklist applied during the load (Phase IV):**

1. Trim every text value and convert empty strings to `NULL` with `NULLIF(TRIM(column), '')`.
2. Confirm each `date` matches `YYYY-MM-DD`; the three files contain no invalid or missing dates.
3. Confirm every populated numeric value parses as a number; the three files contain no non-numeric values.
4. Confirm no duplicate rows and no duplicate `(user_id, date)` pairs; the three files contain none.
5. Seed the three `SOURCE_GROUP` rows before loading daily rows.
6. Load distinct riders first, then upsert daily rows on `(rider_id, source_group, operating_date)`.
7. Leave blank financial and energy fields as `NULL`; never substitute zero.

## 4. Data quality check

The raw files were profiled before any cleaning. Counts below are across all three files (2,718 rows combined).

| Quality check | Result |
|---|---:|
| Duplicate rows (all columns) | 0 |
| Duplicate `(user_id, date)` keys | 0 |
| Missing `user_id` | 0 |
| Missing `date` | 0 |
| Invalid `date` format | 0 |
| Non-numeric value in a numeric field | 0 |
| Negative measure | 0 |

No rows are removed at this stage. The only issues found are the expected blank values recorded below.

### Missing values

Blank numeric cells are loaded as `NULL` and are not replaced with zero.

| Source group | Rows with missing revenue | Missing maintenance | Missing applicable energy cost | Other noted missing values |
|---|---:|---:|---:|---|
| `BASELINE_FUEL` | 266 | 266 | 266 fuel-cost values | Other fuel fields are preserved as provided |
| `TRANSITION_CONTROL_FUEL` | 209 | 209 | 209 fuel-cost values | Other fuel fields are preserved as provided |
| `TRANSITION_TREATMENT_ELECTRIC` | 4 | 4 | 48 battery-swap-cost values | 60 rows have no `kwh_charging` value |

Profit is reported only when revenue, maintenance, and the applicable fuel or battery-swap cost are all present. Missing values therefore do not create an assumed zero-cost profit.

## 5. Provenance and scope

- The three original daily CSVs and their source README are retained unchanged in `data/raw/daily_data/`; these are the load inputs.
- A duplicate of the daily CSVs and README is intentionally kept under `data/original/daily_data/` for provenance.
- Trip-level CSVs, the downloaded archive and the legacy derived extract were removed to keep the project scoped to daily data. The cited dataset DOI links to the publisher source.
- The source daily files are aggregated; they do not contain individual trip timestamps, GPS coordinates, or per-trip fares.
- Daily maintenance is an aggregate, not a maintenance event. Do not copy it into `MAINTENANCE_EVENTS` or add it again to profit.
- The data is from Nairobi, Kenya, not Rwanda. Rider identifiers are anonymised.

## 6. Attribution

Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). *Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023)* [Data set]. Mendeley Data. https://doi.org/10.17632/nv3rkn24zv.1. CC BY 4.0.
