-- This view is the structural cleaning layer made with the columns relevant to our business question
-- Column names have been simplified 
-- Department parsed into department code and department name columns
-- Date formatting is consistent (normalization)
-- Standardizes NULLS from empty strings
CREATE VIEW vanc_clean_view AS 
SELECT 
	department,
	CASE WHEN INSTR(department, '-') > 0 
    THEN TRIM(SUBSTR(department, 1, INSTR(department, '-') - 1))
    ELSE NULL 
    END AS department_code,
	CASE WHEN INSTR(department, '-') > 0
	THEN TRIM(SUBSTR(department, INSTR(department, '-') + 1))
	ELSE TRIM(department)
	END AS department_name,
	"Service request type" AS srt,
	status,
	channel,
	JULIANDAY(SUBSTR("Service request open timestamp",1,10)) AS open_date,
	JULIANDAY(SUBSTR("Service request close date",1,10)) AS close_date,
	NULLIF(TRIM("Local area"), '') AS local_area
FROM "311_vancouver"
