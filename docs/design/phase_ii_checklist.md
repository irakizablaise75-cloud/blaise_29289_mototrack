# Phase II Completion Checklist — MotoTrack

**Project:** MotoTrack — Moto Taxi Trip, Fuel and Maintenance Cost Tracker  
**Student:** Irakiza Blaise (29289)  
**Course:** INSY 8311 — Database Development with PL/SQL  
**Version:** 1.0  
**Status:** Final — Phase II  
**Date:** 15 November 2026

This checklist maps each Phase II requirement to the artefact that satisfies it. It is a navigation aid for the marker and a final self-check before submission.

## 1. Requirement coverage

| Phase II requirement | Where satisfied | Evidence |
|---|---|---|
| Store the raw data exactly as downloaded | `data/raw/` | Six CSVs, two READMEs and the original ZIP; SHA-256 comparison with `data/original/` recorded in `data/dataset_card.md` Section 2 |
| Do not edit raw files | `data/raw/` | No cleaning, sorting, deduplication or renaming; all transformations are deferred to Phase IV |
| Dataset card | `data/dataset_card.md` | Source, DOI, CC BY 4.0 licence, size, record meaning, dates, coverage, anonymisation and limitations |
| Data quality counts | `data/dataset_card.md` Sections 7.1–7.4 | Missing values, duplicates, value/range checks, categorical checks and required type conversions |
| Unnormalised form (UNF) | `docs/design/normalization.md` Section 3 | Real rows, candidate key and identification of repeating groups/mixed concepts |
| First Normal Form (1NF) | `docs/design/normalization.md` Section 4 | Atomic values, primary keys, repeating group removed into `TRIPS` |
| Second Normal Form (2NF) | `docs/design/normalization.md` Section 5 | Partial dependency of cohort/phase/powertrain on part of the unit-day key removed into `RIDER_UNIT` |
| Third Normal Form (3NF) | `docs/design/normalization.md` Section 6 | Transitive dependencies removed into `COHORT`, `FUEL_DAILY_COSTS` and `ELECTRIC_DAILY_COSTS` |
| Real sample rows at each step | `docs/design/normalization.md` Sections 3.2, 4.2, 5.2, 6.2 | Five UNF rows; daily and trip rows at 1NF; unit/daily/trip rows at 2NF; rider/cohort/unit/daily/cost/trip rows at 3NF |
| Named dependency removed at each split | `docs/design/normalization.md` Sections 4.2, 5.2, 6.2 | Explicit “Dependency removed” paragraphs after each normal form, using functional-dependency notation |
| Table-by-table normalization summary | `docs/design/normalization.md` Sections 2.1 and 6.3 | One row per final table with the form it appears in, the split, the dependency removed and the resulting key; column-movement table for the final split |
| In-class single-record trace | `docs/design/normalization.md` Section 11 | One daily record (unit `579236`, `2023-11-14`) and its 35 trips traced into `RIDER`, `COHORT`, `RIDER_UNIT`, `DAILY_OPERATIONS`, `FUEL_DAILY_COSTS` and `TRIPS`; non-applicable tables named |
| Many-to-many relationship resolved with a junction table | `RIDER_UNIT` in the ERD, normalization and data dictionary | `RIDER_UNIT` unique on (`rider_id`, `cohort_name`); 9 riders in all 3 cohorts, 98 in 2, 12 in 1 = 235 units |
| Logical ERD in crow’s-foot notation | `docs/design/erd.png` (source: `docs/design/erd.svg`) | 9 entities, PK/FK/UK badges, cardinality markers, legend and explanatory notes |
| No Oracle data types or sizes on the ERD | `docs/design/erd.png` | Column names and key roles only; logical types are in the data dictionary |
| Data dictionary | `docs/design/data_dictionary.md` | Every table, column, logical type, required/optional flag, unique constraint, foreign key, source mapping, transformation and business rule |
| Assumptions and limitations | `docs/design/normalization.md` Section 9; `docs/design/data_dictionary.md` Section 8; `data/dataset_card.md` Section 10 | Separate daily/trip facts, no trip fare, no event-level maintenance, optional coordinates, UTC+3, Phase IV alignment caveat |
| Cross-document consistency | This checklist and all deliverables | Same table names, keys, row counts and cohort labels throughout |
| Phase IV alignment warning | `README.md`, `docs/design/data_dictionary.md` Section 8.7, `docs/design/normalization.md` Section 10 | Current physical script uses `RIDER_UNITS` and `source_group`; the logical design extracts `COHORT`/`RIDER` and omits `source_group` |

## 2. Final numeric verification

| Check | Verified value |
|---|---:|
| Total data rows | 128,785 |
| Trip rows | 126,067 |
| Daily rows | 2,718 |
| Distinct riders (`source_user_id`) | 119 |
| Rider-cohort units | 235 |
| Unique raw field names | 23 |
| Baseline fuel daily rows / users | 1,480 / 118 |
| Control fuel daily rows / users | 1,150 / 108 |
| Electric treatment daily rows / users | 88 / 9 |
| Baseline trip rows / users | 68,325 / 118 |
| Control trip rows / users | 54,087 / 108 |
| Electric trip rows / users | 3,655 / 9 |
| Distinct dates | 26 (14 baseline + 12 transition) |
| Exact duplicate rows inside any one CSV | 0 |
| Same rider/date control/electric daily pairs | 88 |
| Identical control/electric pairs on all seven shared daily columns | 3 |
| Duplicated trip keys across control/electric | 3,655 (3,654 identical on all 15 fields, 1 differs) |
| Baseline trip rows missing at least one coordinate | 2,954 |
| Control trip rows missing at least one coordinate | 2,288 |
| Electric trip rows missing at least one coordinate | 174 |
| Baseline / control / electric absent unit-days | 172 / 146 / 20 |

## 3. Final document set

| Document | Purpose |
|---|---|
| `data/dataset_card.md` | Source, licence, integrity, record meaning, quality profile and limitations |
| `docs/design/normalization.md` | UNF → 1NF → 2NF → 3NF worksheet with real rows |
| `docs/design/erd.png` | Rendered logical ERD in crow’s-foot notation |
| `docs/design/erd.svg` | Editable vector source for the ERD |
| `docs/design/data_dictionary.md` | Full logical data dictionary |
| `docs/design/phase_ii_checklist.md` | This requirement-to-artefact map |
| `01_documentation/phase_II_design/*` | Working drafts updated to point to the final deliverables |
| `README.md` | Phase II summary and links |
| `06_submission/SUBMISSION_CHECKLIST.md` | Submission tracker updated for Phase II |

## 4. Sign-off

- [x] Raw data stored unchanged and integrity-checked.
- [x] Dataset card completed with quality counts.
- [x] Normalization completed with real rows and named dependencies.
- [x] In-class single-record trace prepared.
- [x] Many-to-many relationship resolved with `RIDER_UNIT`.
- [x] Logical ERD rendered in crow’s-foot notation without Oracle types.
- [x] Data dictionary completed for every table and column.
- [x] Cross-document consistency checked.
- [x] Phase IV alignment caveat documented.

**Phase II status: complete.**
