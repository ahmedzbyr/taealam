import mysql.connector

# Connect to the MySQL database
mydb = mysql.connector.connect(
    host="database_ip_address",
    user="datastream",
    password="password_goes_here",
    database="datastream-src-database"
)

mycursor = mydb.cursor()

# Create a new table 'customers' if it doesn't exist
mycursor.execute(
    "CREATE TABLE IF NOT EXISTS customers (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), address VARCHAR(255))")

# SQL query for inserting data
sql = "INSERT INTO customers (name, address) VALUES (%s, %s)"

# Data to be inserted
vals = [
    ("John", "Highway 21"),
    ("Jane", "Lowstreet 4"),
    ("Mary", "Apple st 652"),
    ("Peter", "Mountain 21"),
    ("Sandy", "Ocean blvd 2")
]

# Insert multiple records into the 'customers' table
mycursor.executemany(sql, vals)

# Commit the transaction
mydb.commit()

# Print the number of records inserted
print(mycursor.rowcount, "records inserted.")
