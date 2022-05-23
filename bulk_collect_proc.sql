-- The procedure bulk_collect_proc performs a bulk collect and uses the limit
-- clause to manage the impact to PGA (process global area) memory.

-- Table customer_transactions.
CREATE TABLE customer_transactions 
(customer_id   NUMBER(10) PRIMARY KEY,
 trans_dte     DATE,
 trans_amt     NUMBER(9,2),
 processed_flg VARCHAR2(1));

-- Table processed_transactions.
CREATE TABLE processed_transactions 
(customer_id   NUMBER(10) PRIMARY KEY,
 trans_dte     DATE,
 trans_amt     NUMBER(9,2),
 audit_flg     VARCHAR2(1));

CREATE OR REPLACE PROCEDURE bulk_collect_proc IS

 CURSOR c_trans(p_audit_amt NUMBER) IS 
 SELECT customer_id,
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
   INSERT INTO processed_transactions VALUES (v_trans_table(cntr).customer_id,
                                              v_trans_table(cntr).trans_dte,
                                              v_trans_table(cntr).trans_amt,
                                              v_trans_table(cntr).audit_flg);

  -- Update processed_flg for processed customer_transaction records.
  FORALL cntr IN 1..v_trans_table.COUNT
   UPDATE customer_transactions SET processed_flg = 'Y'
   WHERE customer_id = v_trans_table(cntr).customer_id;
 
  COMMIT;

 END LOOP;

 COMMIT;

 CLOSE c_trans;

END;
/

-- Insert data into customer_transactions table.
INSERT INTO customer_transactions
SELECT TRUNC(DBMS_RANDOM.value(1,9999999999)) AS customer_id,
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

CUSTOMER_ID   TRANS_DTE     TRANS_AMT     AUDIT_FLG
9543212450    29-JUN-22     1715338.14    Y
1476619708    03-FEB-23     1164284.29    Y
9679171690    16-JUN-22     1812427.04    Y
5302052966    02-OCT-22     111100.51     N
2066970001    16-DEC-22     1044574.27    Y
1213763411    11-DEC-22     1011398.73    Y
3117473165    13-MAR-23     541041.02     N
9089664233    26-JUN-22     1673444.65    Y
4997291166    16-JUN-22     580365.9      N
3727710996    11-MAR-23     297007.78     N
