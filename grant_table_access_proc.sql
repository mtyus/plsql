-- The procedure grant_table_access_proc grants table access to a list of users.
-- A use case for this procedure is a Data migration project where you have
-- numerous source, driver, cross reference, etc. tables in a conversion schema
-- that Developers need access to.

-- Table dm_users.
CREATE TABLE dm_users
(userid VARCHAR2(10));

-- Table dm_tables.
CREATE TABLE dm_tables
(table_name VARCHAR2(100));

CREATE OR REPLACE PROCEDURE grant_table_access_proc IS

 CURSOR c_tables IS
 SELECT DISTINCT table_name
 FROM dm_tables
 ORDER BY table_name;

 v_users VARCHAR2(4000);
 v_sql   VARCHAR2(4000);
 v_cnt   NUMBER := 0;

 no_users_found_exp EXCEPTION;
 PRAGMA EXCEPTION_INIT(no_users_found_exp,-20000);

 no_tables_found_exp EXCEPTION;
 PRAGMA EXCEPTION_INIT(no_tables_found_exp,-20001);
 
BEGIN

 -- Populate v_users with distinct userids from the dm_users table.
 SELECT NVL(LISTAGG(DISTINCT userid,', ') WITHIN GROUP (ORDER BY userid),'NO_USERS') INTO v_users
 FROM dm_users;

 -- Raise an error if no records exist in the dm_users table.
 IF v_users = 'NO_USERS' THEN
    RAISE no_users_found_exp;
 END IF;

 -- Raise an error if no records exist in the dm_tables table.
 SELECT COUNT(*) INTO v_cnt FROM dm_tables;
 IF v_cnt = 0 THEN
    RAISE no_tables_found_exp;
 END IF;

 -- Loop through cursor and grant table access to users.
 FOR table_rec IN c_tables LOOP

  v_sql := 'REVOKE ALL ON ' || table_rec.table_name || ' FROM ' || v_users;
  DBMS_OUTPUT.PUT_LINE(v_sql);
  -- EXECUTE IMMEDIATE v_sql;

  v_sql := 'GRANT SELECT ON ' || table_rec.table_name || ' FROM ' || v_users;
  DBMS_OUTPUT.PUT_LINE(v_sql || CHR(13));
  -- EXECUTE IMMEDIATE v_sql;

 END LOOP;

EXCEPTION
 WHEN no_users_found_exp THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM || 'No users exist in the dm_users table.');
 WHEN no_tables_found_exp THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM || 'No tables exist in the dm_tables table.');

END;
/

-- Insert data into table dm_users.
INSERT INTO dm_users VALUES('USER01');
INSERT INTO dm_users VALUES('USER02');
INSERT INTO dm_users VALUES('USER03');
COMMIT;

-- Insert data into dm_tables.
INSERT INTO dm_tables VALUES('TABLE01');
INSERT INTO dm_tables VALUES('TABLE02');
INSERT INTO dm_tables VALUES('TABLE03');
COMMIT;

-- Execute procedure grant_table_access_proc.
EXECUTE grant_table_access_proc();

-- Oracle Live SQL Results

Table created.

Table created.

Statement processed.

1 row(s) inserted.

1 row(s) inserted.

1 row(s) inserted.

Statement processed.

1 row(s) inserted.

1 row(s) inserted.

1 row(s) inserted.

Statement processed.

Statement processed.
REVOKE ALL ON TABLE01 FROM USER01, USER02, USER03
GRANT SELECT ON TABLE01 FROM USER01, USER02, USER03

REVOKE ALL ON TABLE02 FROM USER01, USER02, USER03
GRANT SELECT ON TABLE02 FROM USER01, USER02, USER03

REVOKE ALL ON TABLE03 FROM USER01, USER02, USER03
GRANT SELECT ON TABLE03 FROM USER01, USER02, USER03
