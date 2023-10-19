# Firestore Native Mode: Point in Time Recovery (PITR)

Data is invaluable, and as any developer would testify, ensuring its security and availability in the event of unintended deletion or modification is paramount. Firestore, Google's NoSQL database service, has introduced PITR (Point in Time Recovery) in its native mode to address this very concern. In this blog, we will explore what PITR is and walk you through the process of recovering from data deletion.

### What is PITR in Firestore Native Mode?

Point in Time Recovery, abbreviated as PITR, is a feature that allows developers to recover data from a specific point in time. This is particularly useful in situations where data may be unintentionally deleted or modified. Firestore creates periodic backups of your data, which can be restored to regain lost information, ensuring continuity and peace of mind.

### Recovering from Data Deletion: A Step-by-Step Guide

To make this practical, let's walk through an example:

#### 1. **Creating a Firestore Native Mode Database Using Terraform**


```hcl
resource "google_firestore_database" "default" {
  name        = "myfirestoredb"  # ID to use for the database, choose accordingly
  location_id = "us-central1"  # Choose your desired location
  type        = "FIRESTORE_NATIVE"  # or use "DATASTORE_MODE"

  concurrency_mode            = "OPTIMISTIC"  # Can also use "PESSIMISTIC" or "OPTIMISTIC_WITH_ENTITY_GROUPS"
  app_engine_integration_mode = "DISABLED"  # or use "ENABLED"

  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"  # or use "POINT_IN_TIME_RECOVERY_DISABLED" 
  delete_protection_state           = "DELETE_PROTECTION_DISABLED"  # or use "DELETE_PROTECTION_ENABLED"

  project  = "your_project_id"  # This is optional. If not provided, the default provider project is used.
}
```

Make sure you choose and adjust values that best fit your specific requirements. For instance, choose the appropriate `location_id` based on where you want the Firestore database to be located, and adjust other parameters based on your desired configuration.

Apply the terraform code using:

```bash
terraform init
terraform apply
```

#### 2. **Creating Sample Data using Python API**

Before we create data, ensure you have the required Python packages:

```bash
pip install google-cloud-firestore
```

We will add at least 10MB of data, you would typically add a significant amount of records to Firestore, or have records with substantial data fields. One straightforward way is to generate a large string field in each record. For simplicity, let's use a repeated string pattern to generate a big field.

```python
from google.cloud import firestore

# Initialize the client
db = firestore.Client()

# Create a reference to the collection
collection_ref = db.collection('sampleData')

# Create a large string (around 1MB)
large_string = "A" * (0.1 * 1024 * 1024)  # Each character is 1 byte, so this string is approximately 1MB

# Add 10 records, each with approximately 1MB of data
for i in range(100):
    collection_ref.add({
        'name': 'John' + str(i),
        'age': 28 + i,
        'large_data': large_string
    })
```

With this code, you're adding 100 records to Firestore. Each record has a `large_data` field that contains approximately 0.1MB of data, resulting in an addition of roughly 10MB of data in total. Adjust as needed for your requirements.

| :warning: NOTE: Keep a note of the time when the data was inserted, we will use this to export the data once it is deleted in the next step. |
| :------------------------------------------------------------------------------------------------------------------------------------------- |

#### 3. **Deleting Data from the Collection using Python API**

Python script to delete data:

```python
from google.cloud import firestore

# Initialize the client
db = firestore.Client()

# Create a reference to the collection
collection_ref = db.collection('sampleData')

# Loop through the 10 records and delete them
for i in range(100):
    doc_name = 'John' + str(i)  # Constructing the name as per the earlier code
    doc_ref = collection_ref.document(doc_name)
    doc_ref.delete()

```

#### 4. **Creating an Export of Data using SnapshotTime into a GCS Bucket**

To create an export, you'll need permissions to both Firestore and the GCS bucket. This should get the data from the `snapshotTime` provided. 

Python script to export data:

```python
from google.cloud import firestore
from datetime import datetime, timezone

# Initialize the client
db = firestore.Client()

# Specify the GCS bucket
bucket = "gs://your_bucket_name"

# Specify the snapshot time, e.g., current time. You can adjust this as needed.
snapshot_time = datetime.now(timezone.utc)

# Create an export with snapshotTime
operation = db.export_documents_to_gcs(
    bucket, 
    collection_ids=['sampleData'], 
    output_uri_prefix="path/in/bucket",
    snapshotTime=snapshot_time
)
```

| :books: NOTE: Update the `datetime.now(timezone.utc)` to the time when the data was inserted approx to nearest minute. |
| :--------------------------------------------------------------------------------------------------------------------- |


#### 5. **Restoring Data from the GCS Bucket**

To use the `gcloud` command-line tool for importing data from Google Cloud Storage (GCS) to Firestore, you can utilize the `firestore import` command.

```bash
gcloud firestore import gs://your_bucket_name/path/in/bucket/where/export/is --async
```

- `gs://your_bucket_name/path/in/bucket/where/export/is` is the path to the exported data in GCS. This should match the `input_uri_prefix` you provided in the Python code.
  
- `--async` is optional. It's used if you want the command to return immediately without waiting for the operation to complete. If you remove it, the command will wait until the import process is done before returning control to the shell.

Make sure to replace the placeholder values with your actual bucket and path information. Also, ensure that `gcloud` is authenticated and configured with the appropriate project.

---

**Conclusion**

Data loss can be catastrophic, but with the right tools and knowledge at your disposal, recovery is not only possible but also straightforward. We hope this guide helps you navigate such challenges with ease. Always remember to test these procedures in a non-production environment before making any changes to production data!