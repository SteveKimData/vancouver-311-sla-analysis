-- Analysis table where status is classified and SLA metric (binary operator) is prepared
-- Removed 27 rows where ticket close date was faster than ticket open date.
CREATE VIEW vanc_analysis_layer AS
SELECT *,
	(close_date - open_date) AS response_days,
	CASE WHEN status = 'Close' 
	THEN 1 
	ELSE 0 
	END AS is_closed,
	--UNDER HERE IS THE SLA DENOMINATOR (ALL ROWS USED IN DATA showing 1)
	CASE WHEN (close_date - open_date) <= 7
	THEN 1
	ELSE 0
	END AS sla_met_7d 
FROM vanc_clean_view
WHERE response_days >= 0
