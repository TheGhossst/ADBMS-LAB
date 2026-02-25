CREATE TABLE CUSTOMER (
    id NUMBER PRIMARY KEY NOT NULL,
    name VARCHAR2(50),
    age NUMBER CHECK (age > 0),
    gender VARCHAR2(10) CHECK gender IN ('m', 'f', 'ym');
    profession VARCHAR2(50)
);

CREATE TABLE shop_details (
    shop_name VARCHAR2(50) PRIMARY KEY,
    area VARCHAR2(50),
    place VARCHAR2(50)
);

CREATE TABLE items (
    i_name VARCHAR2(50) PRIMARY KEY,
    brand VARCHAR2(50),
    cost NUMBER check (cost >= 0)
);

CREATE TABLE transactions (
    tid NUMBER,
    purchase_date DATE,
    id NUMBER,
    shop_name VARCHAR2(50),
    i_name VARCHAR2(50),
    PRIMARY KEY (id, shop_name, i_name),
    FOREIGN KEY (id) REFERENCES cust(id),
    FOREIGN KEY (shop_name) REFERENCES shop_details(shop_name),
    FOREIGN KEY (i_name) REFERENCES items(i_name)
)
  
