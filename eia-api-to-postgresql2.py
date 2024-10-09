import requests
import json
import psycopg2
from datetime import datetime

# EIA API setup
API_KEY = 'YOUR_API_KEY_HERE'
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
    'dbname': 'postgres',  # Changed to 'postgres', the default database
    'user': 'postgres',
    'password': '19881114$',
    'host': 'localhost',
    'port': '5432'
}

try:
    # Connect to the PostgreSQL server (not a specific database)
    conn = psycopg2.connect(**db_params)
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cursor = conn.cursor()
    
    # Create a new database
    new_db_name = 'eia_data'
    cursor.execute(f"CREATE DATABASE {new_db_name}")
    print(f"Database '{new_db_name}' created successfully.")
    
    # Close the connection to the 'postgres' database
    cursor.close()
    conn.close()
    
    # Update the connection parameters to use the new database
    db_params['dbname'] = new_db_name
    
    # Connect to the new database
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

    # Commit the changes
    conn.commit()
    print("Data has been successfully loaded into the PostgreSQL database.")

    # Example query to verify the data
    cursor.execute('SELECT AVG(value) FROM wind_generation')
    avg_generation = cursor.fetchone()[0]
    print(f"Average wind generation: {avg_generation}")

except psycopg2.Error as e:
    print(f"An error occurred: {e}")

finally:
    # Close the cursor and connection
    if cursor:
        cursor.close()
    if conn:
        conn.close()
