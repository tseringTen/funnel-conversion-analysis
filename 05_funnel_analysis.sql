-- Q1. Which channel brings in the most leads, and which channel actually converts them best?

-- Q1. Which channel brings in the most leads, and which channel actually converts them best?

SELECT 
    l.origin,
    COUNT(l.mql_id) AS total_leads,
    COUNT(d.mql_id) AS closed_deals,
    ROUND(COUNT(d.mql_id) * 100.0 / COUNT(l.mql_id), 2) AS conversion_rate
FROM the-name-498307-r7.project_funnel.mql_data l
LEFT JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
GROUP BY l.origin
ORDER BY conversion_rate DESC;

-- Finding: Conversion rate ranges 2.67%-16.65% by channel. "unknown" 
-- converts highest (16.65%), ahead of paid_search (12.3%) and 
-- organic_search (11.8%). Social has high volume (1,350) but weak 
-- conversion (5.56%). Email/other are weakest overall.

-- Insight: Untracked leads outperforming tracked ones suggests a 
-- tracking gap, not noise - possibly high-intent referral/word-of-mouth 
-- traffic. Social flagged as budget-review candidate, pending SDR/SR 
-- check to rule out a handling issue vs. true channel weakness.


-- Q2. Which landing pages have the highest conversion rate, not just the most traffic?
-- (HAVING filter excludes low-volume pages so results aren't skewed by small-sample noise)

SELECT 
    l.landing_page_id,
    COUNT(l.mql_id) AS total_leads,
    COUNT(d.mql_id) AS closed_deals,
    ROUND(COUNT(d.mql_id) * 100.0 / COUNT(l.mql_id), 2) AS conversion_rate
FROM the-name-498307-r7.project_funnel.mql_data l
LEFT JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
GROUP BY l.landing_page_id
HAVING COUNT(l.mql_id) >= 20
ORDER BY conversion_rate DESC;

-- Finding: Conversion rate still ranges 0%-25% after filtering low-volume 
-- pages. Both top-volume pages (912 & 883 leads) also rank near the top 
-- in conversion (18.75%, 19.71%) - not just high traffic, genuinely 
-- high quality. Weakest page with real volume converts at 0%.

-- Insight: top landing page is high-quality, not just high-volume. 
-- Worth studying what top pages do differently to replicate. Wide 
-- spread even among meaningful-volume pages shows landing page design 
-- is a real, independent lever - not just traffic source.


-- Q3. Which landing pages have real traffic but 0% conversion?

SELECT 
    l.landing_page_id,
    COUNT(l.mql_id) AS total_leads,
    COUNT(d.mql_id) AS closed_deals,
    ROUND(COUNT(d.mql_id) * 100.0 / COUNT(l.mql_id), 2) AS conversion_rate
FROM the-name-498307-r7.project_funnel.mql_data l
LEFT JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
GROUP BY l.landing_page_id
HAVING COUNT(l.mql_id) >= 20 
    AND COUNT(d.mql_id) = 0
ORDER BY total_leads DESC;

-- Finding: 15 landing pages have 20+ leads but converted zero deals. 
-- Worst offender: 49 leads, 0 closes. Several more in the 25-37 lead 
-- range, all at 0.0% conversion.

-- Insight: These pages are consuming meaningful lead volume (several 
-- hundred leads combined) with zero return - a direct candidate for 
-- audit or pause. Worth checking if these are tied to specific 
-- channels/campaigns from Q1 (e.g. are they disproportionately 
-- social or email?) to see if the channel or the page itself is the 
-- root cause.


-- Q4. Which SDRs and SRs have the highest individual conversion rates / handle the most deals?

SELECT
    sdr_id,
    COUNT(mql_id) AS total_deals
FROM the-name-498307-r7.project_funnel.closed_deals
GROUP BY sdr_id
ORDER BY total_deals DESC;

SELECT
    sr_id,
    COUNT(mql_id) AS total_deals
FROM the-name-498307-r7.project_funnel.closed_deals
GROUP BY sr_id
ORDER BY total_deals DESC;

-- Finding: Deal volume is highly concentrated. Top SDR closed 140 
-- deals (~16.6% of all 842), top SR closed 133 (~15.8%). Sharp 
-- drop-off after the top 5-6 reps on both sides; several reps at the 
-- bottom handled fewer than 5 deals total across the whole period.

-- Insight: This is a workload/reliance concentration, not yet a 
-- performance signal - can't call the top SDR "best" without knowing 
-- how many leads they were assigned in total. Worth flagging as a 
-- business risk either way - heavy reliance on a small number of 
-- SDRs and SRs for a large share of revenue-generating deals.


-- Q5. What's the average time-to-close, overall and by SDR/SR?

SELECT
    d.sdr_id,
    COUNT(d.mql_id) AS total_deals,
    ROUND(AVG(DATE_DIFF(DATE(d.won_date), l.first_contact_date, DAY)), 1) AS avg_days_to_close
FROM the-name-498307-r7.project_funnel.mql_data l
INNER JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
GROUP BY d.sdr_id
HAVING COUNT(d.mql_id) >= 20
ORDER BY avg_days_to_close ASC;

-- Note: HAVING count(d.mql_id) >= 20 excludes SDRs with too few deals 
-- to trust an average - unfiltered data showed extreme outliers 
-- (4 to 340 days) all coming from SDRs with just 1-3 deals, where a 
-- single fast/slow deal skews the average heavily. 20+ deals gives 
-- a stable, trustworthy average.

-- Finding: Among SDRs with 20+ deals, avg time-to-close ranges 18.3 
-- to 92.7+ days - still a wide, meaningful spread even after removing 
-- noise. Fastest: 55 deals, 18.3 days. Slowest visible: 25 deals, 
-- 92.7 days. Top-volume SDR (140 deals, from Q4) sits mid-pack at 33.6 days.

-- Insight: Deal volume and deal speed are different skills - the 
-- busiest SDR isn't the fastest closer. A ~5x gap in average close 
-- time (18 vs 92+ days) between reps with comparable deal counts 
-- points to a real process/skill difference worth investigating, 
-- not just workload variation.


SELECT
    d.sr_id,
    COUNT(d.mql_id) AS total_deals,
    ROUND(AVG(DATE_DIFF(DATE(d.won_date), l.first_contact_date, DAY)), 1) AS avg_days_to_close
FROM the-name-498307-r7.project_funnel.mql_data l
INNER JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
GROUP BY d.sr_id
HAVING COUNT(d.mql_id) >= 20
ORDER BY avg_days_to_close ASC;

-- Finding: Among SRs with 20+ deals, avg time-to-close ranges 17.0 
-- to 122.3 days - an even wider spread than SDRs. Fastest: 24 deals, 
-- 17.0 days. Slowest: 27 deals, 122.3 days - similar deal counts, 
-- ~7x difference in speed. Top-volume SR (133 deals, from Q4) closes 
-- at 30.5 days, near the faster end.

-- Insight: The gap between fastest and slowest SR (17 vs 122 days) 
-- is wider than the SDR spread, suggesting SR-side handling may have 
-- more impact on deal speed than SDR-side qualification. Worth 
-- checking in the next step whether slow SRs are disproportionately 
-- tied to specific channels/lead types, or if it's a rep-level issue.


-- Q6. Are social's underperforming deals handled by slower reps than unknown's?

WITH main AS (
    SELECT 
        d.sdr_id,
        ROUND(AVG(DATE_DIFF(DATE(d.won_date), l.first_contact_date, DAY)), 1) AS avg_days_to_close
    FROM the-name-498307-r7.project_funnel.mql_data l
    INNER JOIN the-name-498307-r7.project_funnel.closed_deals d 
        ON l.mql_id = d.mql_id
    GROUP BY d.sdr_id
    HAVING COUNT(d.mql_id) >= 20
)
SELECT
    l.origin,
    ROUND(AVG(m.avg_days_to_close), 1) AS channel_weighted_avg_speed,
    COUNT(d.mql_id) AS deals_closed
FROM the-name-498307-r7.project_funnel.mql_data l
INNER JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
INNER JOIN main m 
    ON d.sdr_id = m.sdr_id
WHERE l.origin IN ('social', 'unknown')
GROUP BY l.origin;

-- Finding: Social's closed deals were handled by reps averaging 40.6 
-- days to close; unknown's by reps averaging 38.6 days - only a 2-day 
-- gap, not meaningful against the ~18-92 day spread seen across all 
-- SDRs in Q5.

-- Insight: Rep handling speed does NOT explain social's weaker 
-- conversion rate (5.56% vs unknown's 16.65% from Q1) - both channels 
-- are worked by reps of similar average speed. This points toward 
-- social being a genuine lead-quality/fit issue rather than a sales 
-- execution problem - social leads may be lower-intent by nature of 
-- the channel, not mishandled by the team.


-- Q7. Row-level date integrity check

SELECT
    COUNT(*) AS bad_rows
FROM the-name-498307-r7.project_funnel.mql_data l
INNER JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
WHERE l.first_contact_date > DATE(d.won_date);

SELECT 
    l.mql_id, 
    l.first_contact_date, 
    d.won_date, 
    d.sdr_id, 
    d.sr_id
FROM the-name-498307-r7.project_funnel.mql_data l
INNER JOIN the-name-498307-r7.project_funnel.closed_deals d
    ON l.mql_id = d.mql_id
WHERE l.first_contact_date > DATE(d.won_date);

-- Finding: 1 out of 842 closed deals has a won_date earlier than its 
-- own first_contact_date - a logical impossibility (can't close a 
-- deal before the lead made contact).

-- Insight: Isolated data quality issue (1/842 = 0.12%), doesn't 
-- affect overall conclusions, but worth identifying and excluding 
-- from date-based calculations (e.g. Q5 time-to-close averages) 
-- rather than letting it silently distort results.


-- Q8. Does lead_behaviour_profile correlate with deal speed?

SELECT 
    d.lead_behaviour_profile,
    COUNT(d.mql_id) AS total_deals,
    ROUND(AVG(DATE_DIFF(DATE(d.won_date), l.first_contact_date, DAY)), 1) AS avg_days_to_close
FROM the-name-498307-r7.project_funnel.mql_data l
INNER JOIN the-name-498307-r7.project_funnel.closed_deals d 
    ON l.mql_id = d.mql_id
WHERE l.first_contact_date <= DATE(d.won_date)
GROUP BY d.lead_behaviour_profile
ORDER BY avg_days_to_close ASC;

-- Finding: Eagle (123 deals, 36.0 days), not_specified (177, 39.4), 
-- and cat (406, 40.8) close fastest. Wolf (95, 83.9) and shark 
-- (24, 75.4) take more than double the time. Mixed (16, 190.8) is 
-- slowest by far but smallest sample - treat cautiously.

-- Insight: Eagle-profile leads close ~2.3x faster than wolf-profile 
-- leads despite similar-magnitude sample sizes (123 vs 95) - this 
-- looks like a real pattern, not noise. Matches the DISC framework: 
-- Eagles are decisive/fast-moving by nature, Wolves are 
-- relationship-driven and likely need more touchpoints/trust-building 
-- before committing. Practical implication: SDRs could fast-track 
-- eagle-profile leads and set different timeline expectations for 
-- wolf-profile leads rather than treating all leads with a uniform 
-- follow-up cadence.
