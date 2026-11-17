# MotoTrack Normalization Worksheet

**Project:** MotoTrack — Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL

**Working data:** the three original daily CSVs, 2,718 rows across baseline fuel, transition-control fuel and transition-treatment electric. The fact grain is one rider, source group and calendar date. Individual trip data is outside the project scope. All sample rows below are real source rows.

## 1. Unnormalised form (UNF)

The source is three flat CSVs with mostly common daily measures and some powertrain-specific measures. Each row has atomic values. For modelling, a `source_group` is assigned from the file name.

**Unified relation `MOTOTRACK_DAILY_UNF`:**

`(source_group, user_id, operating_date, distance_km, duration_min, idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes, kwh_charging)`

| source_group | user_id | operating_date | distance_km | duration_min | idle_time_min | revenue_kes | maintenance_kes | fuel_cost_kes | fuel_amount_l | battery_swap_cost_kes | kwh_charging |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| BASELINE_FUEL | 579236 | 2023-11-13 | 129.44 | 267.59 | 17.78 | NULL | NULL | NULL | NULL | NULL | NULL |
| BASELINE_FUEL | 579236 | 2023-11-14 | 113.02 | 232.36 | 10.87 | 1400.00 | 0.00 | 300.00 | 1.40 | NULL | NULL |
| BASELINE_FUEL | 579236 | 2023-11-15 | 95.65 | 197.29 | 10.73 | 930.00 | 0.00 | 350.00 | 1.63 | NULL | NULL |
| TRANSITION_TREATMENT_ELECTRIC | 579236 | 2023-12-11 | 119.74 | 245.78 | 11.64 | 870.00 | 0.00 | NULL | NULL | 176.00 | NULL |
| TRANSITION_TREATMENT_ELECTRIC | 579236 | 2023-12-12 | 126.96 | 268.68 | 15.89 | 1750.00 | 100.00 | NULL | NULL | 370.00 | NULL |

Candidate key: `(source_group, user_id, operating_date)`. A rider may appear in multiple groups; therefore rider/date alone is not a safe key. The source daily files do not contain a trip count.

## 2. First Normal Form (1NF)

1NF requires atomic values, no repeating groups and a key. Every CSV cell is already atomic. Blank measures are treated as `NULL`.

The two powertrain-specific column sets form two **optional repeating groups** — `fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l` for fuel rows and `battery_swap_cost_kes, kwh_charging` for electric rows. Because each row belongs to exactly one powertrain and the two groups never both apply, they are kept as nullable attributes of the daily fact instead of a separate child table. Dependency removed: **the repeating group is flattened into nullable, mutually exclusive attributes.**

**Daily fact at 1NF:**

`(source_group, user_id, operating_date, distance_km, duration_min, idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes, kwh_charging)`

| source_group | user_id | operating_date | distance_km | revenue_kes | maintenance_kes | fuel_cost_kes | fuel_amount_l | battery_swap_cost_kes | kwh_charging |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| BASELINE_FUEL | 579236 | 2023-11-13 | 129.44 | NULL | NULL | NULL | NULL | NULL | NULL |
| BASELINE_FUEL | 579236 | 2023-11-14 | 113.02 | 1400.00 | 0.00 | 300.00 | 1.40 | NULL | NULL |
| BASELINE_FUEL | 579236 | 2023-11-15 | 95.65 | 930.00 | 0.00 | 350.00 | 1.63 | NULL | NULL |
| TRANSITION_TREATMENT_ELECTRIC | 579236 | 2023-12-11 | 119.74 | 870.00 | 0.00 | NULL | NULL | 176.00 | NULL |
| TRANSITION_TREATMENT_ELECTRIC | 579236 | 2023-12-12 | 126.96 | 1750.00 | 100.00 | NULL | NULL | 370.00 | NULL |

The key remains `(source_group, user_id, operating_date)`. No `TRIPS` table is added because only daily summary files are loaded.

## 3. Second Normal Form (2NF)

2NF removes partial dependencies on part of a composite key. Rider identity is determined by `user_id` alone, not by the full rider/group/date key. Dependency removed: **partial dependency `user_id → rider_code`**, resolved by storing each rider once in `RIDERS`.

**`RIDERS`:**

| rider_id | rider_code |
|---:|---|
| 1 | 579236 |
| 2 | 627618 |
| 3 | 627621 |
| 4 | 627627 |
| 5 | 627641 |

**Daily facts after the split:**

`DAILY_OPERATIONS(daily_id, rider_id, source_group, operating_date, distance_km, duration_min, idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes, kwh_charging)`

| daily_id | rider_id | source_group | operating_date | distance_km | revenue_kes | fuel_cost_kes | battery_swap_cost_kes |
|---:|---:|---|---|---:|---:|---:|---:|
| 1 | 1 | BASELINE_FUEL | 2023-11-13 | 129.44 | NULL | NULL | NULL |
| 2 | 1 | BASELINE_FUEL | 2023-11-14 | 113.02 | 1400.00 | 300.00 | NULL |
| 3 | 1 | BASELINE_FUEL | 2023-11-15 | 95.65 | 930.00 | 350.00 | NULL |
| 4 | 1 | TRANSITION_TREATMENT_ELECTRIC | 2023-12-11 | 119.74 | 870.00 | NULL | 176.00 |
| 5 | 1 | TRANSITION_TREATMENT_ELECTRIC | 2023-12-12 | 126.96 | 1750.00 | NULL | 370.00 |

The daily unique key is `(rider_id, source_group, operating_date)`. All activity and cost measures depend on that complete key.

## 4. Third Normal Form (3NF)

3NF removes transitive dependencies and keeps independently repeating facts separate. Two non-key attributes were each determined by another non-key attribute, so they were split into lookup tables.

1. **Study-group attributes.** Dependency removed: **transitive dependency `source_group → study_phase, powertrain, control_role, start_date, end_date`**. These attributes describe the group, not the daily row, so they move to `SOURCE_GROUP`.

   **`SOURCE_GROUP`:**

   | group_code | group_name | study_phase | powertrain | control_role | start_date | end_date |
   |---|---|---|---|---|---|---|
   | BASELINE_FUEL | Baseline fuel | Baseline | Fuel | Baseline | 2023-11-13 | 2023-11-26 |
   | TRANSITION_CONTROL_FUEL | Transition control fuel | Transition | Fuel | Control | 2023-12-10 | 2023-12-21 |
   | TRANSITION_TREATMENT_ELECTRIC | Transition treatment electric | Transition | Electric | Treatment | 2023-12-10 | 2023-12-21 |

2. **Maintenance categories.** Dependency removed: **transitive dependency `maintenance_type → type_name`**. Event categories move to `MAINTENANCE_TYPE`.

   **`MAINTENANCE_TYPE`:**

   | type_code | type_name | description |
   |---|---|---|
   | OIL | Oil and lubricant change | Engine oil and filter |
   | TYRE | Tyre repair or replacement | Puncture or worn tyre |
   | BRAKE | Brake service | Pads, discs or fluid |
   | ENGINE | Engine service | Tuning or repair |
   | OTHER | Other maintenance | Any other event |

3. **Rider identity** stays in `RIDERS`; daily facts reference `rider_id`.
4. **Calculated values:** total cost, profit and per-kilometre measures are calculated in views/functions, not stored in daily rows.
5. **Maintenance events:** source `maintenance_kes` is a daily aggregate. Optional named maintenance events are stored separately in `MAINTENANCE_EVENTS` (referencing `RIDERS` and `MAINTENANCE_TYPE`) and are never copied from the daily aggregate.

**Final tables**

| Table | Form | Key | Notes |
|---|---|---|---|
| `RIDERS` | 3NF | `rider_id`; UK `rider_code` | One row per anonymised source rider |
| `SOURCE_GROUP` | 3NF | `group_code` | Study-group lookup (phase, powertrain, control role, date range) |
| `DAILY_OPERATIONS` | 3NF | `daily_id`; UK `(rider_id, source_group, operating_date)` | One daily fact per rider/group/date |
| `MAINTENANCE_TYPE` | 3NF | `type_code` | Maintenance-category lookup |
| `MAINTENANCE_EVENTS` | 3NF | `maintenance_event_id` | Optional manually entered event detail |
| `AUDIT_LOG` | 3NF | `audit_id` | Daily-operation audit trail (no FK by design) |
| Three `STG_DAILY_*` tables | Raw staging | None | Text staging of each source CSV |

Five related tables carry foreign keys (`RIDERS`, `SOURCE_GROUP`, `DAILY_OPERATIONS`, `MAINTENANCE_TYPE`, `MAINTENANCE_EVENTS`); `AUDIT_LOG` is a standalone governance table and the three staging tables are load-only.

## 5. Relationships and sample trace

Crow's-foot notation (as drawn in `erd.svg`/`erd.png`):

- `SOURCE_GROUP` **1** : **0..\*** `DAILY_OPERATIONS`
- `RIDERS` **1** : **0..\*** `DAILY_OPERATIONS`
- `RIDERS` **1** : **0..\*** `MAINTENANCE_EVENTS`
- `MAINTENANCE_TYPE` **1** : **0..\*** `MAINTENANCE_EVENTS`
- `AUDIT_LOG` is trigger-written with no foreign key. No trip-level or many-to-many table is required.

For source row `579236`, `2023-11-14`, `BASELINE_FUEL`:

| Source value | Target |
|---|---|
| `user_id = 579236` | `RIDERS.RIDER_CODE` → `DAILY_OPERATIONS.RIDER_ID` |
| Source file = baseline fuel | `SOURCE_GROUP.GROUP_CODE` → `DAILY_OPERATIONS.SOURCE_GROUP = 'BASELINE_FUEL'` |
| `date = 2023-11-14` | `DAILY_OPERATIONS.OPERATING_DATE` |
| `distance_km = 113.02`, `duration_min = 232.36`, `idle_time_min = 10.87` | Daily activity measures |
| `revenue_kes = 1400.00`, `maintenance_kes = 0.00` | Daily financial measures |
| `fuel_cost_kes = 300.00`, `fuel_unit_cost_kes_per_l = 214.30`, `fuel_amount_l = 1.40` | Fuel cost measures |
| `battery_swap_cost_kes = NULL`, `kwh_charging = NULL` | Not applicable to a fuel row |
| Derived profit | `1400.00 − 0.00 − 300.00 = 1100.00 KES` |

The daily maintenance amount remains only in `DAILY_OPERATIONS`; no event row is inferred from it.

## 6. Assumptions and limitations

1. Source group is part of the fact key because the same rider may participate in multiple groups.
2. Source daily files do not provide individual trips, per-trip fares, or a trip count.
3. Financial blanks remain `NULL`. Profit is not calculated for a row unless revenue, maintenance and the applicable energy cost are all known.
4. Daily maintenance is an aggregate; additional maintenance events must be entered independently and use a `MAINTENANCE_TYPE` code.
5. The source is from Nairobi, Kenya, and rider IDs are anonymised.
