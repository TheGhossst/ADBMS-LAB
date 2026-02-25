-- ACCOUNT Table
CREATE TABLE ACCOUNTS (
    account_number INT PRIMARY KEY,
    balance INT NOT NULL,
    branch_name INT
);

-- BRANCH Table
CREATE TABLE BRANCH (
    branch_name INT PRIMARY KEY,
    branch_city VARCHAR2(29),
    assets VARCHAR2(20)
);

-- CUSTOMER Table
CREATE TABLE CUSTOMER (
    customer_name VARCHAR2(29),
    customer_street VARCHAR2(29),
    customer_city VARCHAR2(20)
);

-- DEPOSITOR Table
CREATE TABLE DEPOSITOR (
    account_number INT,
    customer_name VARCHAR2(39),
    PRIMARY KEY (account_number, customer_name),
    FOREIGN KEY (account_number) REFERENCES ACCOUNT(account_number),
    FOREIGN KEY (customer_name) REFERENCES CUSTOMER(customer_name)
);

-- LOAN Table
CREATE TABLE LOAN (
    loan_number INT PRIMARY KEY,
    amount INT NOT NULL,
    branch_name INT
);

-- BORROWER Table
CREATE TABLE BORROWER (
    customer_name VARCHAR2(20),
    loan_number INT,
    PRIMARY KEY (customer_name, loan_number),
    FOREIGN KEY (customer_name) REFERENCES CUSTOMER(customer_name),
    FOREIGN KEY (loan_number) REFERENCES LOAN(loan_number)
);


CREATE OR REPLACE PROCEDURE DEPOSIT_MONEY(account_no IN INT, amount IN INT) IS

  
CREATE OR REPLACE PACKAGE account_pkg AS
    PROCEDURE deposit_money(p_account_number IN INT, p_amount IN INT);
    PROCEDURE withdraw_money(p_account_number IN INT, p_amount IN INT);
    FUNCTION show_account_details(p_account_number IN INT) RETURN SYS_REFCURSOR;
END account_pkg;
/



CREATE OR REPLACE PACKAGE BODY account_pkg AS
    PROCEDURE deposit_money(p_account_number IN INT, p_amount IN INT) IS
    BEGIN
        UPDATE ACCOUNT
        SET balance = balance + p_amount
        WHERE account_number = p_account_number;

        COMMIT;
    END deposit_money;
    PROCEDURE withdraw_money(p_account_number IN INT, p_amount IN INT) IS
        current_balance INT;
    BEGIN
        SELECT balance INTO current_balance
        FROM ACCOUNT
        WHERE account_number = p_account_number;

        IF current_balance >= p_amount THEN
            UPDATE ACCOUNT
            SET balance = balance - p_amount
            WHERE account_number = p_account_number;
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds for withdrawal');
        END IF;
    END withdraw_money;

    FUNCTION show_account_details(p_account_number IN INT) RETURN SYS_REFCURSOR IS
        account_cursor SYS_REFCURSOR;
    BEGIN
        OPEN account_cursor FOR
            SELECT account_number, balance, branch_name
            FROM ACCOUNT
            WHERE account_number = p_account_number;
        
        RETURN account_cursor;
    END show_account_details;

END account_pkg;
/

BEGIN
    account_pkg.deposit_money(p_account_number => 101, p_amount => 500);
END;
/

BEGIN
    account_pkg.withdraw_money(p_account_number => 101, p_amount => 300);
END;
/

DECLARE
    account_cursor SYS_REFCURSOR;
    account_rec ACCOUNT%ROWTYPE;
    v_account_number ACCOUNT.account_number%TYPE := &v_account_number;
BEGIN
    account_cursor := account_pkg.show_account_details(p_account_number => v_account_number);
    LOOP
        FETCH account_cursor INTO account_rec;
        EXIT WHEN account_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Account Number: ' || account_rec.account_number);
        DBMS_OUTPUT.PUT_LINE('Balance: ' || account_rec.balance);
        DBMS_OUTPUT.PUT_LINE('Branch Name: ' || account_rec.branch_name);
    END LOOP;
    
    CLOSE account_cursor;
END;
/

CREATE OR REPLACE TRIGGER before_insert_triggers
BEFORE INSERT ON ACCOUNTS
FOR EACH ROW
BEGIN
  IF :new.BALANCE < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'yOU BROKE');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER after_insert_accounts
AFTER INSERT ON ACCOUNTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Account Number: ' || :new.account_number || 
                         ' Balance: ' || :new.balance || 
                         ' Branch: ' || :new.branch_name);
END;
/

CREATE OR REPLACE TRIGGER before_update_accounts
BEFORE UPDATE ON ACCOUNTS
FOR EACH ROW
BEGIN
    IF :new.balance <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'how so broke');
    END IF;
END;
/
CREATE OR REPLACE TRIGGER after_update_accounts
AFTER UPDATE ON ACCOUNTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updated Account Number: ' || :new.account_number || 
                         ' Balance: ' || :new.balance || 
                         ' Branch: ' || :new.branch_name || 
                         ' Change Time: ' || SYSDATE);  
END;
/
CREATE OR REPLACE TRIGGER before_delete_accounts
BEFORE DELETE ON ACCOUNTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Deleting Account Number: ' || :old.account_number || 
                         ' Balance: ' || :old.balance || 
                         ' Branch: ' || :old.branch_name || 
                         ' Change Time: ' || SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER after_delete_accounts
AFTER DELETE ON ACCOUNTS
FOR EACH ROW
BEGIN
    INSERT INTO delete_log (account_number, deleted_at)
    VALUES (:OLD.account_number, SYSDATE);
  
    DBMS_OUTPUT.PUT_LINE('Account Number ' || :OLD.account_number || ' deleted at ' || SYSDATE);
END;
/
