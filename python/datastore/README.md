To write test data to Google Cloud Datastore with data that is about 1 GB large, you can use Python and the Google Cloud Datastore client library. First, make sure you have the `google-cloud-datastore` library installed. You can install it using pip:

```bash
pip install google-cloud-datastore
```

Next, you can use the following sample Python code to write test data to Google Cloud Datastore. In this example, we will generate 1 GB of test data with random values and write it to Datastore:

```python
from google.cloud import datastore
import random
import string

# Initialize the Datastore client
client = datastore.Client()

# Define the entity kind (similar to a table in a relational database)
kind = 'TestData'

# Generate 1 GB of test data
data_size_gb = 1  # Adjust as needed
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

print(f"Total data written: {total_bytes_written / (1024 * 1024 * 1024):.2f} GB")

# Cleanup
for entity in batch:
    client.delete(entity.key)
```

Make sure to replace `'TestData'` with your actual Datastore entity kind, and adjust the batch size and data size according to your needs.

This code will generate random data and write it to Datastore in batches until it reaches the specified data size. It also performs a cleanup at the end to delete the test data entities. Please note that writing 1 GB of data to Datastore can take a significant amount of time and may incur costs, so use it for testing and development purposes only.