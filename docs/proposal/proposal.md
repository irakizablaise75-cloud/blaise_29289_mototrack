# MotoTrack: Motorcycle Taxi Daily Cost and Profit Tracker

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)  
**Academic year:** 2026–2027

## Problem Statement
Motorcycle taxi operators often record trip income, fuel costs, and maintenance expenses in separate places, making it difficult to determine daily profitability and compare operating performance. In many cases, the information is not centralized, which limits the ability to monitor revenue, identify unusual expenses, and evaluate the financial performance of each rider or day. MotoTrack addresses this problem by providing a structured database system that stores daily operating summaries and expenses in a clear and organized manner.

## Objectives
The main objective of this project is to design and implement a database system that helps motorcycle taxi operators record daily trip income, fuel costs, and maintenance expenses. The specific objectives are to:

1. Store rider and daily operating information in a structured relational database.
2. Organize daily operational and financial data to improve data quality and reporting.
3. Calculate total income, total expenses, and daily profit for each rider and date.
4. Support queries and reports that summarize operational performance.
5. Use SQL and PL/SQL to enforce business rules and generate useful financial outputs.

## Proposed Solution
MotoTrack will be implemented as an Oracle database project using SQL and PL/SQL. The system will store rider information and daily summaries in a normalized relational structure. SQL queries will analyze daily activity and costs, while PL/SQL procedures and functions will calculate profit on days with complete financial data, summarize performance by study group, and support reporting. Individual trip records are outside this project's data scope.

## Data Source
The project uses all three daily summary files from the public Mendeley dataset *Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)* (DOI: `10.17632/nv3rkn24zv.1`). The dataset is openly available under CC BY 4.0. The baseline, transition-control and transition-electric files contain 2,718 rider-day rows in total. Trip-level files are not loaded. This provides a manageable way to compare daily operations and costs across the study groups while preserving missing values as NULL.

## Planned Database Tables
The database model includes the following tables:

- `RIDERS`
- `DAILY_OPERATIONS`
- `MAINTENANCE_EVENTS`
- `AUDIT_LOG`
- `STG_DAILY_BASELINE_FUEL` (staging)
- `STG_DAILY_TRANSITION_FUEL` (staging)
- `STG_DAILY_TRANSITION_ELECTRIC` (staging)

These tables store rider details, one row per rider/source-group/day, optional event-level maintenance, changes for database auditing, and the three raw daily CSV imports.

## Planned PL/SQL Features
The project will demonstrate the following PL/SQL concepts:

- stored procedures
- functions
- triggers
- exception handling
- SQL views
- reporting queries for daily profit and cost analysis

These features will support operational data validation, summarization, and reporting.

## Innovation
The project will use Microsoft Power BI to create interactive dashboards from the Oracle reporting views. Operators will be able to review trip income, cost trends, and daily profitability in an organized and reliable format.

## References
The project uses a public educational dataset; it represents Nairobi motorcycle-taxi operations and is not Rwanda-specific. See the dataset card and research log for full attribution, source details and limitations.
