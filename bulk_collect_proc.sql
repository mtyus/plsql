-- Table customer_transactions.
CREATE TABLE customer_transactions 
(customerid    VARCHAR2(10),
 trans_dte     DATE,
 trans_amt     NUMBER(9,2),
 processed_flg VARCHAR2(1));

-- Table processed_transactions.
CREATE TABLE processed_transactions 
(customerid VARCHAR2(10),
 trans_dte  DATE,
 trans_amt  NUMBER(9,2),
 audit_flg  VARCHAR2(1));

-- Procedure bulk_collect_proc.
-- This procedure performs a bulk collect with a limit to manage the impact to PGA (process global area) memory.
CREATE OR REPLACE PROCEDURE bulk_collect_proc IS

 CURSOR c_trans(p_audit_amt NUMBER) IS 
 SELECT customerid,
        trans_dte, 
        trans_amt,
        CASE
         WHEN trans_amt >= p_audit_amt THEN 'Y'
         ELSE 'N' 
        END AS audit_flg
        FROM customer_transactions;

 TYPE processed_rec_type IS TABLE OF processed_transactions%ROWTYPE;
 v_trans_table processed_rec_type;

 c_audit_amt NUMBER(9,2) := 1000000.00;
 c_rec_limit NUMBER := 100;

BEGIN

 OPEN c_trans(c_audit_amt);

 LOOP
  
  FETCH c_trans BULK COLLECT INTO v_trans_table LIMIT c_rec_limit;

  EXIT WHEN v_trans_table.COUNT = 0;

  -- Insert customer_transaction records to processed_transactions table.
  FORALL cntr IN 1..v_trans_table.COUNT
   INSERT INTO processed_transactions VALUES (v_trans_table(cntr).customerid,
                                              v_trans_table(cntr).trans_dte,
                                              v_trans_table(cntr).trans_amt,
                                              v_trans_table(cntr).audit_flg);

  -- Update processed_flg for processed customer_transaction records.
  FORALL cntr IN 1..v_trans_table.COUNT
   UPDATE customer_transactions SET processed_flg = 'Y'
   WHERE customerid = v_trans_table(cntr).customerid;
 
  COMMIT;

 END LOOP;

 COMMIT;

 CLOSE c_trans;

END;
/

-- Insert data into customer_transactions table.
INSERT INTO customer_transactions
SELECT TRUNC(DBMS_RANDOM.value(1,9999999999)) AS customerid,
       TRUNC(SYSDATE + DBMS_RANDOM.value(0,366)) AS trans_dte,
       ROUND(DBMS_RANDOM.value(1,2000000),2) AS trans_amt, 
       'N' AS processed_flg
FROM dual
CONNECT BY level <= 10000;
COMMIT;

-- Execute procedure bulk_collect_proc.
EXECUTE bulk_collect_proc();

SELECT * FROM processed_transactions FETCH FIRST 10 ROWS ONLY;

-- Oracle Live SQL Results

Table created.

Table created.

Procedure created.

10000 row(s) inserted.

Statement processed.

Statement processed.

CUSTOMERID  TRANS_DTE   TRANS_AMT   AUDIT_FLG
4607970315  12-MAY-23   151736.67   N
2606726818  29-JUN-22   183238.68   N
6937193069  14-JAN-23   38776.68    N
2450782710  29-JAN-23   767952.59   N
2389050843  17-MAR-23   1891117.3   Y
2921381471  17-OCT-22   1628143.7   Y
7096571348  18-FEB-23   1829276.66  Y
966003456   17-JAN-23   1573914.97  Y
6223451897  07-MAR-23   1283779.79  Y
8730322564  30-DEC-22   1588102.53  Y
