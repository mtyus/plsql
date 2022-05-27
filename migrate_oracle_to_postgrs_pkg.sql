-- The package migrate_oracle_to_postgrs_pkg contains procedures that will extract HR schema data and
-- insert the data into extract tables in preparation of migrating the data to PostgreSQL. It also
-- contains a private procedure that displays extract information for each extract procedure.

-- TABLE regions_extract.
CREATE TABLE regions_extract AS SELECT * FROM hr.regions WHERE 0 = 1;

-- TABLE countries_extract.
CREATE TABLE countries_extract AS SELECT * FROM hr.countries WHERE 0 = 1;

-- TABLE locations_extract.
CREATE TABLE locations_extract AS SELECT * FROM hr.locations WHERE 0 = 1;

-- TABLE departments_extract.
CREATE TABLE departments_extract AS SELECT * FROM hr.departments WHERE 0 = 1;

-- TABLE jobs_extract.
CREATE TABLE jobs_extract AS SELECT * FROM hr.jobs WHERE 0 = 1;

-- TABLE job_history_extract.
CREATE TABLE job_history_extract AS SELECT * FROM hr.job_history WHERE 0 = 1;

-- TABLE employees_extract.
CREATE TABLE employees_extract AS SELECT * FROM hr.employees WHERE 0 = 1;

CREATE OR REPLACE PACKAGE migrate_oracle_to_postgrs_pkg AS

 v_bulk_rec_limit NUMBER := 100;

 PROCEDURE a01_regions_extract_proc;
 PROCEDURE a02_countries_extract_proc;
 PROCEDURE a03_locations_extract_proc;
 PROCEDURE a04_departments_extract_proc;
 PROCEDURE a05_jobs_extract_proc;
 PROCEDURE a06_job_history_extract_proc;
 PROCEDURE a07_employees_extract_proc;

END migrate_oracle_to_postgrs_pkg;
/

CREATE OR REPLACE PACKAGE BODY migrate_oracle_to_postgrs_pkg AS

 -- Private procedure.
 PROCEDURE u01_get_extract_info_proc(p_extract   IN VARCHAR2,
                                     p_src_table IN VARCHAR2,
                                     p_ext_table IN VARCHAR2);

 PROCEDURE a01_regions_extract_proc IS

   CURSOR c_regions IS SELECT * FROM hr.regions;

   TYPE regions_rec_type IS TABLE OF hr.regions%ROWTYPE;
   v_regions_table regions_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE regions_extract';

   OPEN c_regions;

   LOOP
  
    FETCH c_regions BULK COLLECT INTO v_regions_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_regions_table.COUNT = 0;

    FORALL cntr IN 1..v_regions_table.COUNT
     INSERT INTO regions_extract VALUES (v_regions_table(cntr).region_id,
                                         v_regions_table(cntr).region_name);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_regions;

   u01_get_extract_info_proc('Regions','hr.regions','regions_extract');

  END a01_regions_extract_proc;

 PROCEDURE a02_countries_extract_proc IS

   CURSOR c_countries IS SELECT * FROM hr.countries;

   TYPE countries_rec_type IS TABLE OF hr.countries%ROWTYPE;
   v_countries_table countries_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE countries_extract';

   OPEN c_countries;

   LOOP
  
    FETCH c_countries BULK COLLECT INTO v_countries_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_countries_table.COUNT = 0;

    FORALL cntr IN 1..v_countries_table.COUNT
     INSERT INTO countries_extract VALUES (v_countries_table(cntr).country_id,
                                           v_countries_table(cntr).country_name,
                                           v_countries_table(cntr).region_id);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_countries;

   u01_get_extract_info_proc('Countries','hr.countries','countries_extract');

  END a02_countries_extract_proc;

 PROCEDURE a03_locations_extract_proc IS

   CURSOR c_locations IS SELECT * FROM hr.locations;

   TYPE locations_rec_type IS TABLE OF hr.locations%ROWTYPE;
   v_locations_table locations_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE locations_extract';

   OPEN c_locations;

   LOOP
  
    FETCH c_locations BULK COLLECT INTO v_locations_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_locations_table.COUNT = 0;

    FORALL cntr IN 1..v_locations_table.COUNT
     INSERT INTO locations_extract VALUES (v_locations_table(cntr).location_id,
                                           v_locations_table(cntr).street_address,
                                           v_locations_table(cntr).postal_code,
                                           v_locations_table(cntr).city,
                                           v_locations_table(cntr).state_province,
                                           v_locations_table(cntr).country_id);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_locations; 

   u01_get_extract_info_proc('Locations','hr.locations','locations_extract');

  END a03_locations_extract_proc;

 PROCEDURE a04_departments_extract_proc IS

   CURSOR c_departments IS SELECT * FROM hr.departments;

   TYPE departments_rec_type IS TABLE OF hr.departments%ROWTYPE;
   v_departments_table departments_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE departments_extract';

   OPEN c_departments;

   LOOP
  
    FETCH c_departments BULK COLLECT INTO v_departments_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_departments_table.COUNT = 0;

    FORALL cntr IN 1..v_departments_table.COUNT
     INSERT INTO departments_extract VALUES (v_departments_table(cntr).department_id,
                                             v_departments_table(cntr).department_name,
                                             v_departments_table(cntr).manager_id,
                                             v_departments_table(cntr).location_id);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_departments;

   u01_get_extract_info_proc('Departments','hr.departments','departments_extract');

  END a04_departments_extract_proc;

 PROCEDURE a05_jobs_extract_proc IS

   CURSOR c_jobs IS SELECT * FROM hr.jobs;

   TYPE jobs_rec_type IS TABLE OF hr.jobs%ROWTYPE;
   v_jobs_table jobs_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE jobs_extract';

   OPEN c_jobs;

   LOOP
  
    FETCH c_jobs BULK COLLECT INTO v_jobs_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_jobs_table.COUNT = 0;

    FORALL cntr IN 1..v_jobs_table.COUNT
     INSERT INTO jobs_extract VALUES (v_jobs_table(cntr).job_id,
                                      v_jobs_table(cntr).job_title,
                                      v_jobs_table(cntr).min_salary,
                                      v_jobs_table(cntr).max_salary);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_jobs;

   u01_get_extract_info_proc('Jobs','hr.jobs','jobs_extract');

  END a05_jobs_extract_proc;

 PROCEDURE a06_job_history_extract_proc IS

   CURSOR c_job_history IS SELECT * FROM hr.job_history;

   TYPE job_history_rec_type IS TABLE OF hr.job_history%ROWTYPE;
   v_job_history_table job_history_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE job_history_extract';

   OPEN c_job_history;

   LOOP
  
    FETCH c_job_history BULK COLLECT INTO v_job_history_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_job_history_table.COUNT = 0;

    FORALL cntr IN 1..v_job_history_table.COUNT
     INSERT INTO job_history_extract VALUES (v_job_history_table(cntr).employee_id,
                                             v_job_history_table(cntr).start_date,
                                             v_job_history_table(cntr).end_date,
                                             v_job_history_table(cntr).job_id,
                                             v_job_history_table(cntr).department_id);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_job_history;

   u01_get_extract_info_proc('Job History','hr.job_history','job_history_extract');

  END a06_job_history_extract_proc;

 PROCEDURE a07_employees_extract_proc IS

   CURSOR c_employees IS SELECT * FROM hr.employees;

   TYPE employees_rec_type IS TABLE OF hr.employees%ROWTYPE;
   v_employees_table employees_rec_type;

  BEGIN

   EXECUTE IMMEDIATE 'TRUNCATE TABLE employees_extract';

   OPEN c_employees;

   LOOP
  
    FETCH c_employees BULK COLLECT INTO v_employees_table LIMIT v_bulk_rec_limit;

    EXIT WHEN v_employees_table.COUNT = 0;

    FORALL cntr IN 1..v_employees_table.COUNT
     INSERT INTO employees_extract VALUES (v_employees_table(cntr).employee_id,
                                           v_employees_table(cntr).first_name,
                                           v_employees_table(cntr).last_name,
                                           v_employees_table(cntr).email,
                                           v_employees_table(cntr).phone_number,
                                           v_employees_table(cntr).hire_date,
                                           v_employees_table(cntr).job_id,
                                           v_employees_table(cntr).salary,
                                           v_employees_table(cntr).commission_pct,
                                           v_employees_table(cntr).manager_id,
                                           v_employees_table(cntr).department_id);

    COMMIT;

   END LOOP;

   COMMIT;

   CLOSE c_employees;

   u01_get_extract_info_proc('Employees','hr.employees','employees_extract');

  END a07_employees_extract_proc;

 PROCEDURE u01_get_extract_info_proc(p_extract   IN VARCHAR2,
                                     p_src_table IN VARCHAR2,
                                     p_ext_table IN VARCHAR2) IS

   v_sql           VARCHAR2(500);
   v_src_table_cnt NUMBER;
   v_ext_table_cnt NUMBER;

  BEGIN

   -- Get source table record count.
   v_sql := 'SELECT COUNT(*) FROM ' || p_src_table;
   EXECUTE IMMEDIATE v_sql INTO v_src_table_cnt;

   -- Get extract table record count.
   v_sql := 'SELECT COUNT(*) FROM ' || p_ext_table;
   EXECUTE IMMEDIATE v_sql INTO v_ext_table_cnt;

   -- Display extract statistics.
   DBMS_OUTPUT.PUT_LINE('*** ' || RPAD(p_extract,14,' ') || ': ' || 
                        'Source Count = ' || 
                        LPAD(TRIM(TO_CHAR(v_src_table_cnt,'999')),3,' ') ||
                        ' | ' ||
                        'Extract Count = ' || 
                        LPAD(TRIM(TO_CHAR(v_ext_table_cnt,'999')),3,' '));
   
  END u01_get_extract_info_proc;

END migrate_oracle_to_postgrs_pkg;
/

-- Execute extract procedures.
EXECUTE migrate_oracle_to_postgrs_pkg.a01_regions_extract_proc();
EXECUTE migrate_oracle_to_postgrs_pkg.a02_countries_extract_proc();
EXECUTE migrate_oracle_to_postgrs_pkg.a03_locations_extract_proc();
EXECUTE migrate_oracle_to_postgrs_pkg.a04_departments_extract_proc();
EXECUTE migrate_oracle_to_postgrs_pkg.a05_jobs_extract_proc();
EXECUTE migrate_oracle_to_postgrs_pkg.a06_job_history_extract_proc();
EXECUTE migrate_oracle_to_postgrs_pkg.a07_employees_extract_proc();

-- Oracle Live SQL Results

Table created.

Table created.

Table created.

Table created.

Table created.

Table created.

Table created.

Package created.

Package Body created.

Statement processed.
*** Regions       : Source Count =   4 | Extract Count =   4

Statement processed.
*** Countries     : Source Count =  25 | Extract Count =  25

Statement processed.
*** Locations     : Source Count =  23 | Extract Count =  23

Statement processed.
*** Departments   : Source Count =  27 | Extract Count =  27

Statement processed.
*** Jobs          : Source Count =  19 | Extract Count =  19

Statement processed.
*** Job History   : Source Count =  11 | Extract Count =  11

Statement processed.
*** Employees     : Source Count = 107 | Extract Count = 107
