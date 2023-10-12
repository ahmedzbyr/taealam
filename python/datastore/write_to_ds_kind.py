from google.cloud import datastore
import random
import string

# Initialize the Datastore client
client = datastore.Client()

# Define the entity kind (similar to a table in a relational database)
kind = 'TestData'

# Generate 1 GB of test data
data_size_gb = 0.001  # Adjust as needed
data_size_bytes = data_size_gb * 1024 * 1024 * 1024  # 1 GB in bytes

# Create a random string generator
def generate_random_string(size):
    return ''.join(random.choice(string.ascii_letters) for _ in range(size))

# Define the batch size for writing entities to Datastore
batch_size = 500  # Adjust as needed

# Write data to Datastore
batch = []
total_bytes_written = 0

while total_bytes_written < data_size_bytes:
    # Create a new entity with random data
    entity = datastore.Entity(client.key(kind))
    random_data = generate_random_string(1024)  # 1 KB random string
    entity['data'] = random_data.encode('utf-8')

    batch.append(entity)
    total_bytes_written += len(entity['data'])

    if len(batch) >= batch_size:
        client.put_multi(batch)
        batch = []

# Write any remaining entities
if batch:
    client.put_multi(batch)

print(f"Total data written: {total_bytes_written / (1024 * 1024 * 1024):.3f} GB")