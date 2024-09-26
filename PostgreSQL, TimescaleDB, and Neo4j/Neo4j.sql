// Query 1: Retrieve customer information and account balances
MATCH (c:Customer)-[:HAS_ACCOUNT]->(a:Account)
RETURN c.customer_id, c.customer_name, a.account_balance;

// Query 2: Calculate aggregate transaction amounts by region
MATCH (t:Transaction)-[:INVOLVES]->(c:Customer)-[:LIVES_IN]->(r:Region)
RETURN r.region, SUM(t.transaction_amount) AS total_transaction_amount;

// Query 3: Identify top-performing financial instruments
MATCH (t:Transaction)-[:INVOLVES]->(f:FinancialInstrument)
RETURN f.financial_instrument, SUM(t.transaction_amount) AS total_transaction_amount
ORDER BY total_transaction_amount DESC
LIMIT 10;

// Query 4: Analyze customer behavior and transaction patterns
MATCH (c:Customer)-[:MADE]->(t:Transaction)
RETURN c.customer_id, COUNT(t.transaction_id) AS num_transactions, SUM(t.transaction_amount) AS total_transaction_amount
ORDER BY num_transactions DESC
LIMIT 10;