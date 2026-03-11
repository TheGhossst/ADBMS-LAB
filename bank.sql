CREATE TABLE ACCOUNTS (
    account_number INT PRIMARY KEY,
    balance        INT NOT NULL,
    branch_name    INT
);

CREATE TABLE BRANCH (
    branch_name INT PRIMARY KEY,
    branch_city VARCHAR2(29),
    assets      VARCHAR2(20)
);

CREATE TABLE CUSTOMER (
    customer_name   VARCHAR2(29) PRIMARY KEY,
    customer_street VARCHAR2(29),
    customer_city   VARCHAR2(20)
);

CREATE TABLE DEPOSITOR (
    account_number INT,
    customer_name  VARCHAR2(39),
    PRIMARY KEY (account_number, customer_name),
    FOREIGN KEY (account_number) REFERENCES ACCOUNTS(account_number),
    FOREIGN KEY (customer_name)  REFERENCES CUSTOMER(customer_name)
);

CREATE TABLE LOAN (
    loan_number INT PRIMARY KEY,
    amount      INT NOT NULL,
    branch_name INT
);

CREATE TABLE BORROWER (
    customer_name VARCHAR2(29),
    loan_number   INT,
    PRIMARY KEY (customer_name, loan_number),
    FOREIGN KEY (customer_name) REFERENCES CUSTOMER(customer_name),
    FOREIGN KEY (loan_number)   REFERENCES LOAN(loan_number)
);

CREATE TABLE DELETE_LOG (
    log_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_number INT,
    deleted_at     DATE
);


INSERT INTO BRANCH VALUES (1, 'Mumbai',    '5000000');
INSERT INTO BRANCH VALUES (2, 'Delhi',     '7500000');
INSERT INTO BRANCH VALUES (3, 'Bangalore', '6200000');
INSERT INTO BRANCH VALUES (4, 'Chennai',   '4800000');
INSERT INTO BRANCH VALUES (5, 'Pune',      '3100000');

INSERT INTO CUSTOMER VALUES ('Alice',   '12 MG Road',      'Mumbai');
INSERT INTO CUSTOMER VALUES ('Bob',     '45 Nehru Street',  'Delhi');
INSERT INTO CUSTOMER VALUES ('Charlie', '78 Brigade Road',  'Bangalore');
INSERT INTO CUSTOMER VALUES ('Diana',   '33 Anna Salai',    'Chennai');
INSERT INTO CUSTOMER VALUES ('Edward',  '21 FC Road',       'Pune');

INSERT INTO ACCOUNTS VALUES (101, 25000, 1);
INSERT INTO ACCOUNTS VALUES (102, 12000, 2);
INSERT INTO ACCOUNTS VALUES (103, 47000, 3);
INSERT INTO ACCOUNTS VALUES (104,  8000, 4);
INSERT INTO ACCOUNTS VALUES (105, 31000, 5);

INSERT INTO DEPOSITOR VALUES (101, 'Alice');
INSERT INTO DEPOSITOR VALUES (102, 'Bob');
INSERT INTO DEPOSITOR VALUES (103, 'Charlie');
INSERT INTO DEPOSITOR VALUES (104, 'Diana');
INSERT INTO DEPOSITOR VALUES (105, 'Edward');

INSERT INTO LOAN VALUES (201, 50000, 1);
INSERT INTO LOAN VALUES (202, 30000, 2);
INSERT INTO LOAN VALUES (203, 75000, 3);
INSERT INTO LOAN VALUES (204, 20000, 4);
INSERT INTO LOAN VALUES (205, 45000, 5);

INSERT INTO BORROWER VALUES ('Alice',   201);
INSERT INTO BORROWER VALUES ('Bob',     202);
INSERT INTO BORROWER VALUES ('Charlie', 203);
INSERT INTO BORROWER VALUES ('Diana',   204);
INSERT INTO BORROWER VALUES ('Edward',  205);

COMMIT;


CREATE OR REPLACE PROCEDURE TRANSFER_MONEY(
    p_from_account IN INT,
    p_to_account   IN INT,
    p_amount       IN INT
) IS
    v_balance INT;
BEGIN
    SELECT balance INTO v_balance
    FROM ACCOUNTS
    WHERE account_number = p_from_account;

    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds for transfer.');
    END IF;

    UPDATE ACCOUNTS
    SET balance = balance - p_amount
    WHERE account_number = p_from_account;

    UPDATE ACCOUNTS
    SET balance = balance + p_amount
    WHERE account_number = p_to_account;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer of ' || p_amount ||
                         ' from Account ' || p_from_account ||
                         ' to Account '   || p_to_account || ' successful.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Account not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END TRANSFER_MONEY;
/


CREATE OR REPLACE FUNCTION GET_BRANCH_TOTAL_BALANCE(
    p_branch_name IN INT
) RETURN INT IS
    v_total INT;
BEGIN
    SELECT NVL(SUM(balance), 0) INTO v_total
    FROM ACCOUNTS
    WHERE branch_name = p_branch_name;

    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END GET_BRANCH_TOTAL_BALANCE;
/


CREATE OR REPLACE PACKAGE account_pkg AS
    PROCEDURE deposit_money(
        p_account_number IN INT,
        p_amount         IN INT
    );
    PROCEDURE withdraw_money(
        p_account_number IN INT,
        p_amount         IN INT
    );
    FUNCTION show_account_details(
        p_account_number IN INT
    ) RETURN SYS_REFCURSOR;
    FUNCTION get_balance(
        p_account_number IN INT
    ) RETURN INT;
END account_pkg;
/

CREATE OR REPLACE PACKAGE BODY account_pkg AS

    PROCEDURE deposit_money(
        p_account_number IN INT,
        p_amount         IN INT
    ) IS
    BEGIN
        IF p_amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Deposit amount must be positive.');
        END IF;

        UPDATE ACCOUNTS
        SET balance = balance + p_amount
        WHERE account_number = p_account_number;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Account ' || p_account_number || ' not found.');
        END IF;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Deposited ' || p_amount || ' to Account ' || p_account_number || '.');
    END deposit_money;

    PROCEDURE withdraw_money(
        p_account_number IN INT,
        p_amount         IN INT
    ) IS
        v_balance INT;
    BEGIN
        IF p_amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Withdrawal amount must be positive.');
        END IF;

        SELECT balance INTO v_balance
        FROM ACCOUNTS
        WHERE account_number = p_account_number;

        IF v_balance >= p_amount THEN
            UPDATE ACCOUNTS
            SET balance = balance - p_amount
            WHERE account_number = p_account_number;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Withdrew ' || p_amount || ' from Account ' || p_account_number || '.');
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds for withdrawal.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Account ' || p_account_number || ' not found.');
    END withdraw_money;

    FUNCTION show_account_details(
        p_account_number IN INT
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT a.account_number,
                   a.balance,
                   a.branch_name,
                   b.branch_city
            FROM   ACCOUNTS a
            JOIN   BRANCH   b ON a.branch_name = b.branch_name
            WHERE  a.account_number = p_account_number;

        RETURN v_cursor;
    END show_account_details;

    FUNCTION get_balance(
        p_account_number IN INT
    ) RETURN INT IS
        v_balance INT;
    BEGIN
        SELECT balance INTO v_balance
        FROM ACCOUNTS
        WHERE account_number = p_account_number;

        RETURN v_balance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Account ' || p_account_number || ' not found.');
    END get_balance;

END account_pkg;
/


CREATE OR REPLACE VIEW V_ACCOUNT_SUMMARY AS
    SELECT
        a.account_number,
        a.balance,
        b.branch_name,
        b.branch_city,
        c.customer_name,
        c.customer_street,
        c.customer_city
    FROM  ACCOUNTS  a
    JOIN  BRANCH    b ON a.branch_name    = b.branch_name
    JOIN  DEPOSITOR d ON a.account_number = d.account_number
    JOIN  CUSTOMER  c ON d.customer_name  = c.customer_name;
/

CREATE OR REPLACE VIEW V_LOAN_SUMMARY AS
    SELECT
        l.loan_number,
        l.amount,
        b.branch_name,
        b.branch_city,
        c.customer_name
    FROM  LOAN     l
    JOIN  BRANCH   b ON l.branch_name   = b.branch_name
    JOIN  BORROWER r ON l.loan_number   = r.loan_number
    JOIN  CUSTOMER c ON r.customer_name = c.customer_name;
/


DECLARE
    CURSOR c_low_balance IS
        SELECT account_number, balance, branch_name
        FROM   ACCOUNTS
        WHERE  balance < 20000
        ORDER BY balance;

    v_rec c_low_balance%ROWTYPE;
BEGIN
    OPEN c_low_balance;
    LOOP
        FETCH c_low_balance INTO v_rec;
        EXIT WHEN c_low_balance%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Account: ' || v_rec.account_number ||
                             ' | Balance: ' || v_rec.balance ||
                             ' | Branch: '  || v_rec.branch_name);
    END LOOP;
    CLOSE c_low_balance;
END;
/

DECLARE
    v_cursor         SYS_REFCURSOR;
    v_account_number ACCOUNTS.account_number%TYPE;
    v_balance        ACCOUNTS.balance%TYPE;
    v_branch_name    ACCOUNTS.branch_name%TYPE;
    v_branch_city    BRANCH.branch_city%TYPE;
    p_acc_no         INT := &p_account_number;
BEGIN
    v_cursor := account_pkg.show_account_details(p_account_number => p_acc_no);

    LOOP
        FETCH v_cursor INTO v_account_number, v_balance, v_branch_name, v_branch_city;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Account No : ' || v_account_number);
        DBMS_OUTPUT.PUT_LINE('Balance    : ' || v_balance);
        DBMS_OUTPUT.PUT_LINE('Branch     : ' || v_branch_name);
        DBMS_OUTPUT.PUT_LINE('City       : ' || v_branch_city);
    END LOOP;

    CLOSE v_cursor;
END;
/


CREATE OR REPLACE TRIGGER trg_before_insert_accounts
BEFORE INSERT ON ACCOUNTS
FOR EACH ROW
BEGIN
    IF :NEW.balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot create account with negative balance.');
    END IF;
END trg_before_insert_accounts;
/

CREATE OR REPLACE TRIGGER trg_after_insert_accounts
AFTER INSERT ON ACCOUNTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('[INSERT] Account No: ' || :NEW.account_number ||
                         ' | Balance: '    || :NEW.balance ||
                         ' | Branch: '     || :NEW.branch_name ||
                         ' | Time: '       || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END trg_after_insert_accounts;
/

CREATE OR REPLACE TRIGGER trg_before_update_accounts
BEFORE UPDATE ON ACCOUNTS
FOR EACH ROW
BEGIN
    IF :NEW.balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Balance cannot go negative after update.');
    END IF;
END trg_before_update_accounts;
/

CREATE OR REPLACE TRIGGER trg_after_update_accounts
AFTER UPDATE ON ACCOUNTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('[UPDATE] Account No: '  || :NEW.account_number ||
                         ' | Old Balance: '       || :OLD.balance ||
                         ' | New Balance: '       || :NEW.balance ||
                         ' | Branch: '            || :NEW.branch_name ||
                         ' | Time: '              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END trg_after_update_accounts;
/

CREATE OR REPLACE TRIGGER trg_before_delete_accounts
BEFORE DELETE ON ACCOUNTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('[DELETE - BEFORE] Account No: ' || :OLD.account_number ||
                         ' | Balance: '  || :OLD.balance ||
                         ' | Branch: '   || :OLD.branch_name ||
                         ' | Time: '     || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END trg_before_delete_accounts;
/

CREATE OR REPLACE TRIGGER trg_after_delete_accounts
AFTER DELETE ON ACCOUNTS
FOR EACH ROW
BEGIN
    INSERT INTO DELETE_LOG (account_number, deleted_at)
    VALUES (:OLD.account_number, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('[DELETE - AFTER] Account No: ' || :OLD.account_number ||
                         ' archived to DELETE_LOG at ' ||
                         TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END trg_after_delete_accounts;
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
    v_bal INT;
BEGIN
    v_bal := account_pkg.get_balance(p_account_number => 101);
    DBMS_OUTPUT.PUT_LINE('Current Balance: ' || v_bal);
END;
/

BEGIN
    TRANSFER_MONEY(
        p_from_account => 101,
        p_to_account   => 102,
        p_amount       => 200
    );
END;
/

DECLARE
    v_total INT;
BEGIN
    v_total := GET_BRANCH_TOTAL_BALANCE(p_branch_name => 1);
    DBMS_OUTPUT.PUT_LINE('Branch Total Balance: ' || v_total);
END;
/
