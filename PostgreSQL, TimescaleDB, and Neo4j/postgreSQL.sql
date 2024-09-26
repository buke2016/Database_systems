-- Query 1: Retrieve customer information and account balances
SELECT c.customer_id, c.customer_name, a.account_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id;

-- Query 2: Calculate aggregate transaction amounts by region
SELECT r.region, SUM(t.transaction_amount) AS total_transaction_amount
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN regions r ON c.region_id = r.region_id
GROUP BY r.region;

-- Query 3: Identify top-performing financial instruments
SELECT f.financial_instrument, SUM(t.transaction_amount) AS total_transaction_amount
FROM transactions t
JOIN financial_instruments f ON t.financial_instrument_id = f.financial_instrument_id
GROUP BY f.financial_instrument
ORDER BY total_transaction_amount DESC
LIMIT 10;

-- Query 4: Analyze customer behavior and transaction patterns
SELECT c.customer_id, COUNT(t.transaction_id) AS num_transactions, SUM(t.transaction_amount) AS total_transaction_amount
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id
ORDER BY num_transactions DESC
LIMIT 10;