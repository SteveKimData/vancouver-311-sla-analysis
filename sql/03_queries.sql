-- SLA compliance rate by month (time series)
SELECT
    STRFTIME('%Y-%m', DATE(open_date)) AS year_month,
    COUNT(*) FILTER (WHERE is_closed = 1) AS closed_tickets,
    ROUND(AVG(sla_met_7d) FILTER (WHERE is_closed = 1) * 100, 2) AS sla_rate
FROM vanc_analysis_layer
GROUP BY year_month
ORDER BY year_month


  

  
-- SLA rate by service request type within worst departments (lowest aggregation layer)
SELECT
    department_code,
    srt,
    COUNT(*) FILTER (WHERE is_closed = 1) AS closed_tickets,
    ROUND(AVG(sla_met_7d) FILTER (WHERE is_closed = 1) * 100, 2) AS sla_rate
FROM vanc_analysis_layer
WHERE department_code IN ('PDS', 'PR', 'DBL')
AND is_closed = 1
GROUP BY department_code, srt
HAVING closed_tickets >= 50
ORDER BY department_code, sla_rate ASC




  
-- Channel (type of communication) breakdown
SELECT
    channel,
    COUNT(*) AS total_closed,
    ROUND(SUM(sla_met_7d) * 100.0 / COUNT(*), 2) AS sla_pct,
    ROUND(
        (COUNT(*) - SUM(sla_met_7d)) * 100.0 /
        (SELECT SUM(CASE WHEN is_closed = 1 THEN 1 - sla_met_7d ELSE 0 END)
         FROM vanc_analysis_layer),
        2
    ) AS pct_of_total_misses
FROM vanc_analysis_layer
WHERE is_closed = 1
GROUP BY channel
ORDER BY sla_pct




  
-- Percentage of SLA compliance rate by department name (sub-department, aggregation level 2)
-- Also shows percentage of total misses, indicates volume and percentage of total SLA non-compliance of dataset
SELECT
    department_code,
    department_name,
    COUNT(*) AS total_closed,
    SUM(sla_met_7d) AS sla_met,
    COUNT(*) - SUM(sla_met_7d) AS sla_missed,
    ROUND(SUM(sla_met_7d) * 100.0 / COUNT(*), 2) AS sla_pct,
    ROUND(
        (COUNT(*) - SUM(sla_met_7d)) * 100.0 /
        (SELECT SUM(CASE WHEN is_closed = 1 THEN 1 - sla_met_7d ELSE 0 END)
         FROM vanc_analysis_layer),
        2
    ) AS pct_of_total_misses
FROM vanc_analysis_layer
WHERE is_closed = 1
GROUP BY department_code, department_name
HAVING COUNT(*) >= 200
ORDER BY sla_pct
