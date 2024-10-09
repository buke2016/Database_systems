// Load districts
LOAD CSV WITH HEADERS FROM 'file:///district.csv' AS row
CREATE (:District {
    district_id: toInteger(row.district_id),
    A2: row.A2,
    A3: row.A3,
    A4: toInteger(row.A4),
    A5: toInteger(row.A5),
    A6: toInteger(row.A6),
    A7: toInteger(row.A7),
    A8: toInteger(row.A8),
    A9: toInteger(row.A9),
    A10: toFloat(row.A10),
    A11: toInteger(row.A11),
    A12: toFloat(row.A12),
    A13: toFloat(row.A13),
    A14: toInteger(row.A14),
    A15: toInteger(row.A15),
    A16: toInteger(row.A16)
});

// Load clients
LOAD CSV WITH HEADERS FROM 'file:///client.csv' AS row
CREATE (:Client {
    client_id: toInteger(row.client_id),
    gender: row.gender,
    birth_date: date(row.birth_date),
    district_id: toInteger(row.district_id)
});

// Load accounts
LOAD CSV WITH HEADERS FROM 'file:///account.csv' AS row
CREATE (:Account {
    account_id: toInteger(row.account_id),
    district_id: toInteger(row.district_id),
    frequency: row.frequency,
    date: date(row.date)
});

// Load dispositions
LOAD CSV WITH HEADERS FROM 'file:///disp.csv' AS row
CREATE (:Disposition {
    disp_id: toInteger(row.disp_id),
    client_id: toInteger(row.client_id),
    account_id: toInteger(row.account_id),
    type: row.type
});

// Load cards
LOAD CSV WITH HEADERS FROM 'file:///card.csv' AS row
CREATE (:Card {
    card_id: toInteger(row.card_id),
    disp_id: toInteger(row.disp_id),
    type: row.type,
    issued: date(row.issued)
});

// Load loans
LOAD CSV WITH HEADERS FROM 'file:///loan.csv' AS row
CREATE (:Loan {
    loan_id: toInteger(row.loan_id),
    account_id: toInteger(row.account_id),
    date: date(row.date),
    amount: toInteger(row.amount),
    duration: toInteger(row.duration),
    payments: toFloat(row.payments),
    status: row.status
});

// Load orders
LOAD CSV WITH HEADERS FROM 'file:///order.csv' AS row
CREATE (:Order {
    order_id: toInteger(row.order_id),
    account_id: toInteger(row.account_id),
    bank_to: row.bank_to,
    account_to: toInteger(row.account_to),
    amount: toFloat(row.amount),
    k_symbol: row.k_symbol
});


// Create Relationships and Indexes
// Create relationships
MATCH (c:Client), (d:District)
WHERE c.district_id = d.district_id
CREATE (c)-[:LIVES_IN]->(d);

MATCH (a:Account), (d:District)
WHERE a.district_id = d.district_id
CREATE (a)-[:BELONGS_TO]->(d);

MATCH (d:Disposition), (c:Client), (a:Account)
WHERE d.client_id = c.client_id AND d.account_id = a.account_id
CREATE (c)-[:HAS_DISPOSITION]->(d),
       (d)-[:FOR_ACCOUNT]->(a);

MATCH (c:Card), (d:Disposition)
WHERE c.disp_id = d.disp_id
CREATE (c)-[:ASSOCIATED_WITH]->(d);

MATCH (l:Loan), (a:Account)
WHERE l.account_id = a.account_id
CREATE (a)-[:HAS_LOAN]->(l);

MATCH (o:Order), (a:Account)
WHERE o.account_id = a.account_id
CREATE (a)-[:HAS_ORDER]->(o);

MATCH (t:Transaction), (a:Account)
WHERE t.account_id = a.account_id
CREATE (a)-[:HAS_TRANSACTION]->(t);

// Create indexes
CREATE INDEX ON :District(district_id);
CREATE INDEX ON :Client(client_id);
CREATE INDEX ON :Account(account_id);
CREATE INDEX ON :Disposition(disp_id);
CREATE INDEX ON :Card(card_id);
CREATE INDEX ON :Loan(loan_id);
CREATE INDEX ON :Order(order_id);
CREATE INDEX ON :Transaction(trans_id);