import re
import csv

def extract_data_from_sql(sql_file, output_dir):
    with open(sql_file, 'r') as file:
        sql_content = file.read()

    # Regular expression to match INSERT statements
    insert_regex = re.compile(r"INSERT INTO `(\w+)` \((.*?)\) VALUES (.*?);", re.DOTALL)

    matches = insert_regex.findall(sql_content)

    for match in matches:
        table_name = match[0]
        columns = match[1].split(', ')
        values = match[2].split('), (')

        # Clean up values
        values = [v.strip('()') for v in values]

        # Write to CSV
        with open(f"{output_dir}/{table_name}.csv", 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(columns)
            for value in values:
                row = [v.strip("'") for v in value.split(', ')]
                writer.writerow(row)

# Example usage
extract_data_from_sql(
    'C:\\Users\\bukep\\.Neo4jDesktop\\relate-data\\dbmss\\dbms-d2a38366-aa0f-4b9f-a327-400e586f4c2f\\import',  # Path to your .sql file
    'C:\\Users\bukep\\.Neo4jDesktop\\relate-data\\dbmss\\dbms-d2a38366-aa0f-4b9f-a327-400e586f4c2f'          # Directory to save CSV files
)