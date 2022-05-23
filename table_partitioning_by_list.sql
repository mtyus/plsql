-- This script creates a customer_transaction table with a list partition based
-- on region i.e. North America, Asia, Europe and Middle East and Africa. It also
-- alters the table and adds a South America partition.

-- Table customer_transaction.
CREATE TABLE customer_transactions 
(customer_id   NUMBER(10) PRIMARY KEY,
 trans_dte     DATE,
 trans_amt     NUMBER(9,2),
 region_cd     VARCHAR2(4),
 processed_flg VARCHAR2(1))
PARTITION BY LIST (region_cd)
(PARTITION p_amer VALUES ('NAMR'),
 PARTITION p_asia VALUES ('ASIA'),
 PARTITION p_euro VALUES ('EURO'),
 PARTITION p_meaa VALUES ('MEAA'));

-- Insert data into customer_transactions table.
INSERT INTO customer_transactions
SELECT TRUNC(DBMS_RANDOM.value(1,9999999999)) AS customer_id,
       TRUNC(SYSDATE + DBMS_RANDOM.value(0,366)) AS trans_dte,
       ROUND(DBMS_RANDOM.value(1,2000000),2) AS trans_amt,
       DECODE(TRUNC(DBMS_RANDOM.value(1,5)),1,'NAMR',2,'ASIA',3,'EURO','MEAA')  AS region_cd,
       'N' AS processed_flg
FROM dual
CONNECT BY level <= 10000;
COMMIT;

SELECT TABLE_NAME,PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'CUSTOMER_TRANSACTIONS';

SELECT REGION_CD,COUNT(*) FROM customer_transactions GROUP BY REGION_CD;

SELECT * FROM customer_transactions PARTITION(p_euro) FETCH FIRST 10 ROWS ONLY;

ALTER TABLE customer_transactions ADD PARTITION p_samr VALUES ('SAMR');

SELECT TABLE_NAME,PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'CUSTOMER_TRANSACTIONS';

INSERT INTO customer_transactions VALUES('4646464646',SYSDATE,939000,'SAMR','N');
COMMIT;

SELECT * FROM customer_transactions PARTITION(p_samr) FETCH FIRST 10 ROWS ONLY;

-- Oracle Live SQL Results

Table created.

10000 row(s) inserted.

Statement processed.

TABLE_NAME              PARTITION_NAME
CUSTOMER_TRANSACTIONS   P_AMER
CUSTOMER_TRANSACTIONS   P_ASIA
CUSTOMER_TRANSACTIONS   P_EURO
CUSTOMER_TRANSACTIONS   P_MEAA

REGION_CD   COUNT(*)
NAMR        2546
ASIA        2533
EURO        2439
MEAA        2482

CUSTOMER_ID TRANS_DTE   TRANS_AMT   REGION_CD   PROCESSED_FLG
2739270072  29-MAR-23   1673865.96  EURO        N
2034440033  21-MAR-23   1744693.91  EURO        N
1290931653  11-AUG-22   56579.7     EURO        N
5175991792  27-JUN-22   1100117.97  EURO        N
887619959   12-AUG-22   264745.69   EURO        N
6639560925  29-MAY-22   1639146.85  EURO        N
6134658155  07-SEP-22   340745.77   EURO        N
9945525892  18-FEB-23   348788.81   EURO        N
2900554724  08-JUL-22   90227.76    EURO        N
5325305011  15-MAR-23   311388.48   EURO        N

Table altered.

TABLE_NAME              PARTITION_NAME
CUSTOMER_TRANSACTIONS   P_AMER
CUSTOMER_TRANSACTIONS   P_ASIA
CUSTOMER_TRANSACTIONS   P_EURO
CUSTOMER_TRANSACTIONS   P_MEAA
CUSTOMER_TRANSACTIONS   P_SAMR

1 row(s) inserted.

Statement processed.

CUSTOMER_ID TRANS_DTE   TRANS_AMT   REGION_CD   PROCESSED_FLG
4646464646  23-MAY-22   939000      SAMR        N
