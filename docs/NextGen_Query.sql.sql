						--Employee Retention Analysis
--Understanding the employee turnover trends and identifying the root causes of high turnover rates.

--Who are the top 5 highest serving employees? 

SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    hire_date,
    CURRENT_DATE - hire_date AS days_served
FROM 
    employee
ORDER BY 
    days_served DESC
LIMIT 5;

-- What is the turnover rate for each department? 

SELECT 
    d.department_name,
    COUNT(t.employee_id) AS num_exits,
    COUNT(e.employee_id) AS total_employees,
    ROUND(COUNT(t.employee_id) * 100.0 / NULLIF(COUNT(e.employee_id), 0), 2) AS turnover_rate_percent
FROM 
    department d
LEFT JOIN 
    employee e ON d.department_id = e.department_id
LEFT JOIN 
    turnover t ON e.employee_id = t.employee_id
GROUP BY 
    d.department_name;

-- Which employees are at risk of leaving based on their performance? 

SELECT 
    employee_id,
    first_name,
    last_name,
    ROUND(avg_score, 2) AS avg_performance_score
FROM (
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        AVG(p.performance_score) AS avg_score
    FROM 
        employee e
    JOIN performance p ON e.employee_id = p.employee_id
    LEFT JOIN turnover t ON e.employee_id = t.employee_id
    WHERE t.employee_id IS NULL
    GROUP BY e.employee_id, e.first_name, e.last_name
    HAVING AVG(p.performance_score) <= 2.5

    UNION ALL

    SELECT 
        NULL AS employee_id,
        'None' AS first_name,
        'None' AS last_name,
        NULL AS avg_performance_score
    WHERE NOT EXISTS (
        SELECT 1
        FROM employee e
        JOIN performance p ON e.employee_id = p.employee_id
        LEFT JOIN turnover t ON e.employee_id = t.employee_id
        WHERE t.employee_id IS NULL
        GROUP BY e.employee_id
        HAVING AVG(p.performance_score) <= 2.5
    )
) AS results
ORDER BY avg_performance_score NULLS LAST;

-- What are the main reasons employees are leaving the company? 

SELECT 
    reason_for_leaving,
    COUNT(*) AS number_of_employees
FROM 
    turnover
GROUP BY 
    reason_for_leaving
ORDER BY 
    number_of_employees DESC; 

					--Performance Analysis Goal: 
--Evaluate employee performance across different departments and identify areas
--where performance can be improved. 

--How many employees has left the company? 

SELECT COUNT(*) AS total_exits
FROM turnover;

--How many employees have a performance score of 5.0 / below 3.5? 
--Employees with Avg Score = 5.0
SELECT COUNT(*) AS employees_with_5_score
FROM (
    SELECT employee_id, AVG(performance_score) AS avg_score
    FROM performance
    GROUP BY employee_id
    HAVING AVG(performance_score) = 5.0
) sub;

--Employees with Avg Score < 3.5

SELECT COUNT(*) AS employees_below_3_5
FROM (
    SELECT employee_id, AVG(performance_score) AS avg_score
    FROM performance
    GROUP BY employee_id
    HAVING AVG(performance_score) < 3.5
) sub; 

--Which department has the most employees with a performance of 5.0 / below 3.5? 
--Department with the most employees with a performance of 5.0

SELECT 
    d.department_name,
    COUNT(perf.employee_id) AS employees_with_5
FROM 
    department d
LEFT JOIN (
    SELECT 
        e.employee_id,
        e.department_id
    FROM 
        employee e
    JOIN performance p ON e.employee_id = p.employee_id
    GROUP BY e.employee_id, e.department_id
    HAVING AVG(p.performance_score) = 5.0
) perf ON d.department_id = perf.department_id
GROUP BY d.department_name
ORDER BY 
    CASE 
        WHEN COALESCE(d.department_name, '') = '' THEN 1
        ELSE 0
    END,
    employees_with_5 DESC; 

--Department with the most employees with a performance below 3.5?	
	
	SELECT 
    d.department_name,
    COUNT(perf.employee_id) AS employees_below_3_5
FROM 
    department d
LEFT JOIN (
    SELECT 
        e.employee_id,
        e.department_id
    FROM 
        employee e
    JOIN performance p ON e.employee_id = p.employee_id
    GROUP BY 
        e.employee_id, e.department_id
    HAVING 
        AVG(p.performance_score) < 3.5
) perf ON d.department_id = perf.department_id
GROUP BY d.department_name
ORDER BY 
    CASE 
        WHEN COALESCE(d.department_name, '') = '' THEN 1
        ELSE 0
    END,
    employees_below_3_5 DESC; 

	--What is the average performance score by department? 

	SELECT 
    d.department_name,
    ROUND(AVG(p.performance_score), 2) AS avg_performance_score
FROM 
    employee e
JOIN 
    performance p ON e.employee_id = p.employee_id
JOIN 
    department d ON e.department_id = d.department_id
GROUP BY 
    d.department_name
ORDER BY 
    avg_performance_score DESC;

						--Salary Analysis
--Goal: Analyze salary distribution and ensure fair compensation based on performance and
--departmental benchmarks.

--What is the total salary expense for the company? 

SELECT 
    SUM(salary_amount) AS total_salary_expense
FROM 
    salary;

--What is the average salary by job title? 

SELECT 
    e.job_title,
    ROUND(AVG(s.salary_amount), 2) AS average_salary
FROM 
    salary s
JOIN 
    employee e ON s.employee_id = e.employee_id
GROUP BY 
    e.job_title
ORDER BY 
    average_salary DESC;

--How many employees earn above 80,000?

SELECT 
    COUNT(DISTINCT s.employee_id) AS employees_above_80k
FROM 
    salary s
WHERE 
    s.salary_amount > 80000;

--How does performance correlate with salary across departments? 

SELECT 
    d.department_name,
    ROUND(AVG(p.performance_score), 2) AS avg_performance_score,
    ROUND(AVG(s.salary_amount), 2) AS avg_salary
FROM 
    employee e
JOIN 
    department d ON e.department_id = d.department_id
JOIN 
    performance p ON e.employee_id = p.employee_id
JOIN 
    salary s ON e.employee_id = s.employee_id
GROUP BY 
    d.department_name
ORDER BY 
    avg_performance_score DESC;











