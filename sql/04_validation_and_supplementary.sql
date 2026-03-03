-- VALIDATION LAYER

-- shows number and percent of null rows compared to total rows of the table over the column "local area"
-- It is quite high at 21.29%
SELECT 
COUNT(*) AS total_rows,
SUM(CASE WHEN local_area IS NULL THEN 1 ELSE 0 END) AS null_rows,
ROUND(SUM(CASE WHEN local_area IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS perc
FROM vanc_clean_view
LIMIT 100;


-- Shows the number and percentage of open tickets compared to the whole dataset.
-- It is around 1.3 percent
SELECT 
SUM(CASE WHEN status LIKE 'Close' THEN 1 ELSE 0 END) AS closed_tickets,
SUM(CASE WHEN status LIKE 'Open' THEN 1 ELSE 0 END) AS open_tickets,
ROUND(SUM(CASE WHEN status = 'Open' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS perc
FROM vanc_clean_view 


-- This is a validation check to see if departments with code were seperated properly (this only counts with departmants that have a CODE)
-- Returns the same number of 843593
SELECT 
SUM(CASE WHEN INSTR(department, '-') > 0 THEN 1 ELSE 0 END) AS has_code,
COUNT(department_code) AS deps_with_code
FROM vanc_clean_view


-- Validation check to see if the ticket close date was sooner than the open date. (returned 27 rows)
SELECT 
COUNT(*),
SUM(CASE WHEN (close_date - open_date) < 0 
THEN 1
ELSE 0
END) AS neg_days
FROM vanc_clean_view


-- To check for outliers 
-- There were about 3185 tickets that took longer than 500 days to close, or about 11.09 percent
SELECT 
SUM(CASE WHEN (close_date - open_date) > 500 THEN 1 ELSE 0 END) AS outlier_days_500,
ROUND(AVG(close_date - open_date),2)
FROM vanc_clean_view


-- Confirming the number of closed tickets are the same as the total number of tickets - open
-- Confirmed, returning the same number of 885673
SELECT 
COUNT(close_date) AS closed_tickets,
COUNT(*) - SUM(CASE WHEN is_closed = 0 THEN 1 ELSE 0 END) AS total_minus_open
FROM vanc_analysis_layer


-- Checks for nulls and empty strings in the (communication) channels column as well as number of distinct values
-- 0 empty string values, matching total and non_null values, 10 distinct values
SELECT 
COUNT(*) AS total,
COUNT(channel) AS non_null,
SUM(CASE WHEN TRIM(channel) = '' THEN 1 ELSE 0 END) AS empty_string,
COUNT(DISTINCT channel) AS distinct_values
FROM vanc_analysis_layer






-- EXTRA ANALYSIS AND CALCULATIONS LAYER

-- overall SLA calculation
SELECT
ROUND(100.0 * SUM(sla_met_7d) / COUNT(*), 2) AS sla_met_percent
FROM vanc_analysis_layer
WHERE is_closed = 1;



-- Gives total closed and the percent of tickets that meet the SLA guideline
SELECT
    department_code,
    COUNT(*) AS total_closed,
    ROUND(SUM(sla_met_7d) * 100.0 / COUNT(*), 2) AS sla_pct
FROM vanc_analysis_layer
WHERE is_closed = 1
GROUP BY department_code
ORDER BY sla_pct;




-- Distribution and sensitivity analysis
-- seeing the ticket percentage of all departments collectively having a closed ticket count of < 200
SELECT 
    SUM(total_closed) * 100.0 / 
    (SELECT COUNT(*) FROM vanc_analysis_layer WHERE is_closed = 1)
FROM (
    SELECT COUNT(*) AS total_closed
    FROM vanc_analysis_layer
    WHERE is_closed = 1
    GROUP BY department_name
    HAVING COUNT(*) < 200
);




-- SLA rate by service request type and percentage of total misses within worst - performing depart codes. (Highest level aggregation)
SELECT
    department_code,
    srt,
    COUNT(*) FILTER (WHERE is_closed = 1) AS closed_tickets,
    ROUND(AVG(sla_met_7d) FILTER (WHERE is_closed = 1) * 100, 2) AS sla_rate,
    ROUND(
        (COUNT(*) - SUM(sla_met_7d)) * 100.0 /
        (SELECT SUM(CASE WHEN is_closed = 1 THEN 1 - sla_met_7d ELSE 0 END)
         FROM vanc_analysis_layer),
        2
    ) AS pct_of_total_misses
FROM vanc_analysis_layer
WHERE department_code IN ('PDS', 'PR', 'DBL')
AND is_closed = 1
GROUP BY department_code
HAVING closed_tickets >= 50
ORDER BY department_code, sla_rate ASC

