-- District table
CREATE TABLE district (
    district_id INT PRIMARY KEY,
    A2 VARCHAR(255),
    A3 VARCHAR(255),
    A4 INT,
    A5 INT,
    A6 INT,
    A7 INT,
    A8 INT,
    A9 INT,
    A10 DECIMAL,
    A11 INT,
    A12 DECIMAL,
    A13 DECIMAL,
    A14 INT,
    A15 INT,
    A16 INT
);

-- Client table
CREATE TABLE client (
    client_id INT PRIMARY KEY,
    gender VARCHAR(10),
    birth_date DATE,
    district_id INT,
    FOREIGN KEY (district_id) REFERENCES district(district_id)
);

-- Account table
CREATE TABLE account (
    account_id INT PRIMARY KEY,
    district_id INT,
    frequency VARCHAR(50),
    date DATE,
    FOREIGN KEY (district_id) REFERENCES district(district_id)
);

-- Disposition table (renamed from 'disp' for clarity)
CREATE TABLE disposition (
    disp_id INT PRIMARY KEY,
    client_id INT,
    account_id INT,
    type VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES client(client_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Card table
CREATE TABLE card (
    card_id INT PRIMARY KEY,
    disp_id INT,
    type VARCHAR(50),
    issued DATE,
    FOREIGN KEY (disp_id) REFERENCES disposition(disp_id)
);

-- Loan table
CREATE TABLE loan (
    loan_id INT PRIMARY KEY,
    account_id INT,
    date DATE,
    amount INT,
    duration INT,
    payments DECIMAL,
    status VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Order table (renamed from 'order' as it's a reserved keyword)
CREATE TABLE bank_order (
    order_id INT PRIMARY KEY,
    account_id INT,
    bank_to VARCHAR(255),
    account_to INT,
    amount DECIMAL,
    k_symbol VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Transaction table (renamed from 'trans' for clarity)
CREATE TABLE "transaction" (
    trans_id INT PRIMARY KEY,
    account_id INT,
    date DATE,
    type VARCHAR(50),
    operation VARCHAR(50),
    amount INT,
    balance INT,
    k_symbol VARCHAR(50),
    bank VARCHAR(255),
    account INT,
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);
