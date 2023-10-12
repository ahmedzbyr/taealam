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

print(f"Total data written: {total_bytes_written / (1024 * 1024 * 1024):.3f} GB")
