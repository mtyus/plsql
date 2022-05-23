-- The trigger job_salary_check_trigger maintains data integrity on the my_employees' job and
-- salary fields by validating job and salary values, during inserts and updates, against the
-- hr.jobs table. Also, updates to job and salary fields are tracked in the job_salary_changes table.

-- Table my_employees.
CREATE TABLE my_employees AS SELECT * FROM hr.employees;

-- Table job_salary_changes.
CREATE TABLE job_salary_changes 
(employee_id    NUMBER(6),
 old_job_id     VARCHAR2(10),
 new_job_id     VARCHAR2(10),
 old_salary     NUMBER(8,2),
 new_salary     NUMBER(8,2),
 modify_dte     DATE);

-- Trigger validate_salary.
CREATE OR REPLACE TRIGGER job_salary_check_trigger
BEFORE INSERT OR UPDATE OF salary, job_id ON my_employees
FOR EACH ROW

DECLARE

 TYPE jobs_rec_type IS TABLE OF hr.jobs%ROWTYPE;
 v_jobs_table jobs_rec_type;

 job_not_found_exp EXCEPTION;

 salary_out_of_range_exp EXCEPTION;

BEGIN

 SELECT *
 BULK COLLECT INTO v_jobs_table
 FROM hr.jobs
 WHERE job_id = :new.job_id;

 IF v_jobs_table.COUNT() = 0 THEN
    RAISE job_not_found_exp;
 END IF;

 IF NOT (:new.salary >= v_jobs_table(1).min_salary AND :new.salary <= v_jobs_table(1).max_salary) THEN
    RAISE salary_out_of_range_exp;
 END IF;

 -- Track changes in job_salary_changes table.
 IF UPDATING THEN
    INSERT INTO job_salary_changes VALUES (:new.employee_id,
                                           :old.job_id,
                                           :new.job_id,
                                           :old.salary,
                                           :new.salary,
                                           SYSDATE);
 END IF;

 EXCEPTION
  WHEN job_not_found_exp THEN
   RAISE_APPLICATION_ERROR(-20000, 'Job ' || :new.job_id || ' does not exist.');
  WHEN salary_out_of_range_exp THEN
   RAISE_APPLICATION_ERROR(-20001, TRIM(TO_CHAR(:new.salary,'999,999.00')) ||
                           ' is an invalid salary. The salary range for job ' ||
                           :new.job_id || ' is ' ||
                           TRIM(TO_CHAR(v_jobs_table(1).min_salary,'999,999.00')) || ' - ' ||
                           TRIM(TO_CHAR(v_jobs_table(1).max_salary,'999,999.00')) || '.');

END;
/ 

-- Insert an employee with an invalid job.
INSERT INTO my_employees VALUES (207,'Michael','Tyus','MTYUS','515.123.9999',SYSDATE,'SOME_JOB',
                                 8200,NULL,205,110);

-- Insert an employee with salary that's out of range for the job.
INSERT INTO my_employees VALUES (207,'Michael','Tyus','MTYUS','515.123.9999',SYSDATE,'AC_MGR',
                                 7000,NULL,205,110);

-- Update an employee with a salary that's out of range for the job.
UPDATE my_employees SET SALARY = 400000 WHERE EMPLOYEE_ID = 100;

-- Insert an employee with salary that's in range for the job.
INSERT INTO my_employees VALUES (207,'Michael','Tyus','MTYUS','515.123.9999',SYSDATE,'AC_MGR',
                                 15000,NULL,205,110); 

-- Update an employee with a salary that's in range for the job.
UPDATE my_employees SET SALARY = 35000 WHERE EMPLOYEE_ID = 100;

-- Update an employee with a different job and salary that's in range for the job.
UPDATE my_employees SET JOB_ID = 'IT_PROG', SALARY = 9500 WHERE EMPLOYEE_ID = 109;

SELECT employee_id,first_name,last_name,job_id,salary FROM my_employees WHERE employee_id IN (207,100,109);

SELECT * FROM job_salary_changes;

-- Oracle Live SQL Results

Table created.

Table created.

Trigger created.

ORA-20000: Job SOME_JOB does not exist. ORA-06512: at "SQL_FUOOTQNABSJHJPLZMAFFODAMM.JOB_SALARY_CHECK_TRIGGER", line 37
ORA-06512: at "SYS.DBMS_SQL", line 1721

ORA-20001: 7,000.00 is an invalid salary. The salary range for job AC_MGR is 8,200.00 - 16,000.00. ORA-06512: at "SQL_FUOOTQNABSJHJPLZMAFFODAMM.JOB_SALARY_CHECK_TRIGGER", line 39
ORA-06512: at "SYS.DBMS_SQL", line 1721

ORA-20001: 400,000.00 is an invalid salary. The salary range for job AD_PRES is 20,080.00 - 40,000.00. ORA-06512: at "SQL_FUOOTQNABSJHJPLZMAFFODAMM.JOB_SALARY_CHECK_TRIGGER", line 39
ORA-06512: at "SYS.DBMS_SQL", line 1721

1 row(s) inserted.

1 row(s) updated.

1 row(s) updated.

EMPLOYEE_ID FIRST_NAME  LAST_NAME   JOB_ID   SALARY
100         Steven      King        AD_PRES  35000
109         Daniel      Faviet      IT_PROG  9500
207         Michael     Tyus        AC_MGR   15000

EMPLOYEE_ID OLD_JOB_ID  NEW_JOB_ID  OLD_SALARY  NEW_SALARY  MODIFY_DTE
100         AD_PRES     AD_PRES     24000       35000       23-MAY-22
109         FI_ACCOUNT  IT_PROG     9000        9500        23-MAY-22
