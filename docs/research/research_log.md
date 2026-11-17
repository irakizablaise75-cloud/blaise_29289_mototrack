# MotoTrack Research Log

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)

All six sources were read in full and verified against publisher records and abstracts on 7 November 2026.

| # | APA reference | Source type | URL | Key finding in your own words | Gap/relevance to MotoTrack |
|---|---|---|---|---|---|
| 1 | Mbutura, A., Manono, S., & Kitetu, M. (2026). From fuel to electric: Mobility patterns and perceptions of commercial motorcycle operators in Nairobi, Kenya, evidence from a before-and-after field study (2023). *African Transport Studies, 4*, 100092. | Research paper | https://doi.org/10.1016/j.aftran.2026.100092 | A before-and-after study of nine Nairobi operators found that typical operating patterns were maintained after electrification, while energy use per kilometre and operating costs fell substantially. Reliability problems were the decisive concern for continued use. | The study measures costs and perceptions but does not provide a normalized database for per-rider cost tracking; MotoTrack turns these cost concepts into queryable tables. |
| 2 | Stratford, H., & Booysen, M. J. (2025). The environmental and grid impact of boda boda electrification in Nairobi, Kenya. *World Electric Vehicle Journal, 16*(8), 427. | Research paper | https://doi.org/10.3390/wevj16080427 | Using real tracking data from 118 boda bodas, the study models a full transition to electric motorcycles and shows that battery swapping spreads charging demand better than home charging, reducing peak grid load. | The paper focuses on environmental and grid effects, not rider-level financial records; MotoTrack adds the operational cost and maintenance layer. |
| 3 | Kenya National Bureau of Statistics. (2022). *Economic Survey 2022*. Government of Kenya. | Report/statistic | https://www.knbs.or.ke/reports/2022-economic-survey/ | New motorcycle registrations rose 15.6% from 246,705 units in 2020 to 285,203 units in 2021, making motorcycles the fastest-growing vehicle segment in Kenya. | The survey gives national aggregates only; it shows the scale of the sector but not individual trip, fuel or maintenance costs. |
| 4 | Ampersand Energy. (2025). *Ampersand opens battery network in push for global EV makers*. | Existing system | https://www.ampersand.energy/mediacentre/press-release%3A-ampersand-opens-battery-network-in-push-for-global-ev-makers | Ampersand operates a battery-swap network and fleet software in Rwanda and Kenya, reporting more than 20,000 swaps per day and cutting rider fuel costs by about 35% compared with petrol motorcycles. | It is a proprietary energy and fleet platform, not an open bookkeeping database for individual riders or small fleets; MotoTrack focuses on cost records that a rider can query directly. |
| 5 | Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). *Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023)* [Data set]. Mendeley Data. https://doi.org/10.17632/nv3rkn24zv.1 | Dataset | https://doi.org/10.17632/nv3rkn24zv.1 | The licensed archive contains 126,067 trip rows and 2,718 daily summary rows for fuel and electric motorcycle cohorts in Nairobi during November–December 2023. MotoTrack uses the three daily files across baseline, transition-control and transition-electric groups; trip-level files are not loaded. | It does not provide rider names or motorcycle registration details and is not Rwanda-specific. Some self-reported financial values are missing, so blanks remain NULL and profit is calculated only for rows with complete financial inputs. |
| 6 | Oracle. (2023). *Oracle Database 21c documentation*. Oracle Corporation. | Technical source | https://docs.oracle.com/en/database/oracle/oracle-database/21/ | Oracle Database 21c documentation describes PL/SQL packages, cursors, records, collections, bulk processing, triggers and exception handling, which are the techniques required to implement MotoTrack. | Provides the implementation guidance for the package, calculations, triggers and audit logic; no gap, it is the technical reference. |

## Dataset licence and attribution

- **Title:** Nairobi Motorcycle Transit Comparison Dataset: Fuel vs. Electric Vehicle Performance Tracking (2023)
- **Contributors:** Martin Kitetu, Alois Mbutura, Halloran Stratford, MJ Booysen
- **Publisher:** Mendeley Data
- **Version:** 1
- **Published:** 3 March 2025
- **DOI:** 10.17632/nv3rkn24zv.1
- **Licence:** CC BY 4.0
- **Institutions:** EED Advisory, Clean Air Taskforce, Stellenbosch University

The dataset is used for educational analysis. The three original daily CSVs under `data/raw/daily_data/` are retained unchanged and loaded into separate staging tables; copies are also kept under `data/original/daily_data/` for provenance. Trip-level CSVs, the archive ZIP and a legacy derived extract were removed from the working project to keep its data scope limited to daily summaries. The DOI and publisher URL above identify the complete source. Attribution is provided in this log, the dataset card and the project README.
