-- The procedure pragma_inline_proc invokes the function multiply_numbers with
-- and without the pragma inline directive and it shows that invoking the
-- function multiply_numbers with the pragma inline directive results in
-- less processing time.

-- Set PLSQL_OPTIMIZE_LEVEL parameter to 2, which will allow programs to
-- specify the pragma inline directive for nested subprograms.
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=2;

CREATE OR REPLACE PROCEDURE pragma_inline_proc (p_use_ip IN VARCHAR2) IS

 v_start_time NUMBER;
 v_return_num NUMBER;
 v_loop_cnt   NUMBER := 10000000;

 FUNCTION multiply_numbers (p_num1 IN NUMBER, p_num2 IN NUMBER) RETURN NUMBER IS

  BEGIN

   RETURN p_num1 * p_num2;

  END;

BEGIN

 v_start_time := DBMS_UTILITY.get_time;

 FOR idx IN 1..v_loop_cnt LOOP

  IF p_use_ip = 'YES' THEN
     PRAGMA INLINE (multiply_numbers,'YES');
     v_return_num := multiply_numbers(1,idx);
  ELSE
     v_return_num := multiply_numbers(1,idx);
  END IF;

 END LOOP;

 DBMS_OUTPUT.put_line('Elapsed Time: ' || (DBMS_UTILITY.get_time - v_start_time));
 
END;
/

-- Execute without pragma inline.
EXECUTE pragma_inline_proc('NO');

-- Execute with pragma inline.
EXECUTE pragma_inline_proc('YES');

-- Oracle Live SQL Results

Statement processed.

Procedure created.

Statement processed.
Elapsed Time: 220

Statement processed.
Elapsed Time: 89
