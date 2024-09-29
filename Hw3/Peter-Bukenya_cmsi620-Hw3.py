import requests
import json
import sqlite3
from datetime import datetime

API_KEY = 'U4VVlmknoEZ900NSj0tKy13SR2rK4bFF7XCaOxRG'
BASE_URL = 'https://api.eia.gov/v2/'

# Query for net generation from wind
endpoint = 'electricity/electric-power-operational-data/data/'
params = {
    'api_key': API_KEY,
    'frequency': 'monthly',
    'data': ['value'],
    'facets[fueltypeid][]': ['WND'],  # Correct facet structure for fuel type (wind)
    'facets[sectorid][]': ['99'],     # Correct facet structure for sector (all sectors)
    'start': '2022-01',
    'end': '2022-12',
    'sort[0][column]': 'period',      # Correct sort structure with index [0]
    'sort[0][direction]': 'desc',     # Sort direction: descending (most recent first)
}

response = requests.get(BASE_URL + endpoint, params=params)

# Check if the response was successful
if response.status_code == 200:
    data = json.loads(response.text)

    # Print the data to verify
    print(json.dumps(data, indent=2))

    # Loading data into a SQL database
    # Create or connect to the SQLite database
    conn = sqlite3.connect('wind_generation.db')
    cursor = conn.cursor()

    # Create a table to store the data
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS wind_generation (
        date TEXT,
        value REAL
    )
    ''')

    # Insert the data into the table
    for row in data['response']['data']:
        print(f"Row data: {row}")  # Debug: print each row to check its structure

        # Extract the date and value, handle missing keys
        date = row.get('period')  # Ensure 'period' key exists
        if date:
            date = datetime.strptime(date, '%Y-%m').strftime('%Y-%m-%d')  # Format date
        else:
            print("Missing 'period' in row, skipping...")
            continue  # Skip rows without 'period'

        value = row.get('value')  # Handle missing 'value' key
        if value is None:
            print("Missing 'value' in row, setting default to 0")
            value = 0  # Set a default value if 'value' key is missing

        cursor.execute('INSERT INTO wind_generation (date, value) VALUES (?, ?)', (date, value))

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data has been successfully loaded into the SQLite database.")

    # Analyzing the database
    conn = sqlite3.connect('wind_generation.db')
    cursor = conn.cursor()

    # Example query: Get the average wind generation for the year
    cursor.execute('SELECT AVG(value) FROM wind_generation')
    avg_generation = cursor.fetchone()[0]
    print(f"Average wind generation: {avg_generation}")

    conn.close()
else:
    print(f"Error: {response.status_code} - {response.text}")
