# MotoTrack – Moto Taxi Trip, Fuel and Maintenance Cost Tracker

**Implementation:** Oracle Database 21c and PL/SQL in Oracle SQL Developer  
**Project type:** Individual database capstone  
**Dataset:** Nairobi Motorcycle Transit Comparison Dataset (2023)

## Important scope
This project is designed to be implemented inside Oracle using SQL and PL/SQL. SQL Developer/SQL*Plus is the user/developer interface. No PHP, Java, Python, React or external dashboard is included in this starter project.

Your course brief describes an innovation component as an interactive layer connected to the Oracle database. A SQL Developer/PLSQL menu or DBMS_OUTPUT interface may or may not satisfy that marking criterion. Confirm this interpretation with your lecturer before relying on it for the innovation marks.

## What is included
- Dataset ZIP and six original CSV files in `02_dataset/original/`.
- Six raw staging tables matching the CSV structures.
- Normalized operational tables for tracked units, trips and daily operations.
- Separate fuel and electric daily cost tables.
- PL/SQL package with procedures and functions.
- Trigger-based audit logging.
- SQL views, reports and a simple SQL Developer script menu.
- Proposed ERD and normalization worksheet for Phase II review.
- Test scripts and phase documentation templates.

## Dataset facts verified from the uploaded ZIP
- 126,067 trip rows across three trip CSV files.
- 2,718 daily summary rows across three daily CSV files.
- 119 distinct `user_id` values across the six CSV files.
- Daily data covers baseline fuel, transition control fuel and transition treatment electric groups.
- Trip-level data contains trip timing, distance, duration, idle time, GPS coordinates and speed metrics.
- Daily data contains revenue and maintenance costs, plus fuel costs for fuel motorcycles or battery-swap/charging measures for electric motorcycles.
- Financial values are in Kenyan Shillings (KES); times are UTC+3.
- Blank CSV cells represent missing values. Do not automatically treat missing costs or revenue as zero.
- The dataset is from Nairobi, Kenya, and is not Rwanda-specific.

The dataset README describes `user_id` as an identifier for each rider/motorcycle. IDs can occur in more than one study phase/cohort, so the database identifies a tracked-unit participation using source ID plus powertrain, cohort and phase. The dataset does not provide separate rider names and motorcycle registration details, so the database calls these records **tracked units** rather than inventing personal or motorcycle details.

## Requirements
- Oracle Database 21c (or compatible version supporting identity columns and `STANDARD_HASH`).
- Oracle SQL Developer.
- A database user with privileges to create tables, views, sequences/identity columns, procedures, functions, packages and triggers.

## Installation order
Open SQL Developer, connect to your project schema, open each `.sql` file and run it using **F5 (Run Script)** in this order:

1. `03_sql/01_schema/01_create_core_tables.sql`
2. `03_sql/02_staging/02_create_staging_tables.sql`
3. Import the six CSV files into their matching staging tables (instructions below).
4. `03_sql/03_data_loading/03_load_normalized_data.sql`
5. `03_sql/04_packages/04_pkg_mototrack_spec_body.sql`
6. `03_sql/05_triggers/05_create_audit_trigger.sql`
7. `03_sql/06_reports/06_create_views.sql`
8. Optionally run `03_sql/06_reports/10_mototrack_menu.sql` with F5.
9. Run tests in `03_sql/07_tests/`.

Do not run the table-creation scripts repeatedly on a schema where the tables already exist. If you need a clean restart, use a separate practice schema or carefully drop the project objects first.

## Import the CSV files with SQL Developer
1. Extract the ZIP file.
2. In SQL Developer, expand **Tables** under your project connection.
3. Right-click the matching staging table and choose **Import Data**.
4. Select the CSV file.
5. Confirm that the first row contains column headers.
6. Check that the column order and mapping match the staging table.
7. Finish the import.
8. Repeat for all six CSV files.
9. For the daily CSVs, map the source CSV column `date` to the staging table column `DATE_TXT` (the other fields should map by name).

CSV-to-staging table mapping:

| CSV file | Staging table |
|---|---|
| `baseline-fuel-motorcycle-daily-data.csv` | `STG_DAILY_FUEL_BASE` |
| `transition-control-fuel-motorcycle-daily-data.csv` | `STG_DAILY_FUEL_TRANS` |
| `transition-treatment-electric-motorcycle-daily-data.csv` | `STG_DAILY_ELECTRIC_TRANS` |
| `baseline-fuel-motorcycle-trip-data.csv` | `STG_TRIP_FUEL_BASE` |
| `transition-control-fuel-motorcycle-trip-data.csv` | `STG_TRIP_FUEL_TRANS` |
| `transition-treatment-electric-motorcycle-trip-data.csv` | `STG_TRIP_ELECTRIC_TRANS` |

All staging columns are VARCHAR2 so blank CSV values can be preserved safely. The loading script converts valid values and leaves blanks as NULL.

## Main database model
- `RIDER_UNITS`: anonymized source `user_id`, vehicle technology, study cohort and phase.
- `TRIPS`: trip-level records.
- `DAILY_OPERATIONS`: daily totals for distance, duration, idle time, revenue and maintenance.
- `FUEL_DAILY_COSTS`: fuel cost, unit price and litres for fuel units.
- `ELECTRIC_DAILY_COSTS`: battery-swap cost and charging kWh for electric units.
- `MAINTENANCE_EVENTS`: separately recorded maintenance events (not automatically added to imported daily totals, to avoid double counting).
- `AUDIT_LOG`: records insert/update/delete activity on selected business tables.

This model does not create separate `RIDERS` and `MOTORCYCLES` master tables because the source does not provide separate rider identity and motorcycle attributes. Those can be added if you collect valid supplementary data.

## Business calculations
- Daily profit = daily revenue − maintenance cost − energy cost.
- Operating cost per km = (maintenance cost + energy cost) / distance.
- Fuel efficiency = distance / litres, for records where litres are available.
- Electric energy measure = charging kWh and battery-swap cost, where available.

The profit and cost-per-km functions return NULL when required source values are missing or distance is zero. This avoids falsely reporting a profit from incomplete data.

## Important course-integrity note
The Phase I assignment explicitly prohibits generative AI from creating, modifying or completing its deliverables. The folder `01_documentation/business_process_PHASE_I_STUDENT_ONLY/` contains only a checklist and blank working template. You must independently research, draw, explain and export your own BPMN/UML diagram. Do not submit AI-generated Phase I content.

## Before submission
- Verify the topic is available and approved by your lecturer.
- Read and verify the Mendeley dataset licence and citation on its original page.
- Complete the research log with six sources you personally read; do not submit placeholders.
- Complete Phase I independently.
- Add your own screenshots, tests, ERD, data dictionary, proposal, presentation and explanations.
- Confirm with your lecturer whether a SQL Developer/PLSQL menu satisfies the innovation requirement.
