# Phase II Completion Checklist — MotoTrack

**Project:** MotoTrack — Motorcycle Taxi Daily Cost and Profit Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL  
**Status:** Updated for daily-only data across all study groups  
**Date:** 17 November 2026

## 1. Requirement coverage

| Requirement | Evidence |
|---|---|
| Retain the selected source data | The three daily source CSVs and README remain unchanged in `data/raw/daily_data/`; a provenance copy remains in `data/original/daily_data/`; trip data and downloaded archives are excluded |
| Define current data scope | `data/dataset_card.md`; three daily CSVs, 2,718 rows, all three source groups; trip files are not loaded |
| Document source, licence, format, size, dates and limitations | `data/dataset_card.md` (sections 1, 2 and 5) and the research log |
| Check data quality with counts (no fixes yet) | `data/dataset_card.md` section 4; duplicates, missing keys, invalid dates, non-numeric values and negatives are counted |
| Map every raw field to a target column | `data/dataset_card.md` section 3; raw field → `table.column` with cleaning rules |
| Normalize the selected daily data | `docs/design/normalization.md`; UNF → 1NF → 2NF → 3NF with 3–5 real rows per form and each removed dependency named |
| Identify entities (at least five related tables) | Five related tables with foreign keys: `RIDERS`, `SOURCE_GROUP`, `DAILY_OPERATIONS`, `MAINTENANCE_TYPE`, `MAINTENANCE_EVENTS`; see `docs/design/data_dictionary.md` |
| Document tables and columns (logical, no Oracle types) | `docs/design/data_dictionary.md` |
| Plan a safe load of each daily file | `data/dataset_card.md` section 3 cleaning checklist and `docs/design/data_dictionary.md` section 9 load rules (implemented in Phase IV) |
| Preserve missing values | Load plan converts blanks to `NULL`; profit requires complete financial inputs |
| Define validation targets | `docs/design/phase_ii_checklist.md` section 2 reconciliation values (validated in Phase IV) |
| Maintain daily-only scope in the proposal and process explanation | `docs/proposal/proposal.md` and the Phase I BPMN explanation |
| Logical ERD in crow's-foot notation | `docs/design/erd.svg` and `docs/design/erd.png`; crow's-foot symbols with `1` and `0..*` cardinality for every relationship |

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
| Seed `SOURCE_GROUP` rows | 3 |

Expected counts by group are also checked in `07_validation_queries.sql`. Revenue and energy-cost totals are not treated as complete because source financial fields contain blanks.

## 3. Final document set

| Document | Purpose |
|---|---|
| `data/dataset_card.md` | Dataset metadata, quality counts, field mapping and NULL rules |
| `docs/design/normalization.md` | Normalization of the daily rider/group/date fact |
| `docs/design/data_dictionary.md` | Logical table and column definitions |
| `docs/design/erd.svg`, `docs/design/erd.png` | Logical ERD in crow's-foot notation |
| `docs/design/phase_ii_checklist.md` | This requirement and data reconciliation checklist |
| `README.md` | Project summary, scope and structure |
| `06_submission/SUBMISSION_CHECKLIST.md` | Submission tracker |

## 4. Sign-off

- [x] Three original daily source files selected; trip-level files excluded from loading.
- [x] Staging and load scripts distinguish baseline, control and electric groups.
- [x] Schema contains daily activity and both powertrain-specific cost fields.
- [x] Five related tables with foreign keys; audit table standalone.
- [x] Every normal form shows 3–5 real source rows and names the dependency removed.
- [x] Missing source financial values remain NULL.
- [x] Profit calculations require complete financial inputs.
- [x] Documentation and validation targets reflect all 2,718 daily rows.
- [x] ERD uses crow's-foot notation and was regenerated for the current schema.
