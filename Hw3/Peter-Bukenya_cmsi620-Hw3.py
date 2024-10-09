import requests
import json
import sqlite3
import os
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

# Get the API key from environment variables
API_KEY = os.getenv('EIA_API_KEY')  
if not API_KEY:
    print("API Key is missing! Make sure it's correctly stored in the .env file.")
    exit()

BASE_URL = 'https://api.eia.gov/v2/'

# Query for net generation from all energy types (including wind, solar, etc.)
endpoint = 'electricity/electric-power-operational-data/data/'
params = {
    'api_key': API_KEY,    
    'frequency': 'monthly',
    'data': ['value'],
    'facets[sectorid][]': ['99'],  
    'start': '2022-01',
    'end': '2022-12',
    'sort[0][column]': 'period',
    'sort[0][direction]': 'desc'
}

response = requests.get(BASE_URL + endpoint, params=params)

if response.status_code == 200:
    data = json.loads(response.text)

    # Print the data to verify
    print(json.dumps(data, indent=2))

    # Create or connect to the SQLite database
    conn = sqlite3.connect('energy_data.db')
    cursor = conn.cursor()

    # Create tables for general energy statistics (including production/consumption)
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS energy_stats (
        date TEXT,
        energy_type TEXT,
        consumption REAL,
        production REAL
    )
    ''')

    # Insert data into the table, filtering for relevant fields
    for row in data['response']['data']:
        # Extract date and energy type from the API response
        date = row.get('period')
        if date:
            date = datetime.strptime(date, '%Y-%m').strftime('%Y-%m-%d')
        else:
            continue  # Skip rows without a valid date

        # Extract energy type and consumption
        energy_type = row.get('fueltypeid', 'UNKNOWN')
        consumption = row.get('value', 0)  # Assuming 'value' represents consumption
        production = consumption  # This is an assumption; adjust based on actual API response

        # Insert data into the energy_stats table
        cursor.execute('INSERT INTO energy_stats (date, energy_type, consumption, production) VALUES (?, ?, ?, ?)', 
                       (date, energy_type, consumption, production))

    # Commit the changes
    conn.commit()

    # Analyzing the data
    # 1. Average total consumption and production
    cursor.execute('SELECT AVG(consumption), AVG(production) FROM energy_stats')
    avg_consumption, avg_production = cursor.fetchone()
    print(f"Average Total Consumption: {avg_consumption}")
    print(f"Average Total Production: {avg_production}")

    # 2. Query the most popular (most consumed) energy source per month
    cursor.execute('''
    SELECT date, energy_type, MAX(consumption)
    FROM energy_stats
    GROUP BY date
    ''')
    most_popular_per_month = cursor.fetchall()
    for row in most_popular_per_month:
        print(f"Month: {row[0]}, Most Consumed Energy Source: {row[1]}, Consumption: {row[2]}")

    # 3. Start a transaction to remove all export data
    try:
        conn.execute('BEGIN TRANSACTION')
        cursor.execute("DELETE FROM energy_stats WHERE energy_type = 'EXPORT'")

        # Preview the deletion
        cursor.execute("SELECT * FROM energy_stats WHERE energy_type = 'EXPORT'")
        if cursor.fetchall():
            print("Export data still exists. Something went wrong.")
        else:
            print("Export data successfully removed.")

        # Rollback the transaction
        conn.rollback()
        print("Rollback completed. Export data was not deleted.")

    except sqlite3.Error as e:
        print(f"Error during transaction: {e}")
        conn.rollback()

    # Close the connection
    conn.close()

else:
    print(f"Error: {response.status_code} - {response.text}")
