# Normalization — MotoTrack Phase II

**Project:** MotoTrack — Moto Taxi Trip, Fuel and Maintenance Cost Tracker  
**Student:** Irakiza Blaise (29289)  
**Source:** Nairobi Motorcycle Transit Comparison Dataset (2023), Mendeley Data, DOI `10.17632/nv3rkn24zv.1`, CC BY 4.0  
**Raw data:** `data/raw/` (six CSV files, never edited)  
**Logical ERD:** `docs/design/erd.png`  
**Data dictionary:** `docs/design/data_dictionary.md`

| Document control | |
|---|---|
| Version | 1.0 |
| Status | Final — Phase II |
| Author | Irakiza Blaise (29289) |
| Date | 15 November 2026 |
| Related documents | `data/dataset_card.md`, `docs/design/erd.png`, `docs/design/data_dictionary.md`, `docs/design/phase_ii_checklist.md` |

## Contents

1. [Purpose and scope](#1-purpose-and-scope)
2. [Source relations and candidate keys](#2-source-relations-and-candidate-keys)
3. [Unnormalised form (UNF)](#3-unnormalised-form-unf)
4. [First Normal Form (1NF)](#4-first-normal-form-1nf)
5. [Second Normal Form (2NF)](#5-second-normal-form-2nf)
6. [Third Normal Form (3NF)](#6-third-normal-form-3nf)
7. [Final 3NF schema](#7-final-3nf-schema)
8. [Relationship cardinalities](#8-relationship-cardinalities)
9. [Assumptions and limitations](#9-assumptions-and-limitations)
10. [Alignment with the current Phase IV script](#10-alignment-with-the-current-phase-iv-script)
11. [Single-record trace for the in-class demonstration](#11-single-record-trace-for-the-in-class-demonstration)

## 1. Purpose and scope

This document normalises the real MotoTrack source data from its unnormalised form (UNF) through First, Second and Third Normal Form (1NF, 2NF, 3NF). It uses actual values from the downloaded CSVs, shows 3–5 real rows at each step, and names the dependency removed at every split.

The source is six flat CSV files rather than nested JSON. There are no multi-valued cells and no embedded lists in a single cell. The repeating-group problem therefore comes from the business event itself: **one tracked unit-day contains many trips**, and the daily CSV is an aggregate of those trips. The six files also repeat the same record structure for different study cohorts. The filename, not a column, carries the cohort, phase and powertrain.

The target is a 3NF logical design that is the blueprint for the Oracle tables in Phase IV. Oracle data types and sizes are intentionally omitted here; they belong in Phase IV.

## 2. Source relations and candidate keys

| Source | Grain | Candidate key in the source | Main attributes |
|---|---|---|---|
| `baseline-fuel-motorcycle-daily-data.csv` | One unit-day | (`file`, `user_id`, `date`) | distance, duration, idle time, revenue, maintenance, fuel cost, fuel unit price, fuel litres |
| `transition-control-fuel-motorcycle-daily-data.csv` | One unit-day | (`file`, `user_id`, `date`) | same as baseline fuel |
| `transition-treatment-electric-motorcycle-daily-data.csv` | One unit-day | (`file`, `user_id`, `date`) | distance, duration, idle time, revenue, maintenance, battery-swap cost, kWh |
| `baseline-fuel-motorcycle-trip-data.csv` | One trip | (`file`, `user_id`, `start_ts`, `end_ts`, `distance_km`) | duration, distance, idle time, coordinates, speeds |
| `transition-control-fuel-motorcycle-trip-data.csv` | One trip | (`file`, `user_id`, `start_ts`, `end_ts`, `distance_km`) | same as baseline trip |
| `transition-treatment-electric-motorcycle-trip-data.csv` | One trip | (`file`, `user_id`, `start_ts`, `end_ts`, `distance_km`) | same as baseline trip |

The filename supplies three descriptors that are not columns in the CSV:

| File | Cohort | Study phase | Powertrain |
|---|---|---|---|
| `baseline-fuel-motorcycle-*` | `BASELINE` | `BASELINE` | `FUEL` |
| `transition-control-fuel-motorcycle-*` | `CONTROL` | `TRANSITION` | `FUEL` |
| `transition-treatment-electric-motorcycle-*` | `TREATMENT` | `TRANSITION` | `ELECTRIC` |

## 3. Unnormalised form (UNF)

### 3.1 Structure

The UNF relation represents a tracked unit's day. It contains the daily aggregate values, both alternative energy-cost groups, and the repeating group of trips that make up the day:

```
MOTOTRACK_DAY_UNF(
  source_file, user_id, date,
  distance_km, duration_min, idle_time_min,
  revenue_kes, maintenance_kes,
  fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l,
  battery_swap_cost_kes, kwh_charging,
  trip_list
)
```

`trip_list` is the repeating group: one unit-day contains many trips. The two energy-cost groups are alternative, not repeating rows: a fuel unit uses the fuel group, an electric unit uses the electric group.

### 3.2 Real UNF rows

The `trip_list` column is abbreviated here; the actual trips are shown in Section 4.2. `—` means the column does not apply to that powertrain; blank means the source cell is empty (`NULL`).

| source_file | user_id | date | distance_km | duration_min | idle_time_min | revenue_kes | maintenance_kes | fuel_cost_kes | fuel_unit_cost_kes_per_l | fuel_amount_l | battery_swap_cost_kes | kwh_charging | trip_list (repeating) |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| baseline fuel daily | 579236 | 2023-11-13 | 129.44 | 267.59 | 17.78 | NULL | NULL | NULL | NULL | NULL | — | — | 11:54–11:58 1.33 km; 12:00–12:20 9.34 km; 12:20–12:22 0.52 km; … |
| baseline fuel daily | 579236 | 2023-11-14 | 113.02 | 232.36 | 10.87 | 1400.00 | 0.00 | 300.00 | 214.30 | 1.40 | — | — | 11:00–11:08 2.10 km; 11:20–11:45 10.20 km; … |
| baseline fuel daily | 627618 | 2023-11-14 | 55.56 | 134.38 | 10.15 | 1500.00 | 0.00 | 650.00 | 214.30 | 3.03 | — | — | 13:02–13:09 1.80 km; 13:15–13:36 8.40 km; … |
| control fuel daily | 579236 | 2023-12-10 | 121.31 | 227.43 | 11.16 | NULL | NULL | NULL | NULL | NULL | — | — | 11:06–11:31 15.57 km; 12:11–12:16 2.21 km; … |
| electric treatment daily | 579236 | 2023-12-11 | 119.74 | 245.78 | 11.64 | 870.00 | 0.00 | — | — | — | 176.00 | NULL | 10:58–11:20 8.10 km; 11:35–12:02 9.70 km; … |

### 3.3 UNF problems

1. **Repeating group:** `trip_list` repeats for every unit-day. A daily row hides many trip rows.
2. **Mixed concepts:** rider identity, cohort/phase/powertrain, daily aggregates, trip facts and energy costs are all in one relation.
3. **Alternative energy groups:** fuel and electric columns are mutually exclusive and produce many NULLs.
4. **Non-minimal key:** the cohort/phase/powertrain descriptors repeat on every daily and trip row, even though they describe the unit.
5. **Non-unique rider identifier:** `user_id` alone is not unique across cohorts. 107 of 119 users appear in more than one cohort; all 9 electric users also appear in control/baseline. The key must include the cohort.

## 4. First Normal Form (1NF)

### 4.1 Rule and change

1NF requires atomic values, no repeating groups, and a primary key. The repeating group of trips is removed by creating a separate `TRIPS` relation with one row per trip. Daily aggregates remain in `DAILY_OPERATIONS`. The cohort descriptor is added from the filename so that the same `user_id` in different files is not confused.

- `DAILY_OPERATIONS` key: (`cohort_name`, `user_id`, `operating_date`)
- `TRIPS` key: (`cohort_name`, `user_id`, `start_ts`, `end_ts`, `distance_km`)

The fuel and electric columns are still atomic alternatives at 1NF. They are split later in 3NF, not here.

### 4.2 Real 1NF rows

**DAILY_OPERATIONS after 1NF** (one row per unit-day; energy columns still wide):

| cohort_name | user_id | operating_date | distance_km | duration_min | idle_time_min | revenue_kes | maintenance_kes | fuel_cost_kes | fuel_unit_cost_kes_per_l | fuel_amount_l | battery_swap_cost_kes | kwh_charging |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| BASELINE | 579236 | 2023-11-13 | 129.44 | 267.59 | 17.78 | NULL | NULL | NULL | NULL | NULL | — | — |
| BASELINE | 579236 | 2023-11-14 | 113.02 | 232.36 | 10.87 | 1400.00 | 0.00 | 300.00 | 214.30 | 1.40 | — | — |
| BASELINE | 627618 | 2023-11-14 | 55.56 | 134.38 | 10.15 | 1500.00 | 0.00 | 650.00 | 214.30 | 3.03 | — | — |
| CONTROL | 579236 | 2023-12-10 | 121.31 | 227.43 | 11.16 | NULL | NULL | NULL | NULL | NULL | — | — |
| TREATMENT | 579236 | 2023-12-11 | 119.74 | 245.78 | 11.64 | 870.00 | 0.00 | — | — | — | 176.00 | NULL |

**TRIPS after 1NF** (one row per trip; first four trips of unit 579236 on 2023-11-13 plus one electric trip):

| cohort_name | user_id | start_ts | end_ts | duration_min | distance_km | idle_time_min | start_lat | start_lon | end_lat | end_lon | avg_speed_kmh | avg_moving_speed_kmh | max_speed_kmh |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| BASELINE | 579236 | 2023-11-13 11:54:00 | 2023-11-13 11:58:00 | 4.08 | 1.33 | 0.35 | NULL | NULL | -1.278038 | 36.883012 | 19.56 | 21.39 | 38.0 |
| BASELINE | 579236 | 2023-11-13 12:00:00 | 2023-11-13 12:20:00 | 19.93 | 9.34 | 0.47 | -1.278038 | 36.883012 | -1.282285 | 36.831860 | 28.12 | 28.80 | 44.0 |
| BASELINE | 579236 | 2023-11-13 12:20:00 | 2023-11-13 12:22:00 | 1.80 | 0.52 | 0.17 | -1.282285 | 36.831860 | -1.280667 | 36.827493 | 17.33 | 19.14 | 29.0 |
| BASELINE | 579236 | 2023-11-13 12:24:00 | 2023-11-13 12:33:00 | 9.48 | 4.52 | 0.47 | -1.280607 | 36.827370 | -1.257552 | 36.802875 | 28.61 | 30.10 | 47.0 |
| TREATMENT | 579236 | 2023-12-10 11:06:51 | 2023-12-10 11:31:01 | 24.17 | 15.57 | 0.35 | NULL | NULL | -1.257490 | 36.803090 | 38.65 | 39.22 | 59.0 |

**Dependency removed:** the repeating group of trips inside a unit-day was removed by creating one `TRIPS` row per trip; the daily aggregates stay in `DAILY_OPERATIONS`.

## 5. Second Normal Form (2NF)

### 5.1 Rule and change

2NF requires 1NF plus no partial dependency of a non-key attribute on part of a composite key. In the 1NF daily relation, the key is (`cohort_name`, `user_id`, `operating_date`). The descriptors `powertrain_type` and `study_phase` depend only on `cohort_name` (part of the key), not on the date. The unit descriptors also repeat for every daily row and every trip row.

The fix is a `RIDER_UNIT` relation:

- `RIDER_UNIT(unit_id, source_user_id, cohort_name)`
- Unique key: (`source_user_id`, `cohort_name`)
- `DAILY_OPERATIONS` now stores `unit_id` and the daily measures; the key becomes (`unit_id`, `operating_date`).
- `TRIPS` now stores `unit_id` and the trip measures; the key becomes (`unit_id`, `start_ts`, `end_ts`, `distance_km`).

This is also a real-data finding: `source_user_id` alone cannot identify a unit because 107 users participate in more than one cohort. The pair (`source_user_id`, `cohort_name`) is the unit.

### 5.2 Real 2NF rows

**RIDER_UNIT after 2NF** (illustrative surrogate IDs; the raw key is `source_user_id` + `cohort_name`):

| unit_id | source_user_id | cohort_name | powertrain_type | study_phase |
|---|---|---|---|---|
| U001 | 579236 | BASELINE | FUEL | BASELINE |
| U002 | 579236 | CONTROL | FUEL | TRANSITION |
| U003 | 579236 | TREATMENT | ELECTRIC | TRANSITION |
| U004 | 627618 | BASELINE | FUEL | BASELINE |
| U005 | 629227 | CONTROL | FUEL | TRANSITION |

**DAILY_OPERATIONS after 2NF** (unit descriptors removed; daily measures depend on `unit_id` + date):

| daily_id | unit_id | operating_date | distance_km | duration_min | idle_time_min | revenue_kes | maintenance_kes | fuel_cost_kes | fuel_unit_cost_kes_per_l | fuel_amount_l | battery_swap_cost_kes | kwh_charging |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| D001 | U001 | 2023-11-13 | 129.44 | 267.59 | 17.78 | NULL | NULL | NULL | NULL | NULL | — | — |
| D002 | U001 | 2023-11-14 | 113.02 | 232.36 | 10.87 | 1400.00 | 0.00 | 300.00 | 214.30 | 1.40 | — | — |
| D003 | U004 | 2023-11-14 | 55.56 | 134.38 | 10.15 | 1500.00 | 0.00 | 650.00 | 214.30 | 3.03 | — | — |
| D004 | U003 | 2023-12-11 | 119.74 | 245.78 | 11.64 | 870.00 | 0.00 | — | — | — | 176.00 | NULL |
| D005 | U003 | 2023-12-12 | 126.96 | 268.68 | 15.89 | 1750.00 | 100.00 | — | — | — | 370.00 | NULL |

**TRIPS after 2NF** (unit descriptors removed; trip measures depend on the trip key):

| trip_id | unit_id | start_ts | end_ts | duration_min | distance_km | idle_time_min | start_lat | start_lon | end_lat | end_lon | avg_speed_kmh | avg_moving_speed_kmh | max_speed_kmh |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| T001 | U001 | 2023-11-13 11:54:00 | 2023-11-13 11:58:00 | 4.08 | 1.33 | 0.35 | NULL | NULL | -1.278038 | 36.883012 | 19.56 | 21.39 | 38.0 |
| T002 | U001 | 2023-11-13 12:00:00 | 2023-11-13 12:20:00 | 19.93 | 9.34 | 0.47 | -1.278038 | 36.883012 | -1.282285 | 36.831860 | 28.12 | 28.80 | 44.0 |
| T003 | U001 | 2023-11-13 12:20:00 | 2023-11-13 12:22:00 | 1.80 | 0.52 | 0.17 | -1.282285 | 36.831860 | -1.280667 | 36.827493 | 17.33 | 19.14 | 29.0 |
| T004 | U003 | 2023-12-10 11:06:51 | 2023-12-10 11:31:01 | 24.17 | 15.57 | 0.35 | NULL | NULL | -1.257490 | 36.803090 | 38.65 | 39.22 | 59.0 |

**Dependency removed:** the partial dependencies of `powertrain_type`, `study_phase` and the unit descriptors on only part of the composite unit-day key were removed by moving them to `RIDER_UNIT`; daily measures now depend on the full (`unit_id`, `operating_date`) key, and trip measures depend on the trip key.

## 6. Third Normal Form (3NF)

### 6.1 Rule and change

3NF requires 2NF plus no transitive dependency of a non-key attribute on another non-key attribute. Three transitive/conditional dependencies remain after 2NF:

1. **Cohort descriptors depend on the cohort.** In `RIDER_UNIT`, `powertrain_type` and `study_phase` depend on `cohort_name`, not directly on `unit_id`. Move them to `COHORT(cohort_name, study_phase, powertrain_type)`.
2. **Energy costs depend on the powertrain.** In `DAILY_OPERATIONS`, the applicable fuel or electric cost group depends on the unit's powertrain. This is a conditional/transitive dependency (`daily_id → unit_id → cohort_name → powertrain_type → energy attributes`) and produces many NULLs. Split into `FUEL_DAILY_COSTS(daily_id, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l)` and `ELECTRIC_DAILY_COSTS(daily_id, battery_swap_cost_kes, kwh_charging)`, both one-to-one with `DAILY_OPERATIONS`.
3. **`source_group` is derivable.** The source-group label attached to each daily/trip row is derivable from `COHORT` (`cohort_name`, `study_phase`, `powertrain_type`). Storing it in every child row would be redundant. It is omitted from the logical 3NF design.

The many-to-many between riders and cohorts is resolved by `RIDER_UNIT`: a rider can participate in many cohorts, a cohort has many riders, and `RIDER_UNIT` is the junction. `RIDER` holds the anonymised rider identifier; `COHORT` holds the study descriptors.

### 6.2 Real 3NF rows

**RIDER** (one row per distinct anonymised `user_id`; 119 rows in total):

| rider_id | source_user_id |
|---|---|
| R001 | 579236 |
| R002 | 627618 |
| R003 | 629227 |

**COHORT** (three rows, one per source file group):

| cohort_name | study_phase | powertrain_type |
|---|---|---|
| BASELINE | BASELINE | FUEL |
| CONTROL | TRANSITION | FUEL |
| TREATMENT | TRANSITION | ELECTRIC |

**RIDER_UNIT** (junction between riders and cohorts; 235 rows in total):

| unit_id | rider_id | cohort_name |
|---|---|---|
| U001 | R001 | BASELINE |
| U002 | R001 | CONTROL |
| U003 | R001 | TREATMENT |
| U004 | R002 | BASELINE |
| U005 | R003 | CONTROL |

**DAILY_OPERATIONS** (energy columns removed; 2,718 rows in total):

| daily_id | unit_id | operating_date | distance_km | duration_min | idle_time_min | revenue_kes | maintenance_kes |
|---|---|---|---:|---:|---:|---:|---:|
| D001 | U001 | 2023-11-13 | 129.44 | 267.59 | 17.78 | NULL | NULL |
| D002 | U001 | 2023-11-14 | 113.02 | 232.36 | 10.87 | 1400.00 | 0.00 |
| D003 | U004 | 2023-11-14 | 55.56 | 134.38 | 10.15 | 1500.00 | 0.00 |
| D004 | U003 | 2023-12-11 | 119.74 | 245.78 | 11.64 | 870.00 | 0.00 |
| D005 | U003 | 2023-12-12 | 126.96 | 268.68 | 15.89 | 1750.00 | 100.00 |

**FUEL_DAILY_COSTS** (one-to-one with fuel daily operations; 2,630 rows in total; blanks become NULL):

| daily_id | fuel_cost_kes | fuel_unit_cost_kes_per_l | fuel_amount_l |
|---|---:|---:|---:|
| D001 | NULL | NULL | NULL |
| D002 | 300.00 | 214.30 | 1.40 |
| D003 | 650.00 | 214.30 | 3.03 |

**ELECTRIC_DAILY_COSTS** (one-to-one with electric daily operations; 88 rows in total):

| daily_id | battery_swap_cost_kes | kwh_charging |
|---|---:|---:|
| D004 | 176.00 | NULL |
| D005 | 370.00 | NULL |
| D006 | 147.00 | NULL |

**TRIPS** (126,067 rows in total; unit descriptors removed; coordinates optional):

| trip_id | unit_id | start_ts | end_ts | duration_min | distance_km | idle_time_min | start_lat | start_lon | end_lat | end_lon | avg_speed_kmh | avg_moving_speed_kmh | max_speed_kmh |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| T001 | U001 | 2023-11-13 11:54:00 | 2023-11-13 11:58:00 | 4.08 | 1.33 | 0.35 | NULL | NULL | -1.278038 | 36.883012 | 19.56 | 21.39 | 38.0 |
| T002 | U001 | 2023-11-13 12:00:00 | 2023-11-13 12:20:00 | 19.93 | 9.34 | 0.47 | -1.278038 | 36.883012 | -1.282285 | 36.831860 | 28.12 | 28.80 | 44.0 |
| T003 | U001 | 2023-11-13 12:20:00 | 2023-11-13 12:22:00 | 1.80 | 0.52 | 0.17 | -1.282285 | 36.831860 | -1.280667 | 36.827493 | 17.33 | 19.14 | 29.0 |
| T004 | U003 | 2023-12-10 11:06:51 | 2023-12-10 11:31:01 | 24.17 | 15.57 | 0.35 | NULL | NULL | -1.257490 | 36.803090 | 38.65 | 39.22 | 59.0 |

**MAINTENANCE_EVENTS** (0 rows from this source):

The daily dataset supplies only an aggregate `maintenance_kes`. It does not contain individual maintenance events. `MAINTENANCE_EVENTS` is therefore included as a child of `RIDER_UNIT` for future or manual event-level entries, but it is **not populated from the raw daily total** to avoid double counting. There are no real source rows to show for this table.

**Dependencies removed at 3NF:**

- Moved `study_phase` and `powertrain_type` from `RIDER_UNIT` to `COHORT`, removing the transitive dependency `cohort_name → study_phase/powertrain_type`.
- Moved fuel-specific attributes to `FUEL_DAILY_COSTS` and electric-specific attributes to `ELECTRIC_DAILY_COSTS`, removing the conditional/transitive dependency of energy costs on the unit's powertrain.
- Resolved the many-to-many between `RIDER` and `COHORT` with the `RIDER_UNIT` junction table.
- Removed `source_group` from child tables because it is derivable from `COHORT`.
- Kept `maintenance_kes` in `DAILY_OPERATIONS` as the daily aggregate and separated event-level maintenance into `MAINTENANCE_EVENTS`.

## 7. Final 3NF schema

| Table | Primary key | Unique constraints | Foreign keys | Grain |
|---|---|---|---|---|
| `RIDER` | `rider_id` | `source_user_id` | — | One anonymised rider |
| `COHORT` | `cohort_name` | — | — | One study cohort |
| `RIDER_UNIT` | `unit_id` | (`rider_id`, `cohort_name`) | `rider_id` → `RIDER`; `cohort_name` → `COHORT` | One rider's participation in one cohort |
| `DAILY_OPERATIONS` | `daily_id` | (`unit_id`, `operating_date`) | `unit_id` → `RIDER_UNIT` | One unit-day summary |
| `FUEL_DAILY_COSTS` | `daily_id` | `daily_id` | `daily_id` → `DAILY_OPERATIONS` | One fuel-cost row per fuel unit-day |
| `ELECTRIC_DAILY_COSTS` | `daily_id` | `daily_id` | `daily_id` → `DAILY_OPERATIONS` | One electric-cost row per electric unit-day |
| `TRIPS` | `trip_id` | (`unit_id`, `start_ts`, `end_ts`, `distance_km`) | `unit_id` → `RIDER_UNIT` | One trip |
| `MAINTENANCE_EVENTS` | `maintenance_event_id` | — | `unit_id` → `RIDER_UNIT` | One maintenance event (future/manual; not in source) |
| `AUDIT_LOG` | `audit_id` | — | — | One audit record (standalone) |

## 8. Relationship cardinalities

| Relationship | Cardinality | Optionality |
|---|---|---|
| `RIDER` → `RIDER_UNIT` | 1 : 0..* | A rider may have zero or more cohort participations; each unit has exactly one rider |
| `COHORT` → `RIDER_UNIT` | 1 : 0..* | A cohort may have zero or more riders; each unit belongs to exactly one cohort |
| `RIDER_UNIT` → `DAILY_OPERATIONS` | 1 : 0..* | A unit may have zero or more daily rows; each daily row has exactly one unit |
| `RIDER_UNIT` → `TRIPS` | 1 : 0..* | A unit may have zero or more trips; each trip has exactly one unit |
| `RIDER_UNIT` → `MAINTENANCE_EVENTS` | 1 : 0..* | A unit may have zero or more events; each event has exactly one unit |
| `DAILY_OPERATIONS` → `FUEL_DAILY_COSTS` | 1 : 0..1 | At most one fuel-cost row; required only when the unit's powertrain is `FUEL` |
| `DAILY_OPERATIONS` → `ELECTRIC_DAILY_COSTS` | 1 : 0..1 | At most one electric-cost row; required only when the unit's powertrain is `ELECTRIC` |
| `AUDIT_LOG` | standalone | No foreign key; populated by triggers |

## 9. Assumptions and limitations

1. **Daily and trip files are separate facts.** The daily file is an aggregate of trip activity, but it has no trip identifier. A strict `daily_id` foreign key in `TRIPS` would be unsafe because the daily totals may not reconcile exactly with the trip rows. The design links both to `RIDER_UNIT` instead.
2. **No per-trip revenue.** Revenue exists only at daily level. The design does not invent a fare column in `TRIPS`.
3. **No event-level maintenance in the source.** `MAINTENANCE_EVENTS` is included for future/manual use but is not loaded from the daily aggregate.
4. **The same rider appears in multiple cohorts.** `RIDER_UNIT` is the junction and the unit key is (`rider_id`, `cohort_name`).
5. **The 3,655 electric trips duplicate control trips on the trip fields.** They are kept because they belong to different units; the unit key includes the cohort.
6. **Missing values remain `NULL`.** Blank cells are never converted to zero.
7. **Coordinates are optional.** The publisher removed first/last trip coordinates for privacy.
8. **Timestamps are stored as recorded in UTC+3.** No time-zone conversion is applied in the logical design.
9. **`source_group` is not stored in the 3NF child tables.** It is derivable from `COHORT`; if a physical implementation keeps it for reporting, that is a documented denormalization.
10. **The logical design uses surrogate keys** (`rider_id`, `unit_id`, `daily_id`, `trip_id`, `maintenance_event_id`, `audit_id`) plus the natural unique keys listed in Section 7. Phase IV will choose the Oracle data types and identity/sequence strategy.

## 10. Alignment with the current Phase IV script

The current physical script `03_sql/01_schema/01_create_core_tables.sql` keeps `source_user_id`, `powertrain_type`, `cohort_name` and `study_phase` together in `RIDER_UNITS`, and it stores `source_group` in `DAILY_OPERATIONS` and `TRIPS`. That is a physical shortcut. This logical 3NF design extracts `COHORT`, separates `RIDER` from `RIDER_UNIT`, and omits the derived `source_group` from child tables. When Phase IV is finalised, either:

- align the physical tables to this logical design, or
- keep the shortcut and document it explicitly as a controlled denormalization.

The data dictionary in `docs/design/data_dictionary.md` follows this 3NF logical design.

## 11. Single-record trace for the in-class demonstration

This section traces one real source record and its trips into every 3NF table. It is the script for the five-minute in-class demonstration.

### 11.1 Source record

The chosen record is one daily row from `baseline-fuel-motorcycle-daily-data.csv`:

| Raw field | Raw value |
|---|---|
| `user_id` | `579236` |
| `date` | `2023-11-14` |
| `distance_km` | `113.02` |
| `duration_min` | `232.36` |
| `idle_time_min` | `10.87` |
| `revenue_kes` | `1400.00` |
| `maintenance_kes` | `0.00` |
| `fuel_cost_kes` | `300.00` |
| `fuel_unit_cost_kes_per_l` | `214.30` |
| `fuel_amount_l` | `1.40` |

The same unit has **35 trip rows whose `start_date` is `2023-11-14`** in `baseline-fuel-motorcycle-trip-data.csv`. The first three are:

| start_date | start_time | end_date | end_time | duration_min | distance_km | idle_time_min | start_lat | start_lon | end_lat | end_lon | avg_speed_kmh | avg_moving_speed_kmh | max_speed_kmh |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2023-11-14 | 10:58:00 | 2023-11-14 | 11:23:00 | 24.82 | 14.56 | 0.33 | NULL | NULL | -1.259723 | 36.817942 | 35.2 | 35.67 | 54.0 |
| 2023-11-14 | 11:30:00 | 2023-11-14 | 11:34:00 | 3.42 | 1.37 | 0.17 | -1.258522 | 36.818655 | -1.256992 | 36.808082 | 24.04 | 25.29 | 38.0 |
| 2023-11-14 | 11:34:00 | 2023-11-14 | 11:36:00 | 2.32 | 0.72 | 0.5 | -1.256992 | 36.808082 | -1.257582 | 36.802980 | 18.62 | 23.74 | 32.0 |

### 11.2 Where each value lands

| Source value | Target table and column | Stored value |
|---|---|---|
| `user_id` `579236` | `RIDER.source_user_id` | `579236` (surrogate `rider_id` = `R001`) |
| `user_id` + file name | `RIDER_UNIT` (`rider_id`, `cohort_name`) | (`R001`, `BASELINE`), surrogate `unit_id` = `U001` |
| File name `baseline-fuel-motorcycle-daily-data.csv` | `COHORT` (`cohort_name`, `study_phase`, `powertrain_type`) | (`BASELINE`, `BASELINE`, `FUEL`) |
| `date` `2023-11-14` | `DAILY_OPERATIONS.operating_date` | `2023-11-14` (with `unit_id` `U001`, surrogate `daily_id` = `D002`) |
| `distance_km` `113.02` | `DAILY_OPERATIONS.distance_km` | `113.02` |
| `duration_min` `232.36` | `DAILY_OPERATIONS.duration_min` | `232.36` |
| `idle_time_min` `10.87` | `DAILY_OPERATIONS.idle_time_min` | `10.87` |
| `revenue_kes` `1400.00` | `DAILY_OPERATIONS.revenue_kes` | `1400.00` |
| `maintenance_kes` `0.00` | `DAILY_OPERATIONS.maintenance_kes` | `0.00` (daily aggregate, not an event) |
| `fuel_cost_kes` `300.00` | `FUEL_DAILY_COSTS.fuel_cost_kes` | `300.00` (`daily_id` `D002`) |
| `fuel_unit_cost_kes_per_l` `214.30` | `FUEL_DAILY_COSTS.fuel_unit_cost_kes_per_l` | `214.30` |
| `fuel_amount_l` `1.40` | `FUEL_DAILY_COSTS.fuel_amount_l` | `1.40` |
| 35 trip rows with `start_date` `2023-11-14` | `TRIPS` | 35 rows, illustrated as `T005`–`T039` |
| `start_date` + `start_time` | `TRIPS.start_ts` | e.g. `2023-11-14 10:58:00` for `T005` |
| `end_date` + `end_time` | `TRIPS.end_ts` | e.g. `2023-11-14 11:23:00` for `T005` |
| Trip measures and coordinates | `TRIPS` | Copied per trip; blank coordinates become `NULL` |

The first three trips land in `TRIPS` as:

| trip_id | unit_id | start_ts | end_ts | duration_min | distance_km | idle_time_min | start_lat | start_lon | end_lat | end_lon | avg_speed_kmh | avg_moving_speed_kmh | max_speed_kmh |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| T005 | U001 | 2023-11-14 10:58:00 | 2023-11-14 11:23:00 | 24.82 | 14.56 | 0.33 | NULL | NULL | -1.259723 | 36.817942 | 35.2 | 35.67 | 54.0 |
| T006 | U001 | 2023-11-14 11:30:00 | 2023-11-14 11:34:00 | 3.42 | 1.37 | 0.17 | -1.258522 | 36.818655 | -1.256992 | 36.808082 | 24.04 | 25.29 | 38.0 |
| T007 | U001 | 2023-11-14 11:34:00 | 2023-11-14 11:36:00 | 2.32 | 0.72 | 0.5 | -1.256992 | 36.808082 | -1.257582 | 36.802980 | 18.62 | 23.74 | 32.0 |

Surrogate IDs (`R001`, `U001`, `D002`, `T005`–`T039`) are illustrative and match the earlier sections; Phase IV assigns the real sequence values.

### 11.3 Tables that receive no row from this record

| Table | Why no row |
|---|---|
| `ELECTRIC_DAILY_COSTS` | The unit's `powertrain_type` is `FUEL`, so the electric cost child does not apply. |
| `MAINTENANCE_EVENTS` | The source supplies only the daily `maintenance_kes` aggregate (`0.00`); it contains no individual maintenance events and those must not be invented or double counted. |
| `AUDIT_LOG` | It is populated by DML triggers when the load runs, not by CSV values. |

### 11.4 Five-minute demonstration sequence

1. Open `baseline-fuel-motorcycle-daily-data.csv` and locate `579236` on `2023-11-14`.
2. Show `579236` becoming `RIDER` `R001` and the (`R001`, `BASELINE`) pair becoming `RIDER_UNIT` `U001`.
3. Show the file name becoming the `COHORT` row (`BASELINE`, `BASELINE`, `FUEL`).
4. Show the date and five daily measures landing in `DAILY_OPERATIONS` `D002`.
5. Show the three fuel fields landing in `FUEL_DAILY_COSTS` `D002`.
6. Open the trip file, filter the same unit and `start_date`, and show the 35 trips becoming `TRIPS` `T005`–`T039` with date and time combined into timestamps.
7. State that `ELECTRIC_DAILY_COSTS`, `MAINTENANCE_EVENTS` and `AUDIT_LOG` correctly receive no row from this record, and why.
