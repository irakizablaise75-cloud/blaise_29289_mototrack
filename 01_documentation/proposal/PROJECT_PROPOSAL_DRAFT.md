# MotoTrack: Moto Taxi Trip, Fuel and Maintenance Cost Tracker

**Student:** [Your full name]  
**Student ID:** [Your student ID]  
**Course:** [Course code and title]  
**Institution:** Adventist University of Central Africa (AUCA)  
**Academic year:** 2026–2027

## Problem Statement
Motorcycle taxi operators need to monitor daily trips, revenue, fuel or energy expenses, and maintenance costs. When operational information is incomplete or kept in separate records, it becomes difficult to determine daily profitability, compare operating costs, and identify unusual expenses. MotoTrack addresses this information-management problem through a structured Oracle database and PL/SQL solution.

## Proposed Solution
MotoTrack will be an Oracle database application implemented using SQL and PL/SQL in Oracle SQL Developer. It will store anonymized tracked-unit information, trip records, daily operating summaries, fuel expenses, electric battery/charging measures, and audit records. Stored procedures and functions will support data entry and calculations. SQL views and reports will summarize trip activity, operating costs and daily performance.

## Data Source
The initial dataset is the *Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)* hosted on Mendeley Data: https://data.mendeley.com/datasets/nv3rkn24zv. The uploaded archive contains 126,067 trip rows and 2,718 daily-summary rows. It includes fuel and electric motorcycle groups, trip distance and duration, daily revenue, maintenance costs and energy-related measures. The dataset uses Kenyan Shillings and represents Nairobi, Kenya. Missing values are retained as NULL rather than assumed to be zero. The dataset does not provide separate rider names or motorcycle registration details. Additional local data would be needed before making Rwanda-specific claims.

## Planned Database Tables
The preliminary model includes `RIDER_UNITS`, `TRIPS`, `DAILY_OPERATIONS`, `FUEL_DAILY_COSTS`, `ELECTRIC_DAILY_COSTS`, `MAINTENANCE_EVENTS`, and `AUDIT_LOG`. Raw import tables will be used for staging. The final design will be confirmed through normalization, an ERD and a data dictionary.

## Planned PL/SQL Features
The implementation will demonstrate records, collections, implicit and explicit cursors, BULK COLLECT, FORALL, stored procedures, functions, packages and exception handling. Triggers and an audit table will record selected database changes and enforce data-quality rules. Reports will use SQL views and PL/SQL routines.

## Innovation
The proposed innovation is a database-native, menu-driven PL/SQL interface and a set of operational reports that allow a user to run common MotoTrack tasks from SQL Developer. The project will calculate daily profit and operating cost per kilometre only when the required data is available. **The student must confirm with the instructor that this database-native interface is acceptable for the course innovation criterion.**

## References
1. [Complete the APA reference using the citation details shown on the Mendeley Data record after personally verifying it.]
2. [Add two research papers you have personally read.]
3. [Add one credible report/statistics source you have personally read.]
4. [Add one existing-system source you have personally examined.]
5. [Add one Oracle technical source you have personally consulted.]

**Draft status:** This is a starting draft. Verify every statement, add your own research and format it to the lecturer's required page and font limits before submission.
