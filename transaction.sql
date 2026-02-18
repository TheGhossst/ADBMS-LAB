CREATE TABLE SHOP (
  s_id NUMBER PRIMARY KEY,
  s_name VARCHAR2(20) NOT NULL
  area VARCHAR2(20) NOT NULL
);

CREATE TABLE CUSTOMER (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    age NUMBER CHECK (age > 0),
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female')),
    profession VARCHAR2(100),
    shop_id NUMBER,
    FOREIGN KEY (shop_id) REFERENCES SHOP(s_id)
);

CREATE TABLE ITEMS (
  i_id NUMBER PRIMARY KEY,
  i_name VARCHAR2(20) NOT NULL,
  cost NUMBER NOT NULL CHECK (cost > 0)
);

CREATE TABLE INVENTORY (
  s_id NUMBER,
  i_id NUMBER,
  quantity NUMBER CHECK (quantity >= 0),
  PRIMARY KEY (s_id, i_id),
  FOREIGN KEY (s_id) REFERENCES SHOP(s_id),
  FOREIGN KEY (i_id) REFERENCES ITEMS(i_id)
);

CREATE TABLE TRANSACTION_LOG (
  transaction_id NUMBER PRIMARY KEY,
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  customer_id NUMBER,
  shop_id NUMBER,
  total_amount NUMBER CHECK (total_amount >= 0),
  FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id),
  FOREIGN KEY (shop_id) REFERENCES SHOP(s_id)
);

CREATE TABLE TRANSACTION_ITEMS (
  transaction_id NUMBER,
  i_id NUMBER,
  quantity NUMBER CHECK (quantity > 0),
  item_price NUMBER NOT NULL,
  PRIMARY KEY (transaction_id, i_id),
  FOREIGN KEY (transaction_id) REFERENCES TRANSACTION_LOG(transaction_id),
  FOREIGN KEY (i_id) REFERENCES ITEMS(i_id)
);

INSERT INTO SHOP (s_id, s_name, area) 
VALUES (1, 'ElectroMart', 'Downtown');

INSERT INTO SHOP (s_id, s_name, area) 
VALUES (2, 'GroceryHub', 'Suburb');

INSERT INTO CUSTOMER (id, name, age, gender, profession, shop_id)
VALUES (101, 'John Doe', 30, 'Male', 'Software Engineer', 1);

INSERT INTO CUSTOMER (id, name, age, gender, profession, shop_id)
VALUES (102, 'Jane Smith', 25, 'Female', 'Teacher', 2);

INSERT INTO ITEMS (i_id, i_name, cost)
VALUES (1, 'Laptop', 1000);

INSERT INTO ITEMS (i_id, i_name, cost)
VALUES (2, 'Smartphone', 500);

INSERT INTO ITEMS (i_id, i_name, cost)
VALUES (3, 'Headphones', 100);

INSERT INTO INVENTORY (s_id, i_id, quantity)
VALUES (1, 1, 50);

INSERT INTO INVENTORY (s_id, i_id, quantity)
VALUES (1, 2, 100);

INSERT INTO INVENTORY (s_id, i_id, quantity)
VALUES (1, 3, 150);

INSERT INTO INVENTORY (s_id, i_id, quantity)
VALUES (2, 1, 30);

INSERT INTO INVENTORY (s_id, i_id, quantity)
VALUES (2, 2, 80);

INSERT INTO INVENTORY (s_id, i_id, quantity)
VALUES (2, 3, 120);

INSERT INTO TRANSACTION_LOG (transaction_id, transaction_date, customer_id, shop_id, total_amount)
VALUES (1, CURRENT_TIMESTAMP, 101, 1, 2500);

INSERT INTO TRANSACTION_LOG (transaction_id, transaction_date, customer_id, shop_id, total_amount)
VALUES (2, CURRENT_TIMESTAMP, 102, 2, 2000);

INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
VALUES (1, 1, 1, 1000);

INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
VALUES (1, 2, 2, 500);

INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
VALUES (1, 3, 1, 100);

INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
VALUES (2, 1, 1, 1000);

INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
VALUES (2, 2, 2, 500);

INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
VALUES (2, 3, 1, 100);


CREATE OR REPLACE PACKAGE transaction_pkg AS

  PROCEDURE process_transaction(
    p_customer_id IN NUMBER,
    p_shop_id IN NUMBER,
    p_items IN SYS.ODCINUMBERLIST,
    p_quantities IN SYS.ODCINUMBERLIST,
    p_total_amount OUT NUMBER
  );
  
  PROCEDURE log_transaction_details(
    p_transaction_id IN NUMBER,
    p_items IN SYS.ODCINUMBERLIST,
    p_quantities IN SYS.ODCINUMBERLIST,
    p_item_prices IN SYS.ODCINUMBERLIST
  );

END transaction_pkg;

CREATE OR REPLACE PACKAGE BODY transaction_pkg AS

  PROCEDURE process_transaction(
    p_customer_id IN NUMBER,
    p_shop_id IN NUMBER,
    p_items IN SYS.ODCINUMBERLIST,
    p_quantities IN SYS.ODCINUMBERLIST,
    p_total_amount OUT NUMBER
  ) IS
    v_transaction_id NUMBER;
    v_total NUMBER := 0;
    v_item_price NUMBER;
  BEGIN
    INSERT INTO TRANSACTION_LOG (transaction_id, customer_id, shop_id, total_amount)
    VALUES (TRANSACTION_LOG_SEQ.NEXTVAL, p_customer_id, p_shop_id, 0) 
    RETURNING transaction_id INTO v_transaction_id;
    
    FOR i IN 1..p_items.COUNT LOOP
      SELECT cost INTO v_item_price FROM ITEMS WHERE i_id = p_items(i);
      v_total := v_total + (v_item_price * p_quantities(i));
      log_transaction_details(v_transaction_id, p_items, p_quantities, SYS.ODCINUMBERLIST(v_item_price));
    END LOOP;
    
    UPDATE TRANSACTION_LOG SET total_amount = v_total WHERE transaction_id = v_transaction_id;
    p_total_amount := v_total;
  END process_transaction;

  PROCEDURE log_transaction_details(
    p_transaction_id IN NUMBER,
    p_items IN SYS.ODCINUMBERLIST,
    p_quantities IN SYS.ODCINUMBERLIST,
    p_item_prices IN SYS.ODCINUMBERLIST
  ) IS
  BEGIN
    FOR i IN 1..p_items.COUNT LOOP
      INSERT INTO TRANSACTION_ITEMS (transaction_id, i_id, quantity, item_price)
      VALUES (p_transaction_id, p_items(i), p_quantities(i), p_item_prices(i));
    END LOOP;
  END log_transaction_details;

END transaction_pkg;


DECLARE
  v_total_amount NUMBER;
  v_items SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 2, 3);
  v_quantities SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(2, 3, 1);
BEGIN
  transaction_pkg.process_transaction(
    p_customer_id  => 101,
    p_shop_id      => 1,
    p_items        => v_items,
    p_quantities   => v_quantities,
    p_total_amount => v_total_amount
  );

  DBMS_OUTPUT.PUT_LINE('Total Amount: ' || v_total_amount);
END;
