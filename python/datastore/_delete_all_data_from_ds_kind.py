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