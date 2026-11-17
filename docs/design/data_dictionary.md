# MotoTrack Data Dictionary

**Project:** MotoTrack — Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL

This is a **logical** data dictionary for Phase II. It lists entities, columns, keys and rules, and deliberately leaves out Oracle data types and sizes; physical types are chosen in Phase III and implemented in Phase IV. The current load uses all three daily source CSVs: 2,718 rows across three study groups.

**Logical types used:** Identifier (surrogate key), Code (short business code), Text, Date, Numeric, Timestamp.

## 1. Entity overview

| Table | Grain | Purpose |
|---|---|---|
| `RIDERS` | One row per anonymised rider ID | Stores source rider identifiers once |
| `SOURCE_GROUP` | One row per study group | Lookup for phase, powertrain, control role and date range |
| `DAILY_OPERATIONS` | One row per rider, source group and date | Stores daily activity, revenue and group-specific costs |
| `MAINTENANCE_TYPE` | One row per maintenance category | Lookup for maintenance event categories |
| `MAINTENANCE_EVENTS` | One row per manually recorded maintenance event | Optional operational detail; not loaded from the source dataset |
| `AUDIT_LOG` | One row per daily-operation change | Stores trigger-generated change summaries |
| `STG_DAILY_BASELINE_FUEL` | One row per baseline-fuel CSV record | Raw text staging |
| `STG_DAILY_TRANSITION_FUEL` | One row per transition-control CSV record | Raw text staging |
| `STG_DAILY_TRANSITION_ELECTRIC` | One row per transition-electric CSV record | Raw text staging |

**Relationships (crow's-foot):** `SOURCE_GROUP` 1 : 0..* `DAILY_OPERATIONS`; `RIDERS` 1 : 0..* `DAILY_OPERATIONS`; `RIDERS` 1 : 0..* `MAINTENANCE_EVENTS`; `MAINTENANCE_TYPE` 1 : 0..* `MAINTENANCE_EVENTS`. `AUDIT_LOG` has no foreign key by design.

## 2. `RIDERS`

| Column | Logical type | Required | Key | Source / rule |
|---|---|---|---|---|
| `RIDER_ID` | Identifier | Yes | PK | Generated surrogate key |
| `RIDER_CODE` | Text | Yes | UK | Trimmed source `user_id` |
| `CREATED_AT` | Timestamp | Yes | — | Record creation time |

`RIDER_CODE` is unique. The source has 119 distinct rider IDs; a rider may have records in more than one study group.

## 3. `SOURCE_GROUP`

| Column | Logical type | Required | Key | Source / rule |
|---|---|---|---|---|
| `GROUP_CODE` | Code | Yes | PK | `BASELINE_FUEL`, `TRANSITION_CONTROL_FUEL`, or `TRANSITION_TREATMENT_ELECTRIC` |
| `GROUP_NAME` | Text | Yes | UK | Human-readable group name |
| `STUDY_PHASE` | Text | Yes | — | `Baseline` or `Transition` |
| `POWERTRAIN` | Text | Yes | — | `Fuel` or `Electric` |
| `CONTROL_ROLE` | Text | Yes | — | `Baseline`, `Control` or `Treatment` |
| `START_DATE` | Date | Yes | — | First operating date recorded for the group |
| `END_DATE` | Date | Yes | — | Last operating date recorded for the group |

Three rows are seeded before daily data is loaded: baseline fuel (13–26 Nov 2023), transition-control fuel and transition-treatment electric (10–21 Dec 2023). This table removes the transitive dependency `group_code → study_phase, powertrain, control_role, start_date, end_date`.

## 4. `DAILY_OPERATIONS`

| Column | Logical type | Required | Key | Source / rule |
|---|---|---|---|---|
| `DAILY_ID` | Identifier | Yes | PK | Generated surrogate key |
| `RIDER_ID` | Identifier | Yes | FK | `RIDERS.RIDER_ID` |
| `SOURCE_GROUP` | Code | Yes | FK, UK part | `SOURCE_GROUP.GROUP_CODE`; assigned from the staging table |
| `OPERATING_DATE` | Date | Yes | UK part | Source `date`, parsed as `YYYY-MM-DD` |
| `DISTANCE_KM` | Numeric | No | — | Daily distance, km |
| `DURATION_MIN` | Numeric | No | — | Daily duration, minutes |
| `IDLE_TIME_MIN` | Numeric | No | — | Daily momentary-stop time, minutes |
| `REVENUE_KES` | Numeric | No | — | Daily revenue; blank stays `NULL` |
| `MAINTENANCE_KES` | Numeric | No | — | Daily maintenance total; blank stays `NULL` |
| `FUEL_COST_KES` | Numeric | No | — | Fuel groups only |
| `FUEL_UNIT_COST_KES_PER_L` | Numeric | No | — | Fuel groups only, KES/litre |
| `FUEL_AMOUNT_L` | Numeric | No | — | Fuel groups only, litres |
| `BATTERY_SWAP_COST_KES` | Numeric | No | — | Electric group only |
| `KWH_CHARGING` | Numeric | No | — | Electric group only, kWh |
| `CREATED_AT` | Timestamp | Yes | — | Record creation time |

**Keys and constraints**

- Unique `(RIDER_ID, SOURCE_GROUP, OPERATING_DATE)`.
- `SOURCE_GROUP` must exist in `SOURCE_GROUP`.
- Fuel groups cannot contain electric-only cost/charging fields; the electric group cannot contain fuel-only fields.
- Numeric measures must be non-negative when present.

**Derived measures**

`V_DAILY_PERFORMANCE` calculates total cost and profit. Profit is `NULL` unless revenue, maintenance, and the applicable energy cost (fuel or battery swap) are all present. Profit-per-kilometre is also `NULL` when the required financial inputs are incomplete or distance is zero.

`PKG_MOTOTRACK.CALCULATE_PROFIT` and `GET_TOTAL_PROFIT` sum profit only across financially complete days and return `NULL` when there are no complete days to sum.

## 5. `MAINTENANCE_TYPE`

| Column | Logical type | Required | Key | Source / rule |
|---|---|---|---|---|
| `TYPE_CODE` | Code | Yes | PK | Short category code (for example `OIL`, `TYRE`, `BRAKE`, `ENGINE`, `OTHER`) |
| `TYPE_NAME` | Text | Yes | UK | Category name |
| `DESCRIPTION` | Text | No | — | Optional detail |

Reference list for maintenance events. This table removes the transitive dependency `type_code → type_name`.

## 6. `MAINTENANCE_EVENTS`

| Column | Logical type | Required | Key | Source / rule |
|---|---|---|---|---|
| `MAINTENANCE_EVENT_ID` | Identifier | Yes | PK | Generated surrogate key |
| `RIDER_ID` | Identifier | Yes | FK | `RIDERS.RIDER_ID` |
| `MAINTENANCE_DATE` | Date | Yes | — | Manually recorded event date |
| `MAINTENANCE_TYPE` | Code | Yes | FK | `MAINTENANCE_TYPE.TYPE_CODE` |
| `DESCRIPTION` | Text | No | — | Free text |
| `AMOUNT_KES` | Numeric | Yes | — | Non-negative event amount |
| `ODOMETER_KM` | Numeric | No | — | Non-negative when present |
| `RECORDED_AT` | Timestamp | Yes | — | Record creation time |

This optional table is for separately entered events. The source dataset has only a daily maintenance aggregate; do not copy it here or add it twice to profit.

## 7. `AUDIT_LOG`

| Column | Logical type | Required | Key | Source / rule |
|---|---|---|---|---|
| `AUDIT_ID` | Identifier | Yes | PK | Generated surrogate key |
| `TABLE_NAME` | Text | Yes | — | Audited table |
| `RECORD_KEY` | Text | No | — | Rider, source group and date |
| `ACTION_TYPE` | Code | Yes | — | `INSERT`, `UPDATE` or `DELETE` |
| `CHANGED_BY` | Text | Yes | — | Session user |
| `CHANGED_AT` | Timestamp | Yes | — | Change time |
| `OLD_SUMMARY` | Text | No | — | Selected values before change |
| `NEW_SUMMARY` | Text | No | — | Selected values after change |

Populated by `TRG_DAILY_OPERATIONS_AUDIT`. No foreign key by design.

## 8. Staging tables

All staging columns are text so blank cells can be converted to `NULL` without being mistaken for zero. In SQL Developer, import each CSV into its matching table; map source `user_id` to `RIDER_CODE` and source `date` to `OPERATING_DATE`.

| Staging table | Columns after rider/date mapping |
|---|---|
| `STG_DAILY_BASELINE_FUEL` | `RIDER_CODE`, `OPERATING_DATE`, `DISTANCE_KM`, `DURATION_MIN`, `IDLE_TIME_MIN`, `REVENUE_KES`, `MAINTENANCE_KES`, `FUEL_COST_KES`, `FUEL_UNIT_COST_KES_PER_L`, `FUEL_AMOUNT_L` |
| `STG_DAILY_TRANSITION_FUEL` | `RIDER_CODE`, `OPERATING_DATE`, `DISTANCE_KM`, `DURATION_MIN`, `IDLE_TIME_MIN`, `REVENUE_KES`, `MAINTENANCE_KES`, `FUEL_COST_KES`, `FUEL_UNIT_COST_KES_PER_L`, `FUEL_AMOUNT_L` |
| `STG_DAILY_TRANSITION_ELECTRIC` | `RIDER_CODE`, `OPERATING_DATE`, `DISTANCE_KM`, `DURATION_MIN`, `IDLE_TIME_MIN`, `REVENUE_KES`, `MAINTENANCE_KES`, `BATTERY_SWAP_COST_KES`, `KWH_CHARGING` |

## 9. Load rules

| Rule | Implementation |
|---|---|
| Seed study groups | Insert the three `SOURCE_GROUP` rows before daily loading |
| Assign source group | Loader maps each staging table to its fixed group code |
| Trim text and convert blanks to `NULL` | Empty strings become `NULL` |
| Parse source dates | Convert `YYYY-MM-DD` text to a date |
| Convert measures | Convert numeric text to numbers |
| Deduplicate riders | Merge on `RIDER_CODE` |
| Upsert daily rows | Merge on `(RIDER_ID, SOURCE_GROUP, OPERATING_DATE)` |
| Re-runnable load | Repeated runs update matching records rather than duplicate them |

## 10. Scope and assumptions

1. The fact grain is one rider/group/day; individual trips are not loaded.
2. The original daily files do not contain `trip_count`; no count is inferred from trip data.
3. Missing source values remain `NULL`; profit requires complete revenue and applicable cost inputs.
4. The same rider can appear in multiple groups; `SOURCE_GROUP` is part of the daily unique key.
5. Revenue and maintenance are daily values, not per-trip fares or individual events.
6. The optional maintenance-event table is separate from the source daily maintenance aggregate.
