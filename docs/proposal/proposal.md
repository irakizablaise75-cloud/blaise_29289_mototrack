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
The initial dataset is the *Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)* hosted on Mendeley Data: https://data.mendeley.com/datasets/nv3rkn24zv. The uploaded archive contains 126,067 trip rows and 2,718 daily-summary rows. It includes fuel and electric motorcycle groups, trip distance and duration, daily revenue, maintenance costs and energy-related measures. The dataset uses Kenyan Shillings and represents Nairobi, Kenya. Missing values are retained as NULL rather than assumed to be zero. The dataset does not provide separate rider names or motorcycle registration details. Additional local data would be needed before making Rwanda-specific claims.

## Planned Database Tables
The preliminary model includes `RIDER_UNITS`, `TRIPS`, `DAILY_OPERATIONS`, `FUEL_DAILY_COSTS`, `ELECTRIC_DAILY_COSTS`, `MAINTENANCE_EVENTS`, and `AUDIT_LOG`. Raw import tables will be used for staging. The final design will be confirmed through normalization, an ERD and a data dictionary.

## Planned PL/SQL Features
The implementation will demonstrate records, collections, implicit and explicit cursors, BULK COLLECT, FORALL, stored procedures, functions, packages and exception handling. Triggers and an audit table will record selected database changes and enforce data-quality rules. Reports will use SQL views and PL/SQL routines.

## Innovation
The planned innovation is a database-native, menu-driven PL/SQL interface with operational reports that allow a user to run common MotoTrack tasks from SQL Developer. If the course requires an external interactive layer, the solution will be extended with Oracle APEX, which connects directly to the same Oracle database and calls the PL/SQL routines. The project calculates daily profit and operating cost per kilometre only when the required data is available.

## References
1. [Complete the APA reference using the citation details shown on the Mendeley Data record after personally verifying it.]
2. [Add two research papers you have personally read.]
3. [Add one credible report/statistics source you have personally read.]
4. [Add one existing-system source you have personally examined.]
5. [Add one Oracle technical source you have personally consulted.]
