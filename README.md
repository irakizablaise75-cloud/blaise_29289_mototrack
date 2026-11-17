# MotoTrack: Motorcycle Taxi Daily Cost and Profit Tracker

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)  
**Academic year:** 2026–2027

## Problem Statement

Motorcycle taxi operators often record daily income, fuel costs, and maintenance expenses in separate places, making it difficult to determine daily profitability and compare operating performance. In many cases, the information is not centralized, which limits the ability to monitor revenue, identify unusual expenses, and evaluate the financial performance of each rider or day. MotoTrack addresses this problem by providing a structured database system that stores daily ride and expense information in a clear, organized manner.

## Objectives

The main objective of this project is to design and implement a database system that helps motorcycle taxi operators record daily income, fuel costs, and maintenance expenses.

The specific objectives are to:

1. Store rider and daily operation information in a structured relational database.
2. Keep daily measures separate from event-level maintenance records to improve data quality.
3. Calculate total income, total expenses, and daily profit for each rider and date.
4. Support queries and reports that summarize operational performance.
5. Use SQL and PL/SQL to enforce business rules and generate useful financial outputs.

## Proposed Solution

MotoTrack is implemented as an Oracle database project using SQL and PL/SQL. The system stores rider information, daily operating records, and maintenance events in a normalized relational structure. SQL views analyze daily activity and costs, while PL/SQL packages and functions calculate profit and summarize performance. A trigger writes an audit trail of changes to daily records.

## Data Source

The project uses the daily summary files from a public Mendeley Data dataset:

*Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)*

- DOI: `10.17632/nv3rkn24zv.1`
- URL: https://doi.org/10.17632/nv3rkn24zv.1
- Licence: CC BY 4.0

The working input is the three original daily CSVs stored in `data/raw/daily_data/`: **2,718 rider-day records across the baseline, transition-control, and transition-electric groups**. The project does not load trip-level CSVs. The daily files include distance, duration, idle time, daily revenue and maintenance, plus fuel or electric energy costs where applicable. See `data/dataset_card.md` for counts, field mappings and NULL handling.

## Database Tables

- `RIDERS` — one row per anonymised rider (`rider_code` unique)
- `SOURCE_GROUP` — study-group lookup (phase, powertrain, control role, date range)
- `DAILY_OPERATIONS` — one row per rider, source group and day (daily activity, revenue and fuel/electric/maintenance measures)
- `MAINTENANCE_TYPE` — maintenance-category lookup
- `MAINTENANCE_EVENTS` — optional event-level maintenance records
- `AUDIT_LOG` — changes captured by the audit trigger
- `STG_DAILY_BASELINE_FUEL`, `STG_DAILY_TRANSITION_FUEL`, `STG_DAILY_TRANSITION_ELECTRIC` — staging tables for the three source CSVs

## PL/SQL Features

- Package `PKG_MOTOTRACK` with procedures, functions, a cursor, a record type, custom exceptions, and error handling
- Function `calculate_profit` and `get_total_profit`
- Audit trigger `TRG_DAILY_OPERATIONS_AUDIT`
- SQL views `V_DAILY_PERFORMANCE`, `V_RIDER_SUMMARY`, `V_DAILY_TOTALS`, `V_MAINTENANCE_SUMMARY`
- Validation and demonstration queries under `03_sql/07_tests/`

## Planned Oracle Environment Setup (Phase III)

In Phase III, run `database/setup/01_create_pdb.sql` through `05_verify.sql` in order using SQL*Plus or SQL Developer's script runner. The scripts expect Oracle Managed Files to be configured with `DB_CREATE_FILE_DEST`; run them as `SYSDBA` where indicated. Passwords are requested interactively and are not stored in the scripts. `04_archive_log.sql` switches to `CDB$ROOT`, reports the archive mode, and documents the required restart commands if archiving must be enabled. After setup, connect as `MOTOTRACK` and run the project scripts under `03_sql/` in order.

## Planned Daily Data Load (Phase IV)

In Phase IV, use a clean project schema. Run the scripts in numbered order: create the core tables, create the three staging tables, import each CSV from `data/raw/daily_data/` into its matching staging table, then run the daily load script. In SQL Developer, map source `user_id` to `rider_code` and `date` to `operating_date`. After loading, create the package, trigger, and views, then run the validation queries. The project uses only these daily source files.

## Innovation

The project will use Microsoft Power BI to create interactive dashboards from the Oracle reporting views. Operators will be able to review daily income, cost trends, per-kilometre cost, and profitability by study group.

## Repository Structure

```text
.
├── README.md
├── data/
│   ├── dataset_card.md
│   ├── original/
│   │   └── daily_data/                   (source copy and README for provenance)
│   └── raw/
│       └── daily_data/                   (source README and three CSV load inputs)
└── docs/
    ├── research/
    │   └── research_log.md
    ├── proposal/
    │   └── proposal.md
    ├── design/
    │   ├── normalization.md
    │   ├── data_dictionary.md
    │   ├── erd.svg
    │   ├── erd.png
    │   └── phase_ii_checklist.md
    └── presentation/
        └── MotoTrack_Phase0_Presentation.pptx
```

Later phases add `database/`, `03_sql/` and the phase documentation folders.

## Project Scope

This simplified version of MotoTrack focuses on the core database problem:

- tracking riders
- recording daily income, fuel/electric energy and maintenance costs
- comparing baseline and transition groups
- calculating profit on financially complete days, by group and rider
- producing summarized reports

This keeps the project realistic, easy to explain, and manageable within the course requirements.

## References

1. Ampersand Energy. (2025). *Ampersand opens battery network in push for global EV makers*. https://www.ampersand.energy/mediacentre/press-release%3A-ampersand-opens-battery-network-in-push-for-global-ev-makers
2. Kenya National Bureau of Statistics. (2022). *Economic Survey 2022*. Government of Kenya. https://www.knbs.or.ke/reports/2022-economic-survey/
3. Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). *Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023)* [Data set]. Mendeley Data. https://doi.org/10.17632/nv3rkn24zv.1
4. Mbutura, A., Manono, S., & Kitetu, M. (2026). From fuel to electric: Mobility patterns and perceptions of commercial motorcycle operators in Nairobi, Kenya, evidence from a before-and-after field study (2023). *African Transport Studies, 4*, 100092. https://doi.org/10.1016/j.aftran.2026.100092
5. Oracle. (2023). *Oracle Database 21c documentation*. Oracle Corporation. https://docs.oracle.com/en/database/oracle/oracle-database/21/
6. Stratford, H., & Booysen, M. J. (2025). The environmental and grid impact of boda boda electrification in Nairobi, Kenya. *World Electric Vehicle Journal, 16*(8), 427. https://doi.org/10.3390/wevj16080427
