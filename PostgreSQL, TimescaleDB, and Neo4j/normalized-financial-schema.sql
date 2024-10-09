-- Applicants table
CREATE TABLE Applicants (
    applicant_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    email VARCHAR(100),
    phone VARCHAR(20)
);

-- Loan_Types table
CREATE TABLE Loan_Types (
    loan_type_id SERIAL PRIMARY KEY,
    loan_name VARCHAR(50),
    description TEXT
);

-- Loan_Applications table
CREATE TABLE Loan_Applications (
    application_id SERIAL PRIMARY KEY,
    applicant_id INTEGER REFERENCES Applicants(applicant_id),
    loan_type_id INTEGER REFERENCES Loan_Types(loan_type_id),
    application_date DATE,
    requested_amount DECIMAL(15, 2),
    status VARCHAR(20)
);

-- Financial_Information table
CREATE TABLE Financial_Information (
    financial_info_id SERIAL PRIMARY KEY,
    applicant_id INTEGER REFERENCES Applicants(applicant_id),
    annual_income DECIMAL(15, 2),
    employment_status VARCHAR(50),
    credit_score INTEGER
);

-- Loan_Details table
CREATE TABLE Loan_Details (
    loan_detail_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES Loan_Applications(application_id),
    interest_rate DECIMAL(5, 2),
    term_months INTEGER,
    monthly_payment DECIMAL(15, 2)
);

-- Approval_History table
CREATE TABLE Approval_History (
    approval_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES Loan_Applications(application_id),
    decision VARCHAR(20),
    decision_date DATE,
    decision_maker VARCHAR(100)
);

-- Documents table
CREATE TABLE Documents (
    document_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES Loan_Applications(application_id),
    document_type VARCHAR(50),
    file_path VARCHAR(255),
    upload_date DATE
);
