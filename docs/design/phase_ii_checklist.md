# Phase II Completion Checklist — MotoTrack

**Project:** MotoTrack — Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL  
**Status:** Updated for daily-only data across all study groups  
**Date:** 16 November 2026

## 1. Requirement coverage

| Requirement | Evidence |
|---|---|
| Retain the selected source data | The three daily source CSVs and README remain unchanged in `data/raw/daily_data/`; a provenance copy remains in `data/original/daily_data/`; trip data and downloaded archives are excluded |
| Define current data scope | `data/dataset_card.md`; three daily CSVs, 2,718 rows, all three source groups; trip files are not loaded |
| Document source, licence and limitations | `data/dataset_card.md` and the research log |
| Normalize the selected daily data | `docs/design/normalization.md`; UNF to 3NF with the rider/group/date key |
| Document tables and columns | `docs/design/data_dictionary.md` |
| Load each daily file safely | `03_sql/02_staging/02_create_staging_tables.sql` and `03_sql/03_data_loading/03_load_normalized_data.sql` |
| Preserve missing values | Loader converts blanks to `NULL`; profit requires complete financial inputs |
| Validate loaded data | `03_sql/07_tests/07_validation_queries.sql`; expected group counts and date coverage |
| Maintain daily-only scope in the proposal and process explanation | `01_documentation/phase_0_research_and_proposal/proposal/proposal.md` and the Phase I BPMN explanation |
| Logical ERD | `docs/design/erd.svg` and `docs/design/erd.png`; shows daily operations, source groups, staging tables and audit/event relationships |

## 2. Dataset reconciliation values

| Validation | Expected |
|---|---:|
| Baseline fuel rows | 1,480 |
| Transition-control fuel rows | 1,150 |
| Transition-treatment electric rows | 88 |
| Total daily rows | 2,718 |
| Distinct rider IDs | 119 |
| Distinct rider/source-group pairs | 235 |
| Distinct operating dates | 26 |
| First date | 2023-11-13 |
| Last date | 2023-12-21 |

Expected counts by group are also checked in `07_validation_queries.sql`. Revenue and energy-cost totals are not treated as complete because source financial fields contain blanks.

## 3. Final document set

| Document | Purpose |
|---|---|
| `data/dataset_card.md` | Dataset, licence, row counts, field mappings and NULL rules |
| `docs/design/normalization.md` | Normalization of the daily rider/group/date fact |
| `docs/design/data_dictionary.md` | Logical/physical table and column definitions |
| `docs/design/phase_ii_checklist.md` | This requirement and data reconciliation checklist |
| `README.md` | Project summary, scope and structure |
| `06_submission/SUBMISSION_CHECKLIST.md` | Submission tracker |

## 4. Sign-off

- [x] Three original daily source files selected; trip-level files excluded from loading.
- [x] Staging and load scripts distinguish baseline, control and electric groups.
- [x] Schema contains daily activity and both powertrain-specific cost fields.
- [x] Missing source financial values remain NULL.
- [x] Profit calculations require complete financial inputs.
- [x] Documentation and validation targets reflect all 2,718 daily rows.
- [x] ERD updated and regenerated for the current schema.
