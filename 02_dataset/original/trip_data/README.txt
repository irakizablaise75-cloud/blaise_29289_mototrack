Nairobi Motorcycle Transit Comparison Dataset: Trip Data

Overview
This dataset contains trip-level GPS tracking data for motorcycle taxis (boda bodas) in Nairobi, Kenya, collected in 2023. The study compared traditional internal combustion engine (ICE) motorcycles with electric motorcycles across two phases:

1. Baseline Phase (2023-11-13 to 2023-11-26): 118 ICE motorcycles tracked over 14 days
2. Transition Phase (2023-12-10 to 2023-12-21): 108 ICE motorcycles (control group) and 9 electric motorcycles (treatment group) tracked over 12 days

Files
- baseline-fuel-motorcycle-trip-data.csv: Trip data for ICE motorcycles during the baseline phase
- transition-control-fuel-motorcycle-trip-data.csv: Trip data for ICE motorcycles (control group) during the transition phase
- transition-treatment-electric-motorcycle-trip-data.csv: Trip data for electric motorcycles (treatment group) during the transition phase

Column Descriptions
user_id - Unique identifier for each rider/motorcycle
start_date - Date when the trip started (YYYY-MM-DD)
start_time - Time when the trip started (HH:MM:SS)
end_date - Date when the trip ended (YYYY-MM-DD)
end_time - Time when the trip ended (HH:MM:SS)
duration_min - Total trip duration in minutes
distance_km - Total distance covered in kilometers
idle_time_min - Time during trip spent on momentary stops (< 1 minute)
start_lat - Starting point latitude
start_lon - Starting point longitude
end_lat - Ending point latitude
end_lon - Ending point longitude
avg_speed_kmh - Average speed including idle time (km/h)
avg_moving_speed_kmh - Average speed only considering movement (km/h)
max_speed_kmh - Maximum speed achieved during the trip (km/h)

Notes
- All timestamps are in UTC+3 (East Africa Time)
- GPS data was sampled at 10-second intervals
- Start and end coordinates for first and last trips of the day are intentionally removed to protect rider privacy and anonymise home locations
- Missing location data is indicated by empty cells
- Maximum speed represents the highest speed achieved over a 10-second sampling interval