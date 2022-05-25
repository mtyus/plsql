-- The dept_dashboard_view is comprised of the hr.employees, hr.departments and hr.jobs tables
-- and it summarizes department information.

CREATE VIEW dept_dashboard_view AS
SELECT dept_info.dept_id,
       dept_info.dept_name,
       dept_info.mgr_name,
       dept_info.mgr_title,
       ee_info.nbr_of_ees,
       sal_info.min_sal,
       sal_info.max_sal,
       sal_info.avg_sal
FROM (SELECT a.department_id AS dept_id,
             a.department_name AS dept_name, 
             b.first_name || ' ' || b.last_name AS mgr_name, 
             c.job_title AS mgr_title
      FROM hr.departments a, hr.employees b, hr.jobs c
      WHERE a.manager_id = b.employee_id AND
            b.job_id = c.job_id) dept_info,
     (SELECT department_id AS dept_id, 
             COUNT(*) AS nbr_of_ees
      FROM hr.employees
      GROUP BY department_id) ee_info,
     (SELECT a.department_id AS dept_id,
             MIN(a.salary) AS min_sal, 
             MAX(a.salary) AS max_sal, 
             TRUNC(AVG(a.salary)) AS avg_sal
      FROM hr.employees a, hr.departments b
      WHERE a.department_id = b.department_id 
      GROUP BY a.department_id, b.department_name) sal_info
WHERE dept_info.dept_id = ee_info.dept_id AND
      dept_info.dept_id = sal_info.dept_id
ORDER BY dept_info.dept_id;

SELECT * FROM dept_dashboard_view;

-- Oracle Live SQL Results

View created.

DEPT_ID  DEPT_NAME        MGR_NAME          MGR_TITLE                        NBR_OF_EES  MIN_SAL  MAX_SAL  AVG_SAL
10       Administration   Jennifer Whalen   Administration Assistant         1           4400     4400     4400
20       Marketing        Michael Hartstein Marketing Manager                2           6000     13000    9500
30       Purchasing       Den Raphaely      Purchasing Manager               6           2500     11000    4150
40       Human Resources  Susan Mavris      Human Resources Representative   1           6500     6500     6500
50       Shipping         Adam Fripp        Stock Manager                    45          2100     8200     3475
60       IT               Alexander Hunold  Programmer                       5           4200     9000     5760
70       Public Relations Hermann Baer      Public Relations Representative  1           10000    10000    10000
80       Sales            John Russell      Sales Manager                    34          6100     14000    8955
90       Executive        Steven King       President                        3           17000    24000    19333
100      Finance          Nancy Greenberg   Finance Manager                  6           6900     12008    8601
110      Accounting       Shelley Higgins   Accounting Manager               2           8300     12008    10154
