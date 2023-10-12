## Create data for Datastore

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

## Delete Data in a `kind`

To delete all contents of a kind in Google Cloud Datastore using Python, you can use the `google-cloud-datastore` library. Here's a sample Python code to delete all entities of a specific kind:

```python
from google.cloud import datastore

# Initialize the Datastore client
client = datastore.Client()

# Define the kind you want to delete
kind_to_delete = 'YourKindName'  # Replace with your kind name

# Query for all entities of the specified kind
query = client.query(kind=kind_to_delete)
entities = list(query.fetch())

# Delete all entities in batches
batch_size = 500  # Adjust the batch size as needed

while entities:
    batch = entities[:batch_size]
    client.delete_multi([entity.key for entity in batch])
    entities = entities[batch_size:]

print(f"All entities of kind '{kind_to_delete}' have been deleted.")
```

Make sure to replace `'YourKindName'` with the actual kind name that you want to delete. The code fetches all entities of that kind in batches and deletes them. You can adjust the `batch_size` to control how many entities are deleted at once to avoid exceeding any rate limits.

Please exercise caution when running this code in a production environment, as it permanently deletes all entities of the specified kind. Ensure that you have appropriate backups or safeguards in place before running such code in a production Datastore.

## Create data for Firestore Native

To write test data to Google Cloud Firestore (Native) with a dataset of approximately 1 GB in size, you can use Python and the `google-cloud-firestore` library. First, make sure you have the library installed. You can install it using pip:

```bash
pip install google-cloud-firestore
```

Here's a sample Python code to generate and write test data to Firestore Native:

```python
from google.cloud import firestore
import random
import string

# Initialize the Firestore client
db = firestore.Client()

# Define the collection where you want to store the data
collection_name = 'TestData'

# Generate 1 GB of test data
data_size_gb = 0.001  # Adjust as needed
data_size_bytes = data_size_gb * 1024 * 1024 * 1024  # 1 GB in bytes

# Create a random string generator
def generate_random_string(size):
    return ''.join(random.choice(string.ascii_letters) for _ in range(size))

total_bytes_written = 0

while total_bytes_written < data_size_bytes:
    # Create a new document with random data
    random_data = generate_random_string(1024)  # 1 KB random string
    data = {
        'data': random_data,
    }
    total_bytes_written += len(random_data.encode('utf-8'))
    print("Written: " + str(total_bytes_written) + " Bytes in total.")
    
    update_time, batch_ref = db.collection(collection_name).add(data)
    print(f"Added document with ID: {batch_ref.id}")

print(f"Total data written: {total_bytes_written / (1024 * 1024 * 1024):.2f} GB")

```

This code will generate random data and write it to Firestore in batches until it reaches the specified data size. Please note that writing 1 GB of data to Firestore can take a significant amount of time and may incur costs, so use it for testing and development purposes only. Also, consider cleaning up the data when you're done, as demonstrated in the cleanup section at the end of the code.

## Delete data from Firestore Native Collection

To delete all documents within a collection, you can use the following Python code:

```python
from google.cloud import firestore

# Initialize the Firestore client
db = firestore.Client()

# Define the collection name you want to delete
collection_name = 'YourCollectionName'  # Replace with your collection name

# Query and delete all documents in the collection
collection_ref = db.collection(collection_name)
docs = collection_ref.stream()

for doc in docs:
    doc.reference.delete()

print(f"All documents in collection '{collection_name}' have been deleted.")
```

Make sure to replace `'YourCollectionName'` with the actual collection name you want to delete. This code retrieves all documents within the specified collection and deletes them one by one. Be careful when running this code in a production environment, as it permanently deletes all documents in the collection. Ensure you have appropriate backups or safeguards in place before executing this code in a production Firestore database.
