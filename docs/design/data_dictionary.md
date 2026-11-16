# MotoTrack Data Dictionary

**Project:** MotoTrack — Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL

This dictionary describes the schema in `03_sql/01_schema/01_create_core_tables.sql` and the staging tables in `03_sql/02_staging/02_create_staging_tables.sql`. The current load uses all three daily source CSVs: 2,718 rows across three study groups.

## 1. Entity overview

| Table | Grain | Purpose |
|---|---|---|
| `RIDERS` | One row per anonymised rider ID | Stores source rider identifiers once |
| `DAILY_OPERATIONS` | One row per rider, source group and date | Stores daily activity, revenue and group-specific costs |
| `MAINTENANCE_EVENTS` | One row per manually recorded maintenance event | Optional operational detail; not loaded from the source dataset |
| `AUDIT_LOG` | One row per daily-operation change | Stores trigger-generated change summaries |
| `STG_DAILY_BASELINE_FUEL` | One row per baseline-fuel CSV record | Raw text staging |
| `STG_DAILY_TRANSITION_FUEL` | One row per transition-control CSV record | Raw text staging |
| `STG_DAILY_TRANSITION_ELECTRIC` | One row per transition-electric CSV record | Raw text staging |

Relationships: `RIDERS` 1 : 0..* `DAILY_OPERATIONS`; `RIDERS` 1 : 0..* `MAINTENANCE_EVENTS`. `AUDIT_LOG` has no foreign key by design.

## 2. `RIDERS`

| Column | Type | Required | Key | Source / rule |
|---|---|---|---|---|
| `RIDER_ID` | `NUMBER` | Yes | PK | Generated identity |
| `RIDER_CODE` | `VARCHAR2(50)` | Yes | UK | Trimmed source `user_id` |
| `CREATED_AT` | `TIMESTAMP` | Yes | — | `SYSTIMESTAMP` default |

`RIDER_CODE` is unique. The source has 119 distinct rider IDs; a rider may have records in more than one study group.

## 3. `DAILY_OPERATIONS`

| Column | Type | Required | Key | Source / rule |
|---|---|---|---|---|
| `DAILY_ID` | `NUMBER` | Yes | PK | Generated identity |
| `RIDER_ID` | `NUMBER` | Yes | FK | `RIDERS.RIDER_ID` |
| `SOURCE_GROUP` | `VARCHAR2(40)` | Yes | UK part | Assigned from the staging table: `BASELINE_FUEL`, `TRANSITION_CONTROL_FUEL`, or `TRANSITION_TREATMENT_ELECTRIC` |
| `OPERATING_DATE` | `DATE` | Yes | UK part | Source `date`, parsed as `YYYY-MM-DD` |
| `DISTANCE_KM` | `NUMBER(12,3)` | No | — | Daily distance, km |
| `DURATION_MIN` | `NUMBER(10,2)` | No | — | Daily duration, minutes |
| `IDLE_TIME_MIN` | `NUMBER(10,2)` | No | — | Daily momentary-stop time, minutes |
| `REVENUE_KES` | `NUMBER(14,2)` | No | — | Daily revenue; blank stays `NULL` |
| `MAINTENANCE_KES` | `NUMBER(14,2)` | No | — | Daily maintenance total; blank stays `NULL` |
| `FUEL_COST_KES` | `NUMBER(14,2)` | No | — | Fuel groups only |
| `FUEL_UNIT_COST_KES_PER_L` | `NUMBER(10,2)` | No | — | Fuel groups only, KES/litre |
| `FUEL_AMOUNT_L` | `NUMBER(12,3)` | No | — | Fuel groups only, litres |
| `BATTERY_SWAP_COST_KES` | `NUMBER(14,2)` | No | — | Electric group only |
| `KWH_CHARGING` | `NUMBER(12,3)` | No | — | Electric group only, kWh |
| `CREATED_AT` | `TIMESTAMP` | Yes | — | `SYSTIMESTAMP` default |

**Keys and constraints**

- Unique `(RIDER_ID, SOURCE_GROUP, OPERATING_DATE)`.
- `SOURCE_GROUP` must be one of the three source groups above.
- Fuel groups cannot contain electric-only cost/charging fields; the electric group cannot contain fuel-only fields.
- Numeric measures must be non-negative when present.

**Derived measures**

`V_DAILY_PERFORMANCE` calculates total cost and profit. Profit is `NULL` unless revenue, maintenance, and the applicable energy cost (fuel or battery swap) are all present. Profit-per-kilometre is also `NULL` when the required financial inputs are incomplete or distance is zero.

`PKG_MOTOTRACK.CALCULATE_PROFIT` and `GET_TOTAL_PROFIT` sum profit only across financially complete days and return `NULL` when there are no complete days to sum.

## 4. `MAINTENANCE_EVENTS`

| Column | Type | Required | Key | Source / rule |
|---|---|---|---|---|
| `MAINTENANCE_EVENT_ID` | `NUMBER` | Yes | PK | Generated identity |
| `RIDER_ID` | `NUMBER` | Yes | FK | `RIDERS.RIDER_ID` |
| `MAINTENANCE_DATE` | `DATE` | Yes | — | Manually recorded event date |
| `MAINTENANCE_TYPE` | `VARCHAR2(60)` | Yes | — | Event category |
| `DESCRIPTION` | `VARCHAR2(500)` | No | — | Free text |
| `AMOUNT_KES` | `NUMBER(14,2)` | Yes | — | Non-negative event amount |
| `ODOMETER_KM` | `NUMBER(12,3)` | No | — | Non-negative when present |
| `RECORDED_AT` | `TIMESTAMP` | Yes | — | `SYSTIMESTAMP` default |

This optional table is for separately entered events. The source dataset has only a daily maintenance aggregate; do not copy it here or add it twice to profit.

## 5. `AUDIT_LOG`

| Column | Type | Required | Key | Source / rule |
|---|---|---|---|---|
| `AUDIT_ID` | `NUMBER` | Yes | PK | Generated identity |
| `TABLE_NAME` | `VARCHAR2(30)` | Yes | — | Audited table |
| `RECORD_KEY` | `VARCHAR2(150)` | No | — | Rider, source group and date |
| `ACTION_TYPE` | `VARCHAR2(10)` | Yes | — | `INSERT`, `UPDATE` or `DELETE` |
| `CHANGED_BY` | `VARCHAR2(128)` | Yes | — | Session user |
| `CHANGED_AT` | `TIMESTAMP` | Yes | — | `SYSTIMESTAMP` default |
| `OLD_SUMMARY` | `VARCHAR2(1000)` | No | — | Selected values before change |
| `NEW_SUMMARY` | `VARCHAR2(1000)` | No | — | Selected values after change |

Populated by `TRG_DAILY_OPERATIONS_AUDIT`.

## 6. Staging tables

All staging columns are `VARCHAR2` so blank cells can be converted to `NULL` without being mistaken for zero. In SQL Developer, import each CSV into its matching table; map source `user_id` to `RIDER_CODE` and source `date` to `OPERATING_DATE`.

| Staging table | Columns after rider/date mapping |
|---|---|
| `STG_DAILY_BASELINE_FUEL` | `RIDER_CODE`, `OPERATING_DATE`, `DISTANCE_KM`, `DURATION_MIN`, `IDLE_TIME_MIN`, `REVENUE_KES`, `MAINTENANCE_KES`, `FUEL_COST_KES`, `FUEL_UNIT_COST_KES_PER_L`, `FUEL_AMOUNT_L` |
| `STG_DAILY_TRANSITION_FUEL` | `RIDER_CODE`, `OPERATING_DATE`, `DISTANCE_KM`, `DURATION_MIN`, `IDLE_TIME_MIN`, `REVENUE_KES`, `MAINTENANCE_KES`, `FUEL_COST_KES`, `FUEL_UNIT_COST_KES_PER_L`, `FUEL_AMOUNT_L` |
| `STG_DAILY_TRANSITION_ELECTRIC` | `RIDER_CODE`, `OPERATING_DATE`, `DISTANCE_KM`, `DURATION_MIN`, `IDLE_TIME_MIN`, `REVENUE_KES`, `MAINTENANCE_KES`, `BATTERY_SWAP_COST_KES`, `KWH_CHARGING` |

## 7. Load rules

| Rule | Implementation |
|---|---|
| Assign source group | Loader maps each staging table to its fixed group code |
| Trim text and convert blanks to `NULL` | `NULLIF(TRIM(column), '')` |
| Parse source dates | `TO_DATE(..., 'YYYY-MM-DD')` |
| Convert measures | `TO_NUMBER(...)` |
| Deduplicate riders | `MERGE` on `RIDER_CODE` |
| Upsert daily rows | `MERGE` on `(RIDER_ID, SOURCE_GROUP, OPERATING_DATE)` |
| Re-runnable load | Repeated runs update matching records rather than duplicate them |

## 8. Scope and assumptions

1. The fact grain is one rider/group/day; individual trips are not loaded.
2. The original daily files do not contain `trip_count`; no count is inferred from trip data.
3. Missing source values remain `NULL`; profit requires complete revenue and applicable cost inputs.
4. The same rider can appear in multiple groups; `SOURCE_GROUP` is part of the daily unique key.
5. Revenue and maintenance are daily values, not per-trip fares or individual events.
6. The optional maintenance-event table is separate from the source daily maintenance aggregate.
