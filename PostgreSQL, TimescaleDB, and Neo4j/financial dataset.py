import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load the financial dataset from relational-data.org
df = pd.read_csv(' https://relational-data.org/dataset/Financial/financial.csv')

# Data Exploration
print("Dataset Shape:", df.shape)
print("Dataset Columns:", df.columns)
print("Dataset Info:", df.info())
print("Dataset Describe:", df.describe())

# Data Visualization
plt.figure(figsize=(10, 6))
df['Transaction_Amount'].hist(bins=50)
plt.title('Transaction Amount Distribution')
plt.xlabel('Transaction Amount')
plt.ylabel('Frequency')
plt.show()

plt.figure(figsize=(10, 6))
df['Customer_Age'].hist(bins=50)
plt.title('Customer Age Distribution')
plt.xlabel('Customer Age')
plt.ylabel('Frequency')
plt.show()

# Data Analysis
# Calculate average transaction amount by region
avg_transaction_amount_by_region = df.groupby('Region')['Transaction_Amount'].mean()
print("Average Transaction Amount by Region:")
print(avg_transaction_amount_by_region)

# Calculate top 10 customers by total transaction amount
top_customers_by_transaction_amount = df.groupby('Customer_ID')['Transaction_Amount'].sum().sort_values(ascending=False).head(10)
print("Top 10 Customers by Total Transaction Amount:")
print(top_customers_by_transaction_amount)

# Calculate top 10 financial instruments by total transaction amount
top_financial_instruments_by_transaction_amount = df.groupby('Financial_Instrument')['Transaction_Amount'].sum().sort_values(ascending=False).head(10)
print("Top 10 Financial Instruments by Total Transaction Amount:")
print(top_financial_instruments_by_transaction_amount)