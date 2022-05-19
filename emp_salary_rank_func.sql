-- Function emp_salary_rank_func.
-- This function returns salary rank data based on the p_rank value i.e. if
-- p_rank is '3' it returns the 1st, 2nd and 3rd salary rank data.
-- Note: I used the DENSE_RANK function because the DENSE function
-- can cause gaps in the ranking. 
CREATE OR REPLACE FUNCTION emp_salary_rank_func(p_rank IN NUMBER) 
RETURN SYS_REFCURSOR IS

 c_rank SYS_REFCURSOR;

BEGIN 

 OPEN c_rank FOR
  SELECT * FROM
  (SELECT b.department_name,
          b.department_id,
          a.employee_id, 
          a.first_name, 
          a.last_name,
          b.salary,
          DENSE_RANK() OVER (PARTITION BY b.department_id ORDER BY b.salary DESC) AS sal_rank
   FROM hr.employees a, hr.emp_details_view b
   WHERE a.employee_id = b.employee_id)
  WHERE sal_rank <= p_rank;
  
 RETURN c_rank;

END;
/

CREATE OR REPLACE PROCEDURE call_a_function_proc(p_rank IN NUMBER) is
 
 c_sal_ranks SYS_REFCURSOR;
 v_deptname  hr.emp_details_view.department_name%TYPE;
 v_deptid    hr.emp_details_view.department_id%TYPE;
 v_eeid      hr.employees.employee_id%TYPE;
 v_fname     hr.employees.first_name%TYPE;
 v_lname     hr.employees.last_name%TYPE;
 v_sal       hr.employees.salary%TYPE;
 v_rank      NUMBER;

BEGIN

 c_sal_ranks := emp_salary_rank_func(p_rank);

 LOOP
  FETCH c_sal_ranks INTO v_deptname, v_deptid, v_eeid, v_fname, v_lname, v_sal, v_rank;
   
   EXIT WHEN c_sal_ranks%NOTFOUND;
   
   DBMS_OUTPUT.PUT_LINE(RPAD(v_deptname,20) || ' ' || 
                        RPAD(v_deptid,5) || ' ' ||
                        RPAD(v_eeid,10) || ' ' || 
                        RPAD(v_fname,20) || ' ' || 
                        RPAD(v_Lname,20) || ' ' ||
                        RPAD(v_sal,10) || ' ' ||
                        RPAD(v_rank,1));

 END LOOP;

END;
/

-- Execute procedure call_a_function_proc.
EXECUTE call_a_function_proc(3);

-- Oracle Live SQL Results

Function created.

Procedure created.

Statement processed.
Administration       10    200        Jennifer             Whalen               4400       1
Marketing            20    201        Michael              Hartstein            13000      1
Marketing            20    202        Pat                  Fay                  6000       2
Purchasing           30    114        Den                  Raphaely             11000      1
Purchasing           30    115        Alexander            Khoo                 3100       2
Purchasing           30    116        Shelli               Baida                2900       3
Human Resources      40    203        Susan                Mavris               6500       1
Shipping             50    121        Adam                 Fripp                8200       1
Shipping             50    120        Matthew              Weiss                8000       2
Shipping             50    122        Payam                Kaufling             7900       3
IT                   60    103        Alexander            Hunold               9000       1
IT                   60    104        Bruce                Ernst                6000       2
IT                   60    105        David                Austin               4800       3
IT                   60    106        Valli                Pataballa            4800       3
Public Relations     70    204        Hermann              Baer                 10000      1
Sales                80    145        John                 Russell              14000      1
Sales                80    146        Karen                Partners             13500      2
Sales                80    147        Alberto              Errazuriz            12000      3
Executive            90    100        Steven               King                 24000      1
Executive            90    101        Neena                Kochhar              17000      2
Executive            90    102        Lex                  De Haan              17000      2
Finance              100   108        Nancy                Greenberg            12008      1
Finance              100   109        Daniel               Faviet               9000       2
Finance              100   110        John                 Chen                 8200       3
Accounting           110   205        Shelley              Higgins              12008      1
Accounting           110   206        William              Gietz                8300       2
