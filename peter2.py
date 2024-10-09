import requests
import json
import sqlite3
from datetime import datetime
import csv
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get API key from environment variable
API_KEY = os.getenv('C:\\Users\\bukep\\Desktop\\Database_systems\\EIA_API_KEY.txt')
BASE_URL = 'https://api.eia.gov/v2/'

# Query for net generation from wind
endpoint = 'electricity/electric-power-operational-data/data/'
params = {
    'api_key': API_KEY,
    'frequency': 'monthly',
    'data': ['value'],
    'facets[fueltypeid][]': ['WND'],
    'facets[sectorid][]': ['99'],
    'start': '2022-01',
    'end': '2022-12',
    'sort[0][column]': 'period',
    'sort[0][direction]': 'desc',
}

response = requests.get(BASE_URL + endpoint, params=params)

if response.status_code == 200:
    data = json.loads(response.text)

    print(json.dumps(data, indent=2))

    conn = sqlite3.connect('energy_data.db')
    cursor = conn.cursor()

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS energy_data (
        date TEXT,
        fuel_type TEXT,
        value REAL,
        type TEXT
    )
    ''')

    for row in data['response']['data']:
        date = row.get('period')
        if date:
            date = datetime.strptime(date, '%Y-%m').strftime('%Y-%m-%d')
        else:
            print("Missing 'period' in row, skipping...")
            continue

        value = row.get('value', 0)
        fuel_type = 'WND'
        type = 'production'

        cursor.execute('INSERT INTO energy_data (date, fuel_type, value, type) VALUES (?, ?, ?, ?)', 
                       (date, fuel_type, value, type))

    conn.commit()

    # Add average total consumption and production
    cursor.execute('''
    SELECT AVG(value) as avg_value, type
    FROM energy_data
    GROUP BY type
    ''')
    averages = cursor.fetchall()
    print("\nAverage consumption and production:")
    for row in averages:
        print(f"Average {row[1]}: {row[0]}")

    # Query the most popular energy source per month
    cursor.execute('''
    SELECT date, fuel_type, MAX(value) as max_value
    FROM energy_data
    WHERE type = 'consumption'
    GROUP BY date
    ORDER BY date
    ''')
    popular_sources = cursor.fetchall()
    print("\nMost consumed energy source per month:")
    for row in popular_sources:
        print(f"{row[0]}: {row[1]} ({row[2]})")

    # Transaction to remove all export data
    cursor.execute('BEGIN TRANSACTION')
    try:
        cursor.execute('DELETE FROM energy_data WHERE type = "export"')
        print("\nExport data removed.")
        cursor.execute('COMMIT')
    except:
        cursor.execute('ROLLBACK')
        print("Transaction rolled back.")

    # Export data to CSV
    cursor.execute('SELECT * FROM energy_data')
    data_to_export = cursor.fetchall()

    with open('energy_data_export.csv', 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['Date', 'Fuel Type', 'Value', 'Type'])  # Write header
        csv_writer.writerows(data_to_export)

    print("\nData exported to energy_data_export.csv")

    conn.close()

    print("Data has been successfully processed, analyzed, and exported.")

else:
    print(f"Error: {response.status_code} - {response.text}")