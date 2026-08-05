# Marketing Funnel & Sales Conversion Analysis

End-to-end analysis of a B2B seller-acquisition funnel — from raw leads to closed deals — built with Python, SQL (BigQuery), and Power BI. The project tests whether weak conversion in a marketing channel is a lead-quality problem or a sales-handling problem, and answers with data instead of assumption.

**Dataset:** [Marketing Funnel by Olist](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist) (Kaggle) — 8,000 marketing qualified leads (MQLs) and 842 closed deals from Olist, a Brazilian marketplace, collected June 2017–June 2018.

---

## Business questions

This project is framed around two linked lenses, not just "explore the data":

1. **Marketing ROI** — which acquisition channels and landing pages are actually worth the spend, beyond raw lead volume?
2. **Sales efficiency** — how much of the conversion story is explained by how leads are handled, not just where they came from?
3. **The combined test** — when a channel underperforms, is it the channel's fault or the sales team's?

---

## Tools

| Stage | Tool |
|---|---|
| Data cleaning & integrity checks | Python (Pandas) |
| Business-question analysis | SQL (BigQuery) |
| Interactive dashboard | Power BI |

---

## Project structure

```
├── python/
│   └── data_cleaning.ipynb        # Cleaning, validation, and feature checks on both tables
├── sql/
│   └── funnel_analysis.sql        # All 8 business questions, with inline findings
├── powerbi/
│   └── funnel_conversion_dashboard.pbix
├── report/
│   └── Marketing_Funnel_Analysis_Report.docx   # Full write-up: findings, insights, recommendations
└── README.md
```

---

## Data cleaning highlights (Python)

- Verified lead ID and seller ID uniqueness in both tables before joining — zero duplicates, safe join keys.
- `origin` had 60 blank values, merged with 1,099 pre-existing "unknown" entries — both represent the same underlying meaning (no tracked channel), so they were combined rather than treated as separate categories.
- Four low-null categorical columns filled with an explicit `not_specified` placeholder instead of the column mode, to avoid fabricating a specific category with no supporting evidence.
- Four columns (company registration, product barcodes, average stock, catalog size) were missing in over 90% of rows and excluded from all analysis entirely.
- **Caught a disguised missing-value issue:** `declared_monthly_revenue` showed an exact value of `0` in 797 of 842 rows (94.7%), spread evenly across 235 different business-segment combinations with no realistic clustering pattern. Diagnosed as a system default for a skipped optional field — not a genuine self-report — converted to null, and excluded from analysis.
- 16 leads were tagged with more than one behaviour profile (e.g. `"cat, wolf"`) — bucketed as a distinct `mixed` category rather than merged into `not_specified`, since the two mean different things (no data vs. conflicting data).
- One closed deal showed a `won_date` earlier than its own `first_contact_date` — a logical impossibility. Excluded from the dataset (final closed-deal count: **841**).

---

## Key findings (SQL)

**1. Channel conversion varies from 2.67% to 16.65%.** Untracked ("unknown") leads convert best, ahead of `paid_search` (12.3%) and `organic_search` (11.8%). `social` carries strong lead volume (1,350, 3rd highest) but converts at just 5.56%.

**2. The top landing page isn't just high-volume — it's genuinely high-quality.** The two highest-traffic pages (912 and 883 leads) also rank near the top on conversion rate (18.75% and 19.71%). Meanwhile, pages with nearly identical traffic can differ in conversion rate by more than 2x — proof that landing page design is its own lever, independent of channel.

**3. Rep handling speed does NOT explain social's weak conversion.** Social's closed deals were handled by reps averaging 40.6 days to close; the best-performing channel's ("unknown") deals were handled by reps averaging 38.6 days — a 2-day gap, not meaningful against the 18–92 day spread seen across all reps. This rules out a sales-execution explanation and points to a lead-quality issue instead.

**4. Deal volume is concentrated among a few reps.** The top SDR closed ~16.6% of all deals; the top SR closed ~15.8%. A real business-continuity consideration.

**5. Lead behaviour profile predicts deal speed.** Leads profiled as "Eagle" (decisive, fast-moving) close 2.3x faster than "Wolf" profile leads (relationship-driven, need more touchpoints) — a concrete, low-cost case for routing leads differently rather than a uniform follow-up process.

Full breakdown, all 8 questions with findings and recommendations: see [`/report`](./report).

---

## Dashboard

An interactive Power BI dashboard built on the two cleaned tables (joined natively on lead ID, one-to-one relationship), with all metrics calculated live via DAX — filterable by date range and channel.

![Funnel Conversion Dashboard](./powerbi/dashboard_screenshot.png)

- 4 KPI cards (Total Leads, Total Closed Deals, Conversion Rate, Avg Days to Close)
- Conversion rate by channel
- Average days to close by SDR (filtered to reps with 20+ deals, to exclude small-sample noise)
- Landing page performance table, sorted by conversion rate

---

## Limitations

- "Conversion" is defined as a deal marked *won* in the sales process (i.e., a seller account was created) — this analysis does not verify whether those sellers went on to list products or generate actual sales, which would require joining the broader Brazilian E-Commerce dataset.
- Five columns with over 90% missing data (company registration, product barcodes, average stock, catalog size, declared monthly revenue) were excluded from all analysis rather than imputed.
- Lead behaviour profile is assigned subjectively by the SDR during qualification and was not independently validated for consistency across reps.

---

## Author

Tenzing Tsering Bhutia 
linkedin.com/in/tenzing-tsering-2a69a2202
