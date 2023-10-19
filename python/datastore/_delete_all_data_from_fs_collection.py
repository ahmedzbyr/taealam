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