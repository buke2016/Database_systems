import requests
import json
import psycopg2
from datetime import datetime

# EIA API setup
API_KEY = 'U4VVlmknoEZ900NSj0tKy13SR2rK4bFF7XCaOxRG'
BASE_URL = 'https://api.eia.gov/v2/'

# Query for net generation from wind
endpoint = 'electricity/electric-power-operational-data/data/'
params = {
    'api_key': API_KEY,
    'frequency': 'monthly',
    'data': ['value'],
    'facets': {
        'fueltypeid': ['WND'],
        'sectorid': ['99'],
    },
    'start': '2022-01',
    'end': '2022-12',
    'sort': [
        {'column': 'period', 'direction': 'desc'},
    ],
}

# Fetch data from EIA API
response = requests.get(BASE_URL + endpoint, params=params)
data = json.loads(response.text)

# PostgreSQL connection setup
db_params = {
    'dbname': 'Electricity/Electric Power Operations(Annually And Monthly)',
    'user': 'postgres',
    'password': '19881114$',
    'host': 'localhost',
    'port': '5432'
}

# Connect to the PostgreSQL database
conn = psycopg2.connect(**db_params)
cursor = conn.cursor()

# Create a table to store the data
cursor.execute('''
CREATE TABLE IF NOT EXISTS wind_generation (
    id SERIAL PRIMARY KEY,
    date DATE,
    value NUMERIC
)
''')

# Insert the data into the table
for row in data['response']['data']:
    date = datetime.strptime(row['period'], '%Y-%m').date()
    value = row['value']
    cursor.execute(
        'INSERT INTO wind_generation (date, value) VALUES (%s, %s)',
        (date, value)
    )

# Commit the changes and close the connection
conn.commit()
cursor.close()
conn.close()

print("Data has been successfully loaded into the PostgreSQL database.")

# Example query to verify the data
conn = psycopg2.connect(**db_params)
cursor = conn.cursor()

cursor.execute('SELECT AVG(value) FROM wind_generation')
avg_generation = cursor.fetchone()[0]
print(f"Average wind generation: {avg_generation}")

cursor.close()
conn.close()
