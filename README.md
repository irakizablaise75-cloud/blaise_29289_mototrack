# MotoTrack – Moto Taxi Trip, Fuel and Maintenance Cost Tracker

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)  
**Academic year:** 2026–2027  
**Repository:** https://github.com/irakizablaise75-cloud/blaise_29289_mototrack

## Problem Statement

Motorcycle taxi operators need to monitor daily trips, revenue, fuel or energy expenses, and maintenance costs. When this information is incomplete or kept in separate records, it is difficult to determine daily profitability, compare operating costs, and identify unusual expenses. MotoTrack addresses this information-management problem with a structured Oracle database and PL/SQL solution.

## Objectives

**Main objective:** Design and implement an Oracle database with PL/SQL that helps motorcycle taxi operators record, calculate and analyse trip, fuel, energy and maintenance costs.

**Specific objectives:**

1. Normalize the source data into a relational model that separates tracked units, trips, daily operations, fuel costs, electric costs and maintenance events.
2. Implement PL/SQL procedures, functions, packages, cursors and triggers that enforce business rules and calculate profit and operating cost per kilometre.
3. Provide reliable views and reports that summarize daily performance and support cost comparison between fuel and electric motorcycles.

## Proposed Solution

MotoTrack is an Oracle database application implemented with SQL and PL/SQL in Oracle SQL Developer. It stores anonymized tracked-unit information, trip records, daily operating summaries, fuel expenses, electric battery and charging measures, and audit records. Stored procedures and functions support data entry and calculations, while SQL views and reports summarize trip activity, operating costs and daily performance.

## Data Source

The dataset is the *Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)*, hosted on Mendeley Data (DOI: `10.17632/nv3rkn24zv.1`, licence CC BY 4.0):

https://data.mendeley.com/datasets/nv3rkn24zv

The archive contains 126,067 trip rows and 2,718 daily-summary rows across six CSV files. It covers fuel and electric motorcycle cohorts, trip distance and duration, daily revenue, maintenance costs and energy-related measures. Financial values are in Kenyan Shillings (KES), times are UTC+3, and the study area is Nairobi, Kenya.

Missing values are retained as `NULL` rather than treated as zero. The dataset does not provide separate rider names or motorcycle registration details, so the model uses **tracked units** instead of inventing personal or vehicle details. The dataset is not Rwanda-specific.

The dataset licence and citation must be verified on the Mendeley record before submission. Attribution details are recorded in `docs/research/research_log.md`.

## Innovation

The innovation is a live **Power BI analytics dashboard** connected to the MotoTrack Oracle database. Power BI reads the reporting views `VW_MOTOTRACK_DAILY_SUMMARY` and `VW_MOTOTRACK_TRIP_SUMMARY`, while all business rules and calculations remain in PL/SQL. The dashboard will show daily profit, operating cost per kilometre, fuel efficiency, revenue and maintenance trends by tracked unit, powertrain, cohort and date. Missing source values are displayed as blank, never as zero. The dashboard will be built and demonstrated in Phase VII.

## Planned Database Tables

| Table | Purpose |
|---|---|
| `RIDER_UNITS` | Anonymized source `user_id`, vehicle technology, study cohort and phase. |
| `TRIPS` | Trip-level records with timing, distance, duration, idle time, GPS and speed metrics. |
| `DAILY_OPERATIONS` | Daily totals for distance, duration, idle time, revenue and maintenance. |
| `FUEL_DAILY_COSTS` | Fuel cost, unit price and litres for fuel units. |
| `ELECTRIC_DAILY_COSTS` | Battery-swap cost and charging kWh for electric units. |
| `MAINTENANCE_EVENTS` | Separately recorded maintenance events. |
| `AUDIT_LOG` | Insert, update and delete activity on selected business tables. |

Raw staging tables mirror the six CSV files so that blank values can be preserved during import. The final design will be confirmed through normalization to 3NF, an ERD and a data dictionary in Phase II.

## Planned PL/SQL Features

- Records and collections.
- Implicit and explicit cursors.
- `BULK COLLECT` and `FORALL`.
- Stored procedures and functions.
- Packages with specification and body.
- Exception handling.
- Triggers that enforce data-quality rules and write to `AUDIT_LOG`.
- SQL views and PL/SQL reports.

## Repository Structure (Phase 0)

```
.
├── README.md
├── docs/
│   ├── research/research_log.md
│   ├── proposal/proposal.md
│   └── presentation/
│       ├── presentation_outline.md
│       └── MotoTrack_Phase0_Presentation.pptx
└── data/
    ├── original/
    └── processed/
```

## Phase Status

- [x] Phase 0 – Research, data source and project proposal
- [ ] Phase I – Business process modeling
- [ ] Phase II – Data sourcing and normalization
- [ ] Phase III – Database (PDB) creation
- [ ] Phase IV – Tables and data loading
- [ ] Phase V – PL/SQL development
- [ ] Phase VI – Advanced programming and auditing
- [ ] Phase VII – Documentation, innovation and final presentation

## Dataset Facts

- 126,067 trip rows across three trip CSV files.
- 2,718 daily summary rows across three daily CSV files.
- 119 distinct `user_id` values across the six CSV files.
- Daily data covers baseline fuel, transition control fuel and transition treatment electric groups.
- Trip data contains trip timing, distance, duration, idle time, GPS coordinates and speed metrics.
- Daily data contains revenue and maintenance costs, plus fuel costs for fuel motorcycles or battery-swap and charging measures for electric motorcycles.
- Blank CSV cells represent missing values and are not automatically treated as zero.

## References

1. Ampersand Energy. (2025). *Ampersand opens battery network in push for global EV makers*. https://www.ampersand.energy/
2. FIA Foundation. (2024). *A fare price: An investigation into the health costs of motorcycle taxi crashes in Kenya*. https://www.fiafoundation.org/resources/a-fare-price
3. Kenya National Bureau of Statistics. (2022). *Economic Survey 2022*. Government of Kenya. https://www.knbs.or.ke/
4. Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023). *Data in Brief, 61*, 111805. https://doi.org/10.1016/j.dib.2025.111805
5. Mbutura, A., Manono, S., & Kitetu, M. (2026). From fuel to electric: Mobility patterns and perceptions of commercial motorcycle operators in Nairobi, Kenya, evidence from a before-and-after field study (2023). *African Transport Studies, 4*, 100092. https://doi.org/10.1016/j.aftran.2026.100092
6. Oracle. (2023). *Oracle Database 21c documentation*. Oracle Corporation. https://docs.oracle.com/en/database/oracle/oracle-database/21/
7. Stratford, H., & Booysen, M. J. (2025). The environmental and grid impact of boda boda electrification in Nairobi, Kenya. *World Electric Vehicle Journal, 16*(8), 427. https://doi.org/10.3390/wevj16080427

The complete research log, including the key finding and gap for each source, is maintained in `docs/research/research_log.md`.
