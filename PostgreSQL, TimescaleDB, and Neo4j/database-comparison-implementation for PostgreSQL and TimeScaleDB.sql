-- PostgreSQL and TimescaleDB Setup

-- Create PostgreSQL database
CREATE DATABASE financial_loans;
\c financial_loans

-- Create TimescaleDB database
CREATE DATABASE financial_loans_timescale;
\c financial_loans_timescale
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create tables (same for both PostgreSQL and TimescaleDB)
CREATE TABLE Applicants (
    applicant_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE Loan_Types (
    loan_type_id SERIAL PRIMARY KEY,
    loan_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE Loan_Applications (
    application_id SERIAL PRIMARY KEY,
    applicant_id INTEGER REFERENCES Applicants(applicant_id),
    loan_type_id INTEGER REFERENCES Loan_Types(loan_type_id),
    application_date TIMESTAMP NOT NULL,
    requested_amount DECIMAL(15, 2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- Convert Loan_Applications to hypertable in TimescaleDB
SELECT create_hypertable('Loan_Applications', 'application_date');

CREATE TABLE Financial_Information (
    financial_info_id SERIAL PRIMARY KEY,
    applicant_id INTEGER REFERENCES Applicants(applicant_id),
    annual_income DECIMAL(15, 2) NOT NULL,
    employment_status VARCHAR(50) NOT NULL,
    credit_score INTEGER NOT NULL
);

CREATE TABLE Loan_Details (
    loan_detail_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES Loan_Applications(application_id),
    interest_rate DECIMAL(5, 2) NOT NULL,
    term_months INTEGER NOT NULL,
    monthly_payment DECIMAL(15, 2) NOT NULL
);

CREATE TABLE Approval_History (
    approval_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES Loan_Applications(application_id),
    decision VARCHAR(20) NOT NULL,
    decision_date TIMESTAMP NOT NULL,
    decision_maker VARCHAR(100) NOT NULL
);

CREATE TABLE Documents (
    document_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES Loan_Applications(application_id),
    document_type VARCHAR(50) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_loan_applications_date ON Loan_Applications(application_date);
CREATE INDEX idx_financial_info_applicant ON Financial_Information(applicant_id);
CREATE INDEX idx_loan_details_application ON Loan_Details(application_id);
CREATE INDEX idx_approval_history_application ON Approval_History(application_id);
CREATE INDEX idx_documents_application ON Documents(application_id);

-- Neo4j Setup (Cypher queries)

// Create constraints (act like primary keys)
CREATE CONSTRAINT ON (a:Applicant) ASSERT a.applicant_id IS UNIQUE;
CREATE CONSTRAINT ON (l:LoanApplication) ASSERT l.application_id IS UNIQUE;
CREATE CONSTRAINT ON (t:LoanType) ASSERT t.loan_type_id IS UNIQUE;
CREATE CONSTRAINT ON (f:FinancialInformation) ASSERT f.financial_info_id IS UNIQUE;
CREATE CONSTRAINT ON (d:LoanDetail) ASSERT d.loan_detail_id IS UNIQUE;
CREATE CONSTRAINT ON (h:ApprovalHistory) ASSERT h.approval_id IS UNIQUE;
CREATE CONSTRAINT ON (d:Document) ASSERT d.document_id IS UNIQUE;

// Create indexes for better performance
CREATE INDEX ON :Applicant(email);
CREATE INDEX ON :LoanApplication(application_date);
CREATE INDEX ON :LoanType(loan_name);

-- Sample Queries (PostgreSQL/TimescaleDB)

-- Simple query: Retrieve all loan applications for a specific applicant
SELECT * FROM Loan_Applications
WHERE applicant_id = 1;

-- Medium complexity: Find the average loan amount for each loan type, including only approved loans
SELECT lt.loan_name, AVG(la.requested_amount) as avg_loan_amount
FROM Loan_Applications la
JOIN Loan_Types lt ON la.loan_type_id = lt.loan_type_id
WHERE la.status = 'APPROVED'
GROUP BY lt.loan_name;

-- High complexity: Calculate the approval rate for each loan type, considering applicant's credit score and income
WITH applicant_data AS (
    SELECT la.loan_type_id, la.status, fi.credit_score, fi.annual_income
    FROM Loan_Applications la
    JOIN Financial_Information fi ON la.applicant_id = fi.applicant_id
)
SELECT 
    lt.loan_name,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN ad.status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_applications,
    ROUND(SUM(CASE WHEN ad.status = 'APPROVED' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)::NUMERIC * 100, 2) AS approval_rate,
    AVG(ad.credit_score) AS avg_credit_score,
    AVG(ad.annual_income) AS avg_annual_income
FROM applicant_data ad
JOIN Loan_Types lt ON ad.loan_type_id = lt.loan_type_id
GROUP BY lt.loan_name;

-- Very high complexity: Identify potentially fraudulent applications
WITH suspicious_applications AS (
    SELECT 
        la.application_id,
        la.applicant_id,
        la.requested_amount,
        fi.annual_income,
        fi.credit_score,
        COUNT(*) OVER (PARTITION BY la.applicant_id ORDER BY la.application_date 
                       RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW) AS recent_applications
    FROM Loan_Applications la
    JOIN Financial_Information fi ON la.applicant_id = fi.applicant_id
)
SELECT *
FROM suspicious_applications
WHERE requested_amount > annual_income * 2  -- Unusually high loan amount
   OR credit_score < 500  -- Very low credit score
   OR recent_applications > 3;  -- Multiple applications in a short time frame

-- Sample Queries (Neo4j Cypher)

// Simple query: Retrieve all loan applications for a specific applicant
MATCH (a:Applicant {applicant_id: 1})-[:APPLIED_FOR]->(la:LoanApplication)
RETURN la;

// Medium complexity: Find the average loan amount for each loan type, including only approved loans
MATCH (la:LoanApplication {status: 'APPROVED'})-[:OF_TYPE]->(lt:LoanType)
WITH lt.loan_name AS loan_name, AVG(la.requested_amount) AS avg_loan_amount
RETURN loan_name, avg_loan_amount;

// High complexity: Calculate the approval rate for each loan type, considering applicant's credit score and income
MATCH (a:Applicant)-[:APPLIED_FOR]->(la:LoanApplication)-[:OF_TYPE]->(lt:LoanType),
      (a)-[:HAS_FINANCIAL_INFO]->(fi:FinancialInformation)
WITH lt.loan_name AS loan_name, 
     COUNT(la) AS total_applications,
     SUM(CASE WHEN la.status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_applications,
     AVG(fi.credit_score) AS avg_credit_score,
     AVG(fi.annual_income) AS avg_annual_income
RETURN 
    loan_name,
    total_applications,
    approved_applications,
    toFloat(approved_applications) / total_applications * 100 AS approval_rate,
    avg_credit_score,
    avg_annual_income;

// Very high complexity: Identify potentially fraudulent applications
MATCH (a:Applicant)-[:APPLIED_FOR]->(la:LoanApplication),
      (a)-[:HAS_FINANCIAL_INFO]->(fi:FinancialInformation)
WITH a, la, fi,
     size((a)-[:APPLIED_FOR]->(:LoanApplication)) AS application_count
WHERE la.requested_amount > fi.annual_income * 2  // Unusually high loan amount
   OR fi.credit_score < 500  // Very low credit score
   OR application_count > 3  // Multiple applications
RETURN a.applicant_id, la.application_id, la.requested_amount, fi.annual_income, fi.credit_score, application_count;

-- Monitoring Setup

-- Prometheus configuration (prometheus.yml)
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'postgresql'
    static_configs:
      - targets: ['localhost:9187']
  - job_name: 'neo4j'
    static_configs:
      - targets: ['localhost:2004']

-- PostgreSQL Exporter setup
# Install postgresql_exporter
wget https://github.com/wrouesnel/postgres_exporter/releases/download/v0.8.0/postgres_exporter_v0.8.0_linux-amd64.tar.gz
tar xvf postgres_exporter_v0.8.0_linux-amd64.tar.gz
cd postgres_exporter_v0.8.0_linux-amd64

# Run PostgreSQL Exporter
DATA_SOURCE_NAME="postgresql://username:password@localhost:5432/financial_loans?sslmode=disable" ./postgres_exporter

-- Neo4j Exporter setup
# Install neo4j_exporter
go get github.com/neo4j-contrib/neo4j-prometheus-exporter

# Run Neo4j Exporter
NEO4J_URL=http://localhost:7474 NEO4J_AUTH=neo4j:password neo4j_exporter

-- HammerDB setup
# Download and install HammerDB
wget https://github.com/TPC-Council/HammerDB/releases/download/v4.0/HammerDB-4.0-Linux.tar.gz
tar xvf HammerDB-4.0-Linux.tar.gz
cd HammerDB-4.0

# Create HammerDB script (hammerdb_script.tcl)
dbset db postgresql
diset connection pg_host localhost
diset connection pg_port 5432
diset connection pg_user username
diset connection pg_pass password
diset tpcc pg_count_ware 100
diset tpcc pg_num_vu 10
buildschema
loadscript
vuset vu 10
vucreate
vurun

-- JMeter setup
# Download and install JMeter
wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.4.1.tgz
tar xvf apache-jmeter-5.4.1.tgz
cd apache-jmeter-5.4.1/bin

# Create JMeter test plan (jmeter_testplan.jmx)
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.4.1">
  <!-- Add your test plan here -->
</jmeterTestPlan>

# Run JMeter test
./jmeter -n -t jmeter_testplan.jmx -l results.jtl

-- Security Considerations

-- PostgreSQL: Enable SSL
ALTER SYSTEM SET ssl = on;
ALTER SYSTEM SET ssl_cert_file = 'server.crt';
ALTER SYSTEM SET ssl_key_file = 'server.key';

-- Neo4j: Enable authentication and encryption
dbms.security.auth_enabled=true
dbms.ssl.policy.bolt.enabled=true
dbms.ssl.policy.bolt.base_directory=certificates/bolt
dbms.ssl.policy.bolt.private_key=private.key
dbms.ssl.policy.bolt.public_certificate=public.crt

-- Use prepared statements to prevent SQL injection
-- PostgreSQL example:
PREPARE get_applicant_loans(int) AS
SELECT * FROM Loan_Applications WHERE applicant_id = $1;

EXECUTE get_applicant_loans(1);

-- Neo4j example:
MATCH (a:Applicant {applicant_id: $applicant_id})-[:APPLIED_FOR]->(la:LoanApplication)
RETURN la;

-- Parameters: {applicant_id: 1}

-- Regularly update and patch your database systems
-- Set up automated backups
-- Implement proper access controls and user management
-- Use encryption for sensitive data
-- Regularly audit and monitor database access and queries
