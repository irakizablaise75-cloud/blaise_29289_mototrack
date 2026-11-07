Nairobi Motorcycle Transit Comparison Dataset: Daily Data

Overview
This dataset contains daily summaries of motorcycle taxi (boda boda) usage in Nairobi, Kenya, collected in 2023. The study compared traditional internal combustion engine (ICE) motorcycles with electric motorcycles across two phases:

1. Baseline Phase (2023-11-13 to 2023-11-26): 118 ICE motorcycles tracked over 14 days
2. Transition Phase (2023-12-10 to 2023-12-21): 108 ICE motorcycles (control group) and 9 electric motorcycles (treatment group) tracked over 12 days

Files
- baseline-fuel-motorcycle-daily-data.csv: Daily summary data for ICE motorcycles during the baseline phase
- transition-control-fuel-motorcycle-daily-data.csv: Daily summary data for ICE motorcycles (control group) during the transition phase
- transition-treatment-electric-motorcycle-daily-data.csv: Daily summary data for electric motorcycles (treatment group) during the transition phase

Column Descriptions

Common Columns (All Files)
user_id - Unique identifier for each rider/motorcycle
date - Date of data collection (YYYY-MM-DD)
distance_km - Total distance covered in kilometers for the day
duration_min - Total travel time in minutes (including idle time)
idle_time_min - Total time spent on momentary stops (< 1 minute)
revenue_kes - Money generated from activities done with the motorcycle (Kenyan Shillings)
maintenance_kes - Cost incurred in maintenance of the motorcycle (Kenyan Shillings)

Fuel Motorcycle Specific Columns
fuel_cost_kes - Total cost of fuel used per day (Kenyan Shillings)
fuel_unit_cost_kes_per_l - Cost of fuel per liter (Kenyan Shillings)
fuel_amount_l - Amount of fuel consumed per day (liters)

Electric Motorcycle Specific Columns
battery_swap_cost_kes - Amount charged to swap the battery (Kenyan Shillings)
kwh_charging - Kilowatt-hours drawn during charging

Notes
- All dates are in YYYY-MM-DD format
- Missing values are indicated by empty cells
- Financial values are in Kenyan Shillings (KES)
- Data is aggregated from the trip-level data