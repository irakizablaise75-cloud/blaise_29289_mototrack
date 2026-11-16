# MotoTrack Normalization Worksheet

**Project:** MotoTrack — Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL

**Working data:** the three original daily CSVs, 2,718 rows across baseline fuel, transition-control fuel and transition-treatment electric. The fact grain is one rider, source group and calendar date. Individual trip data is outside the project scope.

## 1. Unnormalised form (UNF)

The source is three flat CSVs with mostly common daily measures and some powertrain-specific measures. Each row has atomic values. For modelling, a `source_group` is assigned from the file name.

**Unified relation `MOTOTRACK_DAILY_UNF`:**

`(source_group, user_id, operating_date, distance_km, duration_min, idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes, kwh_charging)`

| source_group | user_id | operating_date | distance_km | duration_min | revenue_kes | maintenance_kes | fuel_cost_kes | battery_swap_cost_kes |
|---|---:|---|---:|---:|---:|---:|---:|---:|
| BASELINE_FUEL | 579236 | 2023-11-14 | 113.02 | 232.36 | 1400.00 | 0.00 | 300.00 | NULL |
| TRANSITION_TREATMENT_ELECTRIC | 579236 | 2023-12-11 | 119.74 | 245.78 | 870.00 | 0.00 | NULL | 176.00 |

Candidate key: `(source_group, user_id, operating_date)`. A rider may appear in multiple groups; therefore rider/date alone is not a safe key. The source daily files do not contain a trip count.

## 2. First Normal Form (1NF)

1NF requires atomic values, no repeating groups and a key. The CSV cells are atomic. Blank measures are treated as `NULL`; fuel-specific and electric-specific fields are nullable and only populated for their applicable group.

**Daily fact at 1NF:**

`(source_group, user_id, operating_date, distance_km, duration_min, idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes, kwh_charging)`

The key is `(source_group, user_id, operating_date)`. No `TRIPS` table is added because only daily summary files are loaded.

## 3. Second Normal Form (2NF)

2NF removes partial dependencies on part of a composite key. Rider identity is determined by `user_id`, not by the full rider/group/date key, so rider codes are stored once in `RIDERS`.

**`RIDERS`:**

| rider_id | rider_code |
|---:|---|
| 1 | 579236 |

**Daily facts after the split:**

`DAILY_OPERATIONS(daily_id, rider_id, source_group, operating_date, distance_km, duration_min, idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes, fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes, kwh_charging)`

The daily unique key is `(rider_id, source_group, operating_date)`. All activity and cost measures depend on that complete key.

## 4. Third Normal Form (3NF)

3NF removes transitive dependencies and keeps independently repeating facts separate.

1. **Rider identity:** `rider_code` is held in `RIDERS`; daily facts reference `rider_id`.
2. **Calculated values:** total cost, profit and per-kilometre measures are calculated in views/functions, not stored in daily rows.
3. **Maintenance events:** source `maintenance_kes` is a daily aggregate. Optional named maintenance events are stored separately in `MAINTENANCE_EVENTS` and are not copied from the daily aggregate.
4. **Group-specific measures:** the single daily fact retains fuel fields or electric fields according to `source_group`; fields for the other powertrain remain `NULL`. Three group codes are constrained in the table rather than duplicated in another lookup table for this small project.

**Final tables**

| Table | Form | Key | Notes |
|---|---|---|---|
| `RIDERS` | 3NF | `rider_id`; UK `rider_code` | One row per anonymised source rider |
| `DAILY_OPERATIONS` | 3NF | `daily_id`; UK `(rider_id, source_group, operating_date)` | One daily fact per rider/group/date |
| `MAINTENANCE_EVENTS` | 3NF | `maintenance_event_id` | Optional manually entered event detail |
| `AUDIT_LOG` | 3NF | `audit_id` | Daily-operation audit trail |
| Three `STG_DAILY_*` tables | Raw staging | None | Text staging of each source CSV |

## 5. Relationships and sample trace

`RIDERS` 1 : 0..* `DAILY_OPERATIONS`; `RIDERS` 1 : 0..* `MAINTENANCE_EVENTS`. No trip-level or many-to-many table is required.

For source row `579236`, `2023-11-14`, `BASELINE_FUEL`:

| Source value | Target |
|---|---|
| `user_id = 579236` | `RIDERS.RIDER_CODE` |
| Source file = baseline fuel | `DAILY_OPERATIONS.SOURCE_GROUP = 'BASELINE_FUEL'` |
| `date = 2023-11-14` | `DAILY_OPERATIONS.OPERATING_DATE` |
| `distance_km = 113.02`, `duration_min = 232.36` | Daily activity measures |
| `revenue_kes = 1400.00`, `maintenance_kes = 0.00` | Daily financial measures |
| `fuel_cost_kes = 300.00` | Fuel cost measure |
| `battery_swap_cost_kes = NULL` | Not applicable to a fuel row |
| Derived profit | `1400.00 - 0.00 - 300.00 = 1100.00 KES` |

The daily maintenance amount remains only in `DAILY_OPERATIONS`; no event row is inferred from it.

## 6. Assumptions and limitations

1. Source group is part of the fact key because the same rider may participate in multiple groups.
2. Source daily files do not provide individual trips, per-trip fares, or a trip count.
3. Financial blanks remain `NULL`. Profit is not calculated for a row unless revenue, maintenance and the applicable energy cost are all known.
4. Daily maintenance is an aggregate; additional maintenance events must be entered independently.
5. The source is from Nairobi, Kenya, and rider IDs are anonymised.
