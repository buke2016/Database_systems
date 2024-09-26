-- Query 1: Retrieve time-series data for a specific financial instrument
SELECT time_bucket('1 day', t.transaction_time) AS day, SUM(t.transaction_amount) AS total_transaction_amount
FROM transactions t
WHERE t.financial_instrument_id = 1
GROUP BY day
ORDER BY day;

-- Query 2: Calculate aggregate transaction amounts by region over time
SELECT time_bucket('1 week', t.transaction_time) AS week, r.region, SUM(t.transaction_amount) AS total_transaction_amount
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN regions r ON c.region_id = r.region_id
GROUP BY week, r.region
ORDER BY week;

-- Query 3: Identify top-performing financial instruments over time
SELECT time_bucket('1 month', t.transaction_time) AS month, f.financial_instrument, SUM(t.transaction_amount) AS total_transaction_amount
FROM transactions t
JOIN financial_instruments f ON t.financial_instrument_id = f.financial_instrument_id
GROUP BY month, f.financial_instrument
ORDER BY month, total_transaction_amount DESC;

-- Query 4: Analyze customer behavior and transaction patterns over time
SELECT time_bucket('1 quarter', t.transaction_time) AS quarter, c.customer_id, COUNT(t.transaction_id) AS num_transactions, SUM(t.transaction_amount) AS total_transaction_amount
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY quarter, c.customer_id
ORDER BY quarter, num_transactions DESC;