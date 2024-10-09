-- import psycopg2

-- -- Connect to your postgres DB
-- conn = psycopg2.connect(dbname='finpractice', user='postgres', password='postgres', host='localhost')
--                         conn.close()


-- -- Create a cursor object using the cursor() method
-- cursor = conn.cursor()


import psycopg2

-- # Define the SQL script
sql_script = """
-- District table
CREATE TABLE IF NOT EXISTS district (
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
CREATE TABLE IF NOT EXISTS client (
    client_id INT PRIMARY KEY,
    gender VARCHAR(10),
    birth_date DATE,
    district_id INT,
    FOREIGN KEY (district_id) REFERENCES district(district_id)
);

-- Account table
CREATE TABLE IF NOT EXISTS account (
    account_id INT PRIMARY KEY,
    district_id INT,
    frequency VARCHAR(50),
    date DATE,
    FOREIGN KEY (district_id) REFERENCES district(district_id)
);

-- Disposition table (renamed from 'disp' for clarity)
CREATE TABLE IF NOT EXISTS disposition (
    disp_id INT PRIMARY KEY,
    client_id INT,
    account_id INT,
    type VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES client(client_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Card table
CREATE TABLE IF NOT EXISTS card (
    card_id INT PRIMARY KEY,
    disp_id INT,
    type VARCHAR(50),
    issued DATE,
    FOREIGN KEY (disp_id) REFERENCES disposition(disp_id)
);

-- Loan table
CREATE TABLE IF NOT EXISTS loan (
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
CREATE TABLE IF NOT EXISTS bank_order (
    order_id INT PRIMARY KEY,
    account_id INT,
    bank_to VARCHAR(255),
    account_to INT,
    amount DECIMAL,
    k_symbol VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Transaction table (renamed from 'trans' for clarity)
CREATE TABLE IF NOT EXISTS "transaction" (
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
"""

try:
    # Establish a database connection
    connection = psycopg2.connect(
        host="localhost",
        database="Finpractice",
        user="postgres",
        password="19881114$",
        port="5432"
    )

    # Create a cursor object
    cursor = connection.cursor()

    # Execute the SQL script to create tables
    cursor.execute(sql_script)
    connection.commit()

    # Run a sample query
    sample_query = "SELECT * FROM client;"
    cursor.execute(sample_query)
    results = cursor.fetchall()

    # Print the results
    for row in results:
        print(row)

except (Exception, psycopg2.DatabaseError) as error:
    print(f"Error: {error}")
    if connection:
        connection.rollback()
finally:
    if cursor:
        cursor.close()
    if connection:
        connection.close()