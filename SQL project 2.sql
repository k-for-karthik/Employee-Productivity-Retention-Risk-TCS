-- database creation
CREATE DATABASE IF NOT EXISTS employee_analytics;

-- Table creation
CREATE TABLE employee_analytics.employee_attendance (
    employee_id VARCHAR(10),
    full_name VARCHAR(100),
    department VARCHAR(50),
    designation VARCHAR(50),
    employment_type VARCHAR(50),
    shift_type VARCHAR(50),
    work_mode VARCHAR(50),
    date DATE,
    clock_in_time TIME,
    clock_out_time TIME,
    total_work_hours DECIMAL(4,2),
    tasks_completed INT,
    productivity_score DECIMAL(5,2),
    absent BOOLEAN,
    overtime_hours DECIMAL(4,2),
    leave_type VARCHAR(50),
    late_login BOOLEAN,
    early_logout BOOLEAN,
    project_deadlines_missed INT,
    burnout_risk_score DECIMAL(5,2),
    manager_id VARCHAR(10),
    location VARCHAR(50),
    salary_band VARCHAR(50),
    performance_rating DECIMAL(3,2),
    years_with_company DECIMAL(3,1),
    reason_for_leave VARCHAR(255)
);


-- Data Exploration and Data Cleaning
SELECT COUNT(*) FROM employee_analytics.employee_attendance;

-- Check for duplicate records based on all columns
SELECT employee_id, date, COUNT(*) AS duplicate_count
FROM employee_analytics.employee_attendance
GROUP BY employee_id, date
HAVING COUNT(*) > 1;

SELECT * 
FROM employee_analytics.employee_attendance
WHERE date = 0000-00-00;

UPDATE employee_analytics.employee_attendance
SET date = NULL
WHERE date = 0000-00-00;

WITH duplicate_rows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY employee_id, date ORDER BY employee_id) AS row_num
    FROM employee_analytics.employee_attendance
)
DELETE FROM employee_analytics.employee_attendance
WHERE (employee_id, date) IN (
    SELECT employee_id, date
    FROM duplicate_rows
    WHERE row_num > 1
);

SELECT employee_id, date, COUNT(*) AS duplicate_count
FROM employee_analytics.employee_attendance
GROUP BY employee_id, date
HAVING COUNT(*) > 1;


SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN TRIM(employee_id) = '' OR employee_id IS NULL THEN 1 ELSE 0 END) AS blank_or_null_employee_id,
    SUM(CASE WHEN TRIM(full_name) = '' OR full_name IS NULL THEN 1 ELSE 0 END) AS blank_or_null_full_name,
    SUM(CASE WHEN TRIM(department) = '' OR department IS NULL THEN 1 ELSE 0 END) AS blank_or_null_department,
    SUM(CASE WHEN TRIM(designation) = '' OR designation IS NULL THEN 1 ELSE 0 END) AS blank_or_null_designation,
    SUM(CASE WHEN TRIM(employment_type) = '' OR employment_type IS NULL THEN 1 ELSE 0 END) AS blank_or_null_employment_type,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN TRIM(clock_in_time) = '' OR clock_in_time IS NULL THEN 1 ELSE 0 END) AS blank_or_null_clock_in_time,
    SUM(CASE WHEN TRIM(clock_out_time) = '' OR clock_out_time IS NULL THEN 1 ELSE 0 END) AS blank_or_null_clock_out_time,
    SUM(CASE WHEN total_work_hours IS NULL THEN 1 ELSE 0 END) AS null_total_work_hours,
    SUM(CASE WHEN TRIM(tasks_completed) = '' OR tasks_completed IS NULL THEN 1 ELSE 0 END) AS blank_or_null_tasks_completed,
    SUM(CASE WHEN TRIM(productivity_score) = '' OR productivity_score IS NULL THEN 1 ELSE 0 END) AS blank_or_null_productivity_score
FROM employee_analytics.employee_attendance;

SELECT * 
FROM employee_analytics.employee_attendance 
WHERE employee_id IS NULL OR TRIM(employee_id) = '';

UPDATE employee_analytics.employee_attendance ea
JOIN (
    SELECT full_name, MAX(employee_id) AS valid_id
    FROM employee_analytics.employee_attendance
    WHERE employee_id IS NOT NULL AND TRIM(employee_id) <> ''
    GROUP BY full_name
) subquery
ON ea.full_name = subquery.full_name
SET ea.employee_id = subquery.valid_id
WHERE ea.employee_id IS NULL OR TRIM(ea.employee_id) = '';

SELECT * FROM employee_analytics.employee_attendance 
WHERE department IS NULL OR TRIM(department) = '';

UPDATE employee_analytics.employee_attendance ea
JOIN (
    SELECT employee_id, MAX(department) AS valid_department
    FROM employee_analytics.employee_attendance
    WHERE department IS NOT NULL AND TRIM(department) <> ''
    GROUP BY employee_id
) subquery
ON ea.employee_id = subquery.employee_id
SET ea.department = subquery.valid_department
WHERE ea.department IS NULL OR TRIM(ea.department) = '';

SELECT * FROM employee_analytics.employee_attendance 
WHERE date IS NULL;

DELETE FROM employee_analytics.employee_attendance 
WHERE date IS NULL;

SELECT * FROM employee_analytics.employee_attendance 
WHERE clock_in_time = '00:00:00' and clock_out_time = '00:00:00';

ALTER TABLE employee_analytics.employee_attendance  
DROP COLUMN full_name;

SELECT DISTINCT employment_type FROM employee_analytics.employee_attendance;
SELECT DISTINCT shift_type FROM employee_analytics.employee_attendance;
SELECT DISTINCT work_mode FROM employee_analytics.employee_attendance;
SELECT DISTINCT salary_band FROM employee_analytics.employee_attendance;

SELECT * FROM employee_analytics.employee_attendance
WHERE total_work_hours < 0 OR total_work_hours > 24 
   OR productivity_score < 0 OR productivity_score > 100
   OR overtime_hours < 0;

SELECT * FROM employee_analytics.employee_attendance  
WHERE TRIM(salary_band) = '';

UPDATE employee_analytics.employee_attendance ea
JOIN (
    SELECT employee_id, MAX(salary_band) AS valid_salary_band
    FROM employee_analytics.employee_attendance
    WHERE salary_band IS NOT NULL AND TRIM(salary_band) <> ''
    GROUP BY employee_id
) subquery
ON ea.employee_id = subquery.employee_id
SET ea.salary_band = subquery.valid_salary_band
WHERE TRIM(ea.salary_band) = '';

SELECT 
    SUM(CASE WHEN TRIM(employee_id) = '' OR employee_id IS NULL THEN 1 ELSE 0 END) AS blank_or_null_employee_id,
    SUM(CASE WHEN TRIM(department) = '' OR department IS NULL THEN 1 ELSE 0 END) AS blank_or_null_department,
    SUM(CASE WHEN TRIM(designation) = '' OR designation IS NULL THEN 1 ELSE 0 END) AS blank_or_null_designation,
    SUM(CASE WHEN TRIM(employment_type) = '' OR employment_type IS NULL THEN 1 ELSE 0 END) AS blank_or_null_employment_type,
    SUM(CASE WHEN TRIM(shift_type) = '' OR shift_type IS NULL THEN 1 ELSE 0 END) AS blank_or_null_shift_type,
    SUM(CASE WHEN TRIM(work_mode) = '' OR work_mode IS NULL THEN 1 ELSE 0 END) AS blank_or_null_work_mode,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN TRIM(clock_in_time) = '' OR clock_in_time IS NULL THEN 1 ELSE 0 END) AS blank_or_null_clock_in_time,
    SUM(CASE WHEN TRIM(clock_out_time) = '' OR clock_out_time IS NULL THEN 1 ELSE 0 END) AS blank_or_null_clock_out_time,
    SUM(CASE WHEN total_work_hours IS NULL THEN 1 ELSE 0 END) AS null_total_work_hours,
    SUM(CASE WHEN TRIM(tasks_completed) = '' OR tasks_completed IS NULL THEN 1 ELSE 0 END) AS blank_or_null_tasks_completed,
    SUM(CASE WHEN TRIM(productivity_score) = '' OR productivity_score IS NULL THEN 1 ELSE 0 END) AS blank_or_null_productivity_score,
    SUM(CASE WHEN absent IS NULL THEN 1 ELSE 0 END) AS null_absent,
    SUM(CASE WHEN TRIM(leave_type) = '' OR leave_type IS NULL THEN 1 ELSE 0 END) AS blank_or_null_leave_type,
    SUM(CASE WHEN TRIM(late_login) = '' OR late_login IS NULL THEN 1 ELSE 0 END) AS blank_or_null_late_login,
    SUM(CASE WHEN TRIM(early_logout) = '' OR early_logout IS NULL THEN 1 ELSE 0 END) AS blank_or_null_early_logout,
    SUM(CASE WHEN TRIM(manager_id) = '' OR manager_id IS NULL THEN 1 ELSE 0 END) AS blank_or_null_manager_id,
    SUM(CASE WHEN TRIM(location) = '' OR location IS NULL THEN 1 ELSE 0 END) AS blank_or_null_location,
    SUM(CASE WHEN TRIM(performance_rating) = '' OR performance_rating IS NULL THEN 1 ELSE 0 END) AS blank_or_null_performance_rating,
    SUM(CASE WHEN TRIM(years_with_company) = '' OR years_with_company IS NULL THEN 1 ELSE 0 END) AS blank_or_null_years_with_company,
    SUM(CASE WHEN TRIM(reason_for_leave) = '' OR reason_for_leave IS NULL THEN 1 ELSE 0 END) AS blank_or_null_reason_for_leave
FROM employee_analytics.employee_attendance;

SELECT COUNT(*) 
FROM employee_analytics.employee_attendance  
WHERE (leave_type IS NULL OR TRIM(leave_type) = '')  
AND absent = False;

SELECT * FROM employee_analytics.employee_attendance  
WHERE manager_id IS NULL OR TRIM(manager_id) = '';

UPDATE employee_analytics.employee_attendance ea  
JOIN (  
    SELECT employee_id, MAX(manager_id) AS valid_manager  
    FROM employee_analytics.employee_attendance  
    WHERE manager_id IS NOT NULL AND TRIM(manager_id) <> ''  
    GROUP BY employee_id  
) subquery  
ON ea.employee_id = subquery.employee_id  
SET ea.manager_id = subquery.valid_manager  
WHERE ea.manager_id IS NULL OR TRIM(ea.manager_id) = '';

SELECT COUNT(*)  
FROM employee_analytics.employee_attendance  
WHERE (reason_for_leave IS NULL OR TRIM(reason_for_leave) = '')  
AND absent = TRUE;


-- Basic EDA
SELECT 
    COUNT(DISTINCT employee_id) AS total_employees,
    COUNT(DISTINCT department) AS total_departments,
    COUNT(DISTINCT designation) AS total_designations,
    COUNT(*) AS total_records,
    SUM(CASE WHEN absent = TRUE THEN 1 ELSE 0 END) AS total_absent_days,
    SUM(CASE WHEN work_mode = 'Work From Home' THEN 1 ELSE 0 END) AS total_wfh_days,
    AVG(productivity_score) AS avg_productivity_score
FROM employee_analytics.employee_attendance;

-- Avg productivity per employee
SELECT 
    employee_id,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY employee_id
ORDER BY avg_productivity
limit 3;

-- Dept with highest absenteeism rate
SELECT 
    department,
    COUNT(CASE WHEN absent = TRUE THEN 1 END) AS total_absent_days,
    COUNT(*) AS total_work_days,
    ROUND((COUNT(CASE WHEN absent = TRUE THEN 1 END) / COUNT(*)) * 100, 2) AS absenteeism_rate
FROM employee_analytics.employee_attendance
GROUP BY department
ORDER BY absenteeism_rate DESC;

SELECT COUNT(*) 
FROM employee_analytics.employee_attendance
WHERE clock_in_time = '00:00:00' 
AND clock_out_time = '00:00:00' 
AND absent = FALSE;

UPDATE employee_analytics.employee_attendance
SET absent = TRUE
WHERE clock_in_time = '00:00:00' 
AND clock_out_time = '00:00:00';

-- Does Work-From-Home Affect Employee Performance?
SELECT 
    work_mode,
    COUNT(*) AS total_days,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY work_mode
ORDER BY avg_productivity DESC;

-- Work-From-Home Productivity by Department
SELECT 
    department,
    work_mode,
    COUNT(*) AS total_days,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY department, work_mode
ORDER BY department, avg_productivity DESC;

-- Does Overtime Impact Productivity?
SELECT 
    CASE 
        WHEN overtime_hours = 0 THEN 'No Overtime'
        WHEN overtime_hours BETWEEN 0.01 AND 2 THEN 'Low Overtime (0-2 hrs)'
        WHEN overtime_hours BETWEEN 2.01 AND 4 THEN 'Moderate Overtime (2-4 hrs)'
        ELSE 'High Overtime (>4 hrs)'
    END AS overtime_category,
    COUNT(*) AS total_days,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY overtime_category
ORDER BY avg_productivity DESC;

-- Does Missing Project Deadlines Affect Productivity?
SELECT 
    CASE 
        WHEN project_deadlines_missed = 0 THEN 'No Deadlines Missed'
        WHEN project_deadlines_missed BETWEEN 1 AND 2 THEN 'Few Missed (1-2)'
        WHEN project_deadlines_missed BETWEEN 3 AND 5 THEN 'Moderate Missed (3-5)'
        ELSE 'High Missed (>5)'
    END AS deadline_category,
    COUNT(*) AS total_days,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY deadline_category
ORDER BY avg_productivity DESC;

-- How Does Burnout Risk Affect Productivity?
SELECT 
    CASE 
        WHEN burnout_risk_score < 40 THEN 'Low Burnout Risk'
        WHEN burnout_risk_score BETWEEN 40 AND 70 THEN 'Moderate Burnout Risk'
        ELSE 'High Burnout Risk'
    END AS burnout_category,
    COUNT(*) AS total_days,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY burnout_category
ORDER BY avg_productivity DESC;

-- Performance Rating & Productivity
-- Analyzing the impact of performance rating on productivity
SELECT 
    CASE 
        WHEN performance_rating >= 4.5 THEN 'Outstanding (4.5 - 5.0)'
        WHEN performance_rating >= 3.5 THEN 'Above Average (3.5 - 4.49)'
        WHEN performance_rating >= 2.5 THEN 'Average (2.5 - 3.49)'
        ELSE 'Below Average (0 - 2.49)'
    END AS performance_category,
    COUNT(*) AS total_employees,
    ROUND(AVG(productivity_score), 2) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY performance_category
ORDER BY avg_productivity DESC;

-- productivity trends by weekday:
SELECT 
    DAYNAME(date) AS weekday, 
    ROUND(AVG(productivity_score), 2) AS avg_productivity,
    COUNT(*) AS total_days
FROM employee_analytics.employee_attendance
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- find employees with high absenteeism & low performance:
SELECT 
    employee_id, 
    department, 
    COUNT(*) AS total_absences,
    ROUND(AVG(productivity_score), 2) AS avg_productivity,
    ROUND(AVG(performance_rating), 2) AS avg_performance_rating
FROM employee_analytics.employee_attendance
WHERE absent = TRUE
GROUP BY employee_id, department
HAVING total_absences > (SELECT AVG(total_absences) FROM 
    (SELECT employee_id, COUNT(*) AS total_absences FROM employee_analytics.employee_attendance WHERE absent = TRUE GROUP BY employee_id) subquery)
AND avg_productivity < (SELECT AVG(productivity_score) FROM employee_analytics.employee_attendance)
ORDER BY total_absences DESC, avg_productivity ASC;

-- Does Pay Affect Performance?
SELECT 
    salary_band, 
    COUNT(*) AS total_employees,
    ROUND(AVG(productivity_score), 2) AS avg_productivity,
    ROUND(AVG(performance_rating), 2) AS avg_performance_rating
FROM employee_analytics.employee_attendance
GROUP BY salary_band
ORDER BY avg_productivity DESC;
 
 -- Understanding Why Friday Has the Lowest Productivity
 -- Check Absenteeism Rate on Fridays vs. Other Days
 SELECT 
    DAYNAME(date) AS weekday, 
    COUNT(CASE WHEN absent = TRUE THEN 1 END) AS total_absent,
    COUNT(*) AS total_days,
    ROUND((COUNT(CASE WHEN absent = TRUE THEN 1 END) / COUNT(*)) * 100, 2) AS absenteeism_rate
FROM employee_analytics.employee_attendance
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Check Early Logouts & Late Logins on Fridays vs. Other Days
SELECT 
    DAYNAME(date) AS weekday, 
    COUNT(CASE WHEN late_login = TRUE THEN 1 END) AS total_late_logins,
    COUNT(CASE WHEN early_logout = TRUE THEN 1 END) AS total_early_logouts,
    COUNT(*) AS total_days,
    ROUND((COUNT(CASE WHEN late_login = TRUE THEN 1 END) / COUNT(*)) * 100, 2) AS late_login_rate,
    ROUND((COUNT(CASE WHEN early_logout = TRUE THEN 1 END) / COUNT(*)) * 100, 2) AS early_logout_rate
FROM employee_analytics.employee_attendance
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Check Missed Deadlines on Fridays vs. Other Days
SELECT 
    DAYNAME(date) AS weekday, 
    SUM(project_deadlines_missed) AS total_missed_deadlines,
    COUNT(*) AS total_days,
    ROUND(SUM(project_deadlines_missed) / COUNT(*), 2) AS avg_missed_deadlines
FROM employee_analytics.employee_attendance
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Check Task Completion on Fridays vs. Other Days
SELECT 
    DAYNAME(date) AS weekday, 
    ROUND(AVG(tasks_completed), 2) AS avg_tasks_completed
FROM employee_analytics.employee_attendance
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


-- Employee Retention Risk Analysis
-- Query to identify high-risk employees by department:
SELECT 
    department,
    COUNT(DISTINCT employee_id) AS at_risk_employees
FROM employee_analytics.employee_attendance
WHERE absent = TRUE
GROUP BY department
ORDER BY at_risk_employees DESC;
 -- Why These Employees Are At Risk
 -- Query to check work mode of at-risk employees (Are remote workers more at risk?)
 SELECT 
    work_mode,
    COUNT(DISTINCT employee_id) AS at_risk_employees
FROM employee_analytics.employee_attendance
WHERE absent = TRUE
GROUP BY work_mode
ORDER BY at_risk_employees DESC;


-- Dive Deeper into Salary Impact on Retention
-- Query to check salary bands of at-risk employees:
SELECT 
    salary_band,
    COUNT(DISTINCT employee_id) AS at_risk_employees
FROM employee_analytics.employee_attendance
WHERE absent = TRUE
GROUP BY salary_band
ORDER BY at_risk_employees DESC;

--  Final Step in Retention Analysis: Find the Most Affected Designations
-- Query to check retention risk by designation:
SELECT 
    designation,
    COUNT(DISTINCT employee_id) AS at_risk_employees
FROM employee_analytics.employee_attendance
WHERE absent = TRUE
GROUP BY designation
ORDER BY at_risk_employees DESC;


-- Key Dashboard Metrics & Queries
-- Overview of Employee Productivity & Attendance
CREATE VIEW employee_analytics.employee_overview AS
SELECT 
    COUNT(DISTINCT employee_id) AS total_employees,
    COUNT(*) AS total_records,
    SUM(CASE WHEN absent = TRUE THEN 1 ELSE 0 END) AS total_absent_days,
    AVG(productivity_score) AS avg_productivity
FROM employee_analytics.employee_attendance;

-- Absenteeism by Department
CREATE VIEW employee_analytics.department_absenteeism AS
SELECT 
    department,
    SUM(CASE WHEN absent = TRUE THEN 1 ELSE 0 END) AS absenteeism_days,
    COUNT(*) AS total_days,
    (SUM(CASE WHEN absent = TRUE THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS absenteeism_rate
FROM employee_analytics.employee_attendance
GROUP BY department;

-- Productivity by Work Mode
CREATE VIEW employee_analytics.work_mode_productivity AS
SELECT work_mode, COUNT(*) AS total_employees, AVG(productivity_score) AS avg_productivity
FROM employee_analytics.employee_attendance
GROUP BY work_mode;

-- Stored Procedure for Dynamic Date Filtering
DELIMITER //
CREATE PROCEDURE employee_analytics.get_productivity_by_date(IN start_date DATE, IN end_date DATE)
BEGIN
    SELECT 
        date, department, AVG(productivity_score) AS avg_productivity
    FROM employee_analytics.employee_attendance
    WHERE date BETWEEN start_date AND end_date
    GROUP BY date, department
    order by date;
END //
DELIMITER ;

CALL employee_analytics.get_productivity_by_date('2025-02-01', '2025-02-28');