-- This script reads the product_import table and uses the product_id_seq sequence
-- to assign product_id values to each product before inserting them into the
-- product_master table.

-- Sequence product_id_seq
CREATE SEQUENCE product_id_seq
  MINVALUE 1
  MAXVALUE 9999999999
  START WITH 1
  INCREMENT BY 1
  NOCACHE;

-- Table product_import.
CREATE TABLE product_import
(product_name VARCHAR2(100),
 unit_price   NUMBER(9,2));

-- Insert data into product_import table.
INSERT INTO product_import
SELECT 'WIDGET ' || DBMS_RANDOM.string('x',10) AS product_name,
       ROUND(DBMS_RANDOM.value(1,300),2) AS unit_price 
FROM dual
CONNECT BY level <= 30;
COMMIT;

-- Table product_master.
CREATE TABLE product_master 
(product_id   NUMBER(10) PRIMARY KEY,
 product_name VARCHAR2(100),
 unit_price   NUMBER(9,2),
 modified_dte DATE);

DECLARE

 CURSOR cur_products IS SELECT * FROM product_import;

BEGIN

 FOR product_rec IN cur_products LOOP

  INSERT INTO product_master VALUES(product_id_seq.nextval,
                                    product_rec.product_name,
                                    product_rec.unit_price,
                                    NULL);

 END LOOP;
 
 COMMIT;

END;
/

SELECT * FROM product_master;

SELECT product_id_seq.currval FROM dual;

-- Oracle Live SQL Results

Sequence created.

Table created.

30 row(s) inserted.

Statement processed.

Table created.

Statement processed.

PRODUCT_ID  PRODUCT_NAME        UNIT_PRICE  MODIFIED_DTE
1           WIDGET 4QTJK53PC2   244.72      - 
2           WIDGET RZXR2V6XUQ   120.96      - 
3           WIDGET DXNZCADMDW   75.22       - 
4           WIDGET 2TZ34J2FYL   244.88      - 
5           WIDGET BF1B78I8AX   132.05      - 
6           WIDGET RP5TXRGML4   188.05      - 
7           WIDGET R21A4A4IO1   253.49      - 
8           WIDGET F9U7UINJTO   286.93      - 
9           WIDGET 7MXUL5OJKD   267.76      - 
10          WIDGET DQ6MBR695C   209.86      - 
11          WIDGET MX0BLAABKC   75.17       - 
12          WIDGET OXNGTUPWKE   176.44      - 
13          WIDGET MV6Z1RTWIA   265.6       - 
14          WIDGET 8XI5VH8WT2   248.72      - 
15          WIDGET 07ZG1NQOQZ   173.26      - 
16          WIDGET SX13E6SMGK   56.46       - 
17          WIDGET 73JX1QJYEF   237.02      - 
18          WIDGET MC7NSGJV33   242.04      - 
19          WIDGET 90WCO3OG09   275.15      - 
20          WIDGET K416LM54IL   273.21      - 
21          WIDGET 0KTJX1WP9U   64.22       - 
22          WIDGET 3F80Q7J7BZ   277.74      - 
23          WIDGET NIS9XK2G03   116.08      - 
24          WIDGET 2KUELSXB8C   103.03      - 
25          WIDGET S5RE4TG4G9   131.09      - 
26          WIDGET SUQ4ZIWSMX   235.7       - 
27          WIDGET YTTTNISKNS   25.48       - 
28          WIDGET FXX3DOIQFW   71.24       - 
29          WIDGET TPUWHLK80A   47.67       - 
30          WIDGET LYFWWD3WJO   106.31      - 

CURRVAL
30
