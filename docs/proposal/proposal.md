# MotoTrack: Moto Taxi Trip, Fuel and Maintenance Cost Tracker

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)  
**Academic year:** 2026–2027  
**Repository:** https://github.com/irakizablaise75-cloud/blaise_29289_mototrack

## Problem Statement
Motorcycle taxi operators need to monitor daily trips, revenue, fuel or energy expenses, and maintenance costs. When operational information is incomplete or kept in separate records, it becomes difficult to determine daily profitability, compare operating costs, and identify unusual expenses. MotoTrack addresses this information-management problem through a structured Oracle database and PL/SQL solution.

## Objectives
The main objective is to design and implement an Oracle database with PL/SQL that helps motorcycle taxi operators record, calculate and analyse trip, fuel, energy and maintenance costs. The specific objectives are to:

1. Normalize the source data into a relational model that separates tracked units, trips, daily operations, fuel costs, electric costs and maintenance events.
2. Implement PL/SQL procedures, functions, packages, cursors and triggers that enforce business rules and calculate profit and operating cost per kilometre.
3. Provide reliable views and reports that summarize daily performance and support cost comparison between fuel and electric motorcycles.

## Proposed Solution
MotoTrack will be an Oracle database application implemented using SQL and PL/SQL in Oracle SQL Developer. It will store anonymized tracked-unit information, trip records, daily operating summaries, fuel expenses, electric battery/charging measures, and audit records. Stored procedures and functions will support data entry and calculations. SQL views and reports will summarize trip activity, operating costs and daily performance.

## Data Source
The initial dataset is the *Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)* hosted on Mendeley Data (DOI: 10.17632/nv3rkn24zv.1, licence CC BY 4.0): https://data.mendeley.com/datasets/nv3rkn24zv. The uploaded archive contains 126,067 trip rows and 2,718 daily-summary rows. It includes fuel and electric motorcycle groups, trip distance and duration, daily revenue, maintenance costs and energy-related measures. The dataset uses Kenyan Shillings and represents Nairobi, Kenya. Missing values are retained as NULL rather than assumed to be zero. The dataset does not provide separate rider names or motorcycle registration details. Additional local data would be needed before making Rwanda-specific claims.

## Planned Database Tables
The preliminary model includes `RIDER_UNITS`, `TRIPS`, `DAILY_OPERATIONS`, `FUEL_DAILY_COSTS`, `ELECTRIC_DAILY_COSTS`, `MAINTENANCE_EVENTS`, and `AUDIT_LOG`. Raw import tables will be used for staging. The final design will be confirmed through normalization, an ERD and a data dictionary.

## Planned PL/SQL Features
The implementation will demonstrate records, collections, implicit and explicit cursors, BULK COLLECT, FORALL, stored procedures, functions, packages and exception handling. Triggers and an audit table will record selected database changes and enforce data-quality rules. Reports will use SQL views and PL/SQL routines.

## Innovation
The innovation is a live Power BI analytics dashboard connected to the MotoTrack Oracle database. Power BI reads the reporting views `VW_MOTOTRACK_DAILY_SUMMARY` and `VW_MOTOTRACK_TRIP_SUMMARY`, while all business rules and calculations remain in PL/SQL. The dashboard will show daily profit, operating cost per kilometre, fuel efficiency, revenue and maintenance trends by tracked unit, powertrain, cohort and date. Missing source values are displayed as blank, never as zero. The dashboard will be demonstrated live in Phase VII.

## References
1. Ampersand Energy. (2025). *Ampersand opens battery network in push for global EV makers*. https://www.ampersand.energy/
2. FIA Foundation. (2024). *A fare price: An investigation into the health costs of motorcycle taxi crashes in Kenya*. https://www.fiafoundation.org/resources/a-fare-price
3. Kenya National Bureau of Statistics. (2022). *Economic Survey 2022*. Government of Kenya. https://www.knbs.or.ke/
4. Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023). *Data in Brief, 61*, 111805. https://doi.org/10.1016/j.dib.2025.111805
5. Mbutura, A., Manono, S., & Kitetu, M. (2026). From fuel to electric: Mobility patterns and perceptions of commercial motorcycle operators in Nairobi, Kenya, evidence from a before-and-after field study (2023). *African Transport Studies, 4*, 100092. https://doi.org/10.1016/j.aftran.2026.100092
6. Oracle. (2023). *Oracle Database 21c documentation*. Oracle Corporation. https://docs.oracle.com/en/database/oracle/oracle-database/21/
7. Stratford, H., & Booysen, M. J. (2025). The environmental and grid impact of boda boda electrification in Nairobi, Kenya. *World Electric Vehicle Journal, 16*(8), 427. https://doi.org/10.3390/wevj16080427
