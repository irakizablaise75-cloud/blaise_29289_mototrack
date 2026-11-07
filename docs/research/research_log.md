# MotoTrack Research Log

**Student:** Irakiza Blaise  
**Student ID:** 29289  
**Course:** INSY 8311 – Database Development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)

Sources were verified against publisher records and abstracts on 7 November 2026. Read each source in full and confirm the findings before final submission.

| # | APA reference | Source type | URL | Key finding in your own words | Gap/relevance to MotoTrack |
|---|---|---|---|---|---|
| 1 | Mbutura, A., Manono, S., & Kitetu, M. (2026). From fuel to electric: Mobility patterns and perceptions of commercial motorcycle operators in Nairobi, Kenya, evidence from a before-and-after field study (2023). *African Transport Studies, 4*, 100092. | Research paper | https://doi.org/10.1016/j.aftran.2026.100092 | A before-and-after study of nine Nairobi operators found that typical operating patterns were maintained after electrification, while energy use per kilometre and operating costs fell substantially. Reliability problems were the decisive concern for continued use. | The study measures costs and perceptions but does not provide a normalized database for per-rider cost tracking; MotoTrack turns these cost concepts into queryable tables. |
| 2 | Stratford, H., & Booysen, M. J. (2025). The environmental and grid impact of boda boda electrification in Nairobi, Kenya. *World Electric Vehicle Journal, 16*(8), 427. | Research paper | https://doi.org/10.3390/wevj16080427 | Using real tracking data from 118 boda bodas, the study models a full transition to electric motorcycles and shows that battery swapping spreads charging demand better than home charging, reducing peak grid load. | The paper focuses on environmental and grid effects, not rider-level financial records; MotoTrack adds the operational cost and maintenance layer. |
| 3 | Kenya National Bureau of Statistics. (2022). *Economic Survey 2022*. Government of Kenya. | Report/statistic | https://www.knbs.or.ke/ | New motorcycle registrations rose 15.6% from 246,705 units in 2020 to 285,203 units in 2021, making motorcycles the fastest-growing vehicle segment in Kenya. | The survey gives national aggregates only; it shows the scale of the sector but not individual trip, fuel or maintenance costs. |
| 4 | Ampersand Energy. (2025). *Ampersand opens battery network in push for global EV makers*. | Existing system | https://www.ampersand.energy/ | Ampersand operates a battery-swap network and fleet software in Rwanda and Kenya, reporting more than 20,000 swaps per day and rider savings of about 35–45% compared with petrol motorcycles. | It is a proprietary energy and fleet platform, not an open bookkeeping database for individual riders or small fleets; MotoTrack focuses on cost records that a rider can query directly. |
| 5 | Mbutura, A., Kitetu, M., Stratford, H., & Booysen, M. J. (2025). *Nairobi motorcycle transit comparison dataset: Fuel vs. electric vehicle performance tracking (2023)* [Data set]. Mendeley Data. https://doi.org/10.17632/nv3rkn24zv.1 | Dataset | https://data.mendeley.com/datasets/nv3rkn24zv | The licensed archive contains 126,067 trip rows and 2,718 daily summary rows for fuel and electric motorcycle cohorts in Nairobi during November–December 2023, including revenue, maintenance, fuel and charging measures. | It does not provide rider names or motorcycle registration details, is not Rwanda-specific, and some self-reported financial values are missing; blanks must remain NULL. |
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

The dataset is used for educational analysis. The CSV files are loaded unchanged into staging tables; any cleaning or conversion is documented in the SQL scripts. Attribution is provided in this log and in the project README.
