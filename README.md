# Vancouver 311 SLA Performance Analysis

**Business Question:** What percentage of service requests are resolved within 7 days, and which departments and request types miss this threshold most often?

[View Live Dashboard](https://stevekimdata.github.io/vancouver-311-sla-analysis/dashboard/vancouver_311_dashboard.html)

---

## Overview

This analysis evaluates resolution time performance across Vancouver's 311 service request system as a proxy for service delivery friction. Departments with low SLA compliance and high contribution to total missed targets are identified as candidates for operational review.

The dataset contains approximately 880,000 closed service requests submitted between August 2022 and February 2026, sourced from the [City of Vancouver Open Data Portal](https://opendata.vancouver.ca/explore/dataset/3-1-1-service-requests/table/?disjunctive.service_request_type&disjunctive.status&disjunctive.channel&disjunctive.local_area&disjunctive.department&disjunctive.closure_reason). The analytical grain is one row per closed service request.

Analysis shows that overall SLA compliance is 74.50% but with 35.15% of missed volume is heavily concentrated in departments DBL and PR, with a small structural anomaly in PDS.

---

## Tools

- **SQL (SQLite)** — data cleaning, transformation, and analysis
- **Dashboard** — interactive visualization built on analysis outputs, AI assisted

---

## Data Cleaning and Assumptions

- Open and close date fields were stored in different formats and were normalized to Julian date format for consistent arithmetic
- Time of day components were removed from open timestamps to match the granularity of close date fields; resolution time is measured in calendar days
- The `local_area` field contained empty strings instead of NULLs, which were standardized
- The `department` field contained mixed formatting with and without prefix codes; these were conditionally parsed into `department_code` and `department_name` columns
- 27 records (0.003%) with negative response durations were excluded as data integrity anomalies; these represent a negligible portion of total ticket volume and do not materially affect system-wide metrics
- 11,637 open tickets (1.3%) were excluded from SLA calculations as final resolution time is unknown
- Departments with fewer than 200 closed tickets were excluded from comparative ranking to avoid small sample distortion; these represent less than 0.07% of total ticket volume and therefore do not materially affect system-wide metrics

---

## SLA Benchmark

A **7-day resolution window** was selected as the SLA benchmark. This threshold provides a consistent, measurable baseline for comparative analysis across departments.

Whether 7 calendar days is structurally appropriate for all department types is an open question and a core limitation of this analysis. Engineering and regulatory departments involve coordination, legal review, and physical constraints that may inherently exceed this threshold regardless of operational efficiency. Establishing formal tiered SLA targets by department complexity is itself a recommendation of this analysis.

---

## Key Findings

- **74.5%** of closed requests were resolved within 7 days overall
- Performance has been broadly stable (about 62-80%) across the 3+ year period, indicating that underperformance is structural rather than a recent degradation
- The October 2025 onward period shows incomplete data windows and should not be interpreted as performance improvement
- **DBL and PR are the primary drivers of missed SLA volume**, contributing 25.52% and 9.63% of total system-wide misses respectively; targeting workflow improvements in these two departments would materially improve aggregate compliance
- **PDS contributes only 0.36% of total missed volume** but contains an extreme underperforming request type, warranting targeted investigation rather than broad operational remediation
- Within DBL, two request types drive the majority of missed volume: Building and Development Inquiry (81,895 tickets, 57% SLA) and Business Licence Request (49,599 tickets, 61% SLA)
- Within PR, City and Park Trees Maintenance alone accounts for 36,000+ tickets at 60% SLA — a single request type dragging the entire department. Improving tree maintenance SLA by 10 percentage points would materially raise system-wide SLA compliance.
- Within PDS, the Business Support Request Case (312 tickets, 6.73% SLA) shows clear underperformance relative to the departmental baseline and warrants direct investigation
- Submission channel has a negligible effect on SLA outcomes; WEB drives 51% of total misses due to volume, not underperformance

---

## Limitations

- The 7-day SLA benchmark is uniform and may not reflect realistic targets for complex or regulated request types
- 21.29% of records lack local area attribution; geographic analysis would require spatial imputation via boundary shapefiles, which was excluded to maintain analytical scope
- Open tickets are excluded from all SLA calculations; if open ticket resolution patterns differ systematically from closed tickets, aggregate metrics may be biased

---

## Recommendations

1. **Targeted workflow review for DBL and PR departments** — specifically Building/Development Inquiry, Business Licence Request, and City and Park Trees Maintenance; these three request types collectively account for a disproportionate share of total missed SLA volume
2. **Investigate PDS Business Support Request Case** as an isolated anomaly distinct from the volume-driven underperformance in DBL and PR
3. **Establish tiered SLA benchmarks by department complexity category** — administrative, operational, and regulatory — with targets set through consultation with department leads rather than a uniform threshold
4. **Test for seasonality in PR** — outdoor maintenance workflows are likely weather-dependent and may warrant seasonally adjusted targets

---

## Repository Structure

```
vancouver-311-sla-analysis/
│
├── README.md
├── data/
│   ├── Channel_breakdown.csv
│   ├── Department_ranking.csv
│   ├── sla_worst_deps.csv
│   └── Time_series.csv
├── sql/
│   ├── 01_cleaning_view.sql
│   ├── 02_analysis_layer.sql
│   └── 03_queries.sql
└── dashboard/
    └── vancouver_311_dashboard.html
```

---

*Data source: [City of Vancouver Open Data — 311 Service Requests](https://opendata.vancouver.ca/explore/dataset/3-1-1-service-requests/table/?disjunctive.service_request_type&disjunctive.status&disjunctive.channel&disjunctive.local_area&disjunctive.department&disjunctive.closure_reason)*
