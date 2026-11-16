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

All three source files contain `user_id`, `date`, `distance_km`, `duration_min`, `idle_time_min`, `revenue_kes`, and `maintenance_kes`.

| Source field | Meaning | Handling |
|---|---|---|
| `user_id` | Anonymised rider identifier | Stored as `RIDERS.RIDER_CODE` |
| `date` | Calendar day (`YYYY-MM-DD`) | Stored as `DAILY_OPERATIONS.OPERATING_DATE` |
| `distance_km` | Daily distance in kilometres | Stored as a decimal measure |
| `duration_min` | Daily travel duration in minutes | Stored as a decimal measure |
| `idle_time_min` | Daily momentary-stop time in minutes | Stored as a decimal measure |
| `revenue_kes` | Daily revenue in Kenyan shillings | Stored as a decimal measure; blanks remain NULL |
| `maintenance_kes` | Daily maintenance total in Kenyan shillings | Stored as a decimal measure; blanks remain NULL |
| `fuel_cost_kes` | Fuel cost in Kenyan shillings | Fuel groups only |
| `fuel_unit_cost_kes_per_l` | Fuel price per litre | Fuel groups only |
| `fuel_amount_l` | Daily fuel amount in litres | Fuel groups only |
| `battery_swap_cost_kes` | Battery-swap cost in Kenyan shillings | Electric group only |
| `kwh_charging` | Energy charged in kilowatt-hours | Electric group only |

The original daily files do **not** contain a trip count. MotoTrack does not import the trip-level files or derive trip counts from them.

## 4. Missing values

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
