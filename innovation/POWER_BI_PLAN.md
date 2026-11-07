# MotoTrack Innovation – Power BI Dashboard Plan

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)  
**Innovation option:** Analytics dashboard  
**Tool:** Microsoft Power BI Desktop

## 1. What the innovation does

The innovation is a live Power BI dashboard connected to the MotoTrack Oracle database. It lets a rider or fleet owner see daily profit, operating cost per kilometre, fuel efficiency, revenue and maintenance trends without writing SQL.

Business rules stay in PL/SQL. Power BI only reads the reporting views and displays the results. Missing source values are shown as blank, never as zero.

## 2. Data source: Oracle views

Power BI must read the views, not the base tables, so the business rules remain in the database.

| View | Use in Power BI |
|---|---|
| `VW_MOTOTRACK_DAILY_SUMMARY` | Daily profit, revenue, maintenance, energy cost, distance, cost per km, fuel efficiency. |
| `VW_MOTOTRACK_TRIP_SUMMARY` | Trip drill-down: duration, distance, idle time and speed by unit. |

Key columns available: `SOURCE_USER_ID`, `POWERTRAIN_TYPE`, `COHORT_NAME`, `STUDY_PHASE`, `OPERATING_DATE`, `DISTANCE_KM`, `REVENUE_KES`, `MAINTENANCE_KES`, `ENERGY_COST_KES`, `FUEL_AMOUNT_L`, `KWH_CHARGING`, `DAILY_PROFIT_KES`, `COST_PER_KM_KES`.

## 3. Verified connection details for this machine

| Item | Value |
|---|---|
| Oracle version | Oracle Database 21c |
| Oracle service | `OracleServiceORCL` (running) |
| Listener | `192.168.56.1:1521` |
| Project PDB service | `bl_pdb_29289` |
| Default PDB service | `orclpdb` |
| Easy Connect string | `192.168.56.1:1521/bl_pdb_29289` |

Connect to the **PDB service** (`bl_pdb_29289`), not the CDB root (`orcl`). Use the MotoTrack schema user and password.

## 4. Prerequisites

1. **Install Power BI Desktop** (Windows). It is not currently installed on this machine.
2. **Install an Oracle provider** – choose one:
   - **Oracle Client for Microsoft Tools (OCMT)**, 64-bit, free from Oracle. This is the stable option.
   - The **bundled Oracle provider** in Power BI Desktop (Preview feature). Enable it under *File > Options and settings > Options > Preview features*.
3. **Grant read access** to the Power BI user:
   ```sql
   GRANT SELECT ON vw_mototrack_daily_summary TO <powerbi_user>;
   GRANT SELECT ON vw_mototrack_trip_summary  TO <powerbi_user>;
   ```
4. **Network access** from the Power BI machine to `192.168.56.1:1521`.
5. **For Power BI Service refresh:** install the 64-bit OCMT on the machine running an **enterprise on-premises data gateway**. Personal gateways do not support new Oracle connections.

## 5. Dashboard pages

1. **Executive overview** – total revenue, total cost, total profit, average cost per km, total distance, active units. Slicers: powertrain, cohort, study phase, date.
2. **Daily performance** – profit and cost per km over time, revenue versus cost, maintenance trend.
3. **Fuel vs electric** – cost per km, energy cost, distance and profit by powertrain and cohort.
4. **Unit drill-down** – trips, idle time, speed and maintenance events for one tracked unit.
5. **Data quality** – count and percentage of missing revenue, maintenance and energy values.

## 6. DAX measures

```DAX
Total Revenue = SUM ( vw_mototrack_daily_summary[revenue_kes] )
Total Maintenance = SUM ( vw_mototrack_daily_summary[maintenance_kes] )
Total Energy Cost = SUM ( vw_mototrack_daily_summary[energy_cost_kes] )
Total Cost = [Total Maintenance] + [Total Energy Cost]
Total Profit = SUM ( vw_mototrack_daily_summary[daily_profit_kes] )
Avg Cost per KM = DIVIDE ( [Total Cost], SUM ( vw_mototrack_daily_summary[distance_km] ) )
Profit Margin % = DIVIDE ( [Total Profit], [Total Revenue] )
Fuel Efficiency km per L = DIVIDE ( SUM ( vw_mototrack_daily_summary[distance_km] ), SUM ( vw_mototrack_daily_summary[fuel_amount_l] ) )
Missing Revenue Days = COUNTROWS ( FILTER ( vw_mototrack_daily_summary, ISBLANK ( vw_mototrack_daily_summary[revenue_kes] ) ) )
```

Use `DIVIDE` and `BLANK`. Do not replace missing values with zero, because that would create a false profit.

## 7. How to run it

1. Open Power BI Desktop.
2. Select **Get data > Oracle database**.
3. Enter server `192.168.56.1:1521/bl_pdb_29289`.
4. Choose **Import** mode for normal use, or **DirectQuery** for a live demonstration.
5. Select the two MotoTrack views.
6. Build the pages listed in section 5.
7. Save the file as `MotoTrack_Dashboard.pbix` in this folder.

## 8. Known issues to expect

- The reporting views have no primary key. Use **Import** mode. If DirectQuery is required, Power BI may warn that a table does not define key columns; add a surrogate key to the view or query the base tables instead.
- Power BI Service refresh requires an **enterprise** on-premises data gateway. Personal gateways do not support new Oracle connections.
- The Oracle listener must be reachable from the Power BI machine. Test the connection first with `tnsping 192.168.56.1:1521/bl_pdb_29289` or SQL*Plus.
- If the PDB is restarted, confirm that the service is registered with `lsnrctl status`.
- The views must be created in the project PDB before Power BI can read them. Run `03_sql/06_reports/06_create_views.sql` during the database build phases.

## 9. Evidence to capture for Phase VII

- Screenshot of the successful Oracle connection.
- Screenshot of each dashboard page.
- Live demonstration: insert a new daily row in Oracle, refresh Power BI, and show the change.
- Screenshot showing missing values displayed as blank, not zero.
- Short explanation of how the dashboard helps solve the stated problem.

## 10. Status

This is the Phase 0 plan. The dashboard will be built and demonstrated in Phase VII. No screenshots are included yet because Power BI Desktop is not installed on this machine.
