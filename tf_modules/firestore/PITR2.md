#  Firestore Native Mode: Point in Time Recovery (PITR)

Data is invaluable, and as any developer would testify, ensuring its security and availability in the event of unintended deletion or modification is paramount. Firestore, Google's NoSQL database service, has introduced PITR (Point in Time Recovery) in its native mode to address this very concern. In this blog, we will explore what PITR is and walk you through the process of recovering from data deletion.

## What is PITR in Firestore Native Mode?

Point in Time Recovery, abbreviated as PITR, is a feature that allows developers to recover data from a specific point in time. This is particularly useful in situations where data may be unintentionally deleted or modified. Firestore creates periodic backups of your data, which can be restored to regain lost information, ensuring continuity and peace of mind.

## Firestore Point-in-Time Recovery (PITR)

**Introduction**

Firestore's Point-in-Time Recovery (PITR) feature offers a safety net for your data, protecting it against accidental deletions or erroneous writes. With PITR, you can maintain consistent versions of your documents from past timestamps, allowing you to recover your data to a specific point in time, seamlessly. In this article, we'll explore the benefits of PITR and how to harness its capabilities effectively.

**The Power of Point-in-Time Recovery**

PITR is your guardian against data disasters. It helps you safeguard your data from accidental mishaps such as data deletions or incorrect writes. The key advantage of PITR is that it allows you to recover your data to any point in time within the last 7 days. This means that even if a developer inadvertently pushes incorrect data or deletes essential information, you can turn back the clock and restore your data to a previous state.

It's essential to highlight that for any live database that adheres to Firestore's [Best Practices](https://cloud.google.com/firestore/docs/best-practices), using PITR doesn't impact the performance of read or write operations. It operates seamlessly in the background, ensuring data integrity without causing any slowdowns.

**Understanding the PITR Window**

After enabling PITR, Firestore starts retaining your data within what's known as the "PITR window." This window extends over a 7-day period. The PITR window timeline depends on the enablement status, as follows:

- When PITR is disabled, you can read data starting from one hour before the time of your read request.
- If PITR is enabled within the last 7 days, you can read data from one hour before the moment PITR was enabled.
- In case PITR was enabled more than 7 days ago, you can read data dating back to 7 days before the time of your read request.

Please note that you can't immediately start reading data from 7 days in the past right after enabling PITR. There's an initial one-hour buffer.

In the PITR window, Firestore retains a single version per minute. This means you can read documents at minute granularity using timestamps. In situations where multiple writes occurred for a document, only one version is retained. For example, if a document had multiple writes (v1, v2, ... vk) between timestamps like `2023-05-30 09:00:00 AM` (exclusive) and `2023-05-30 09:01:00 AM` (inclusive), a read request at `2023-05-30 09:01:00 AM` will return the `vk` version of the document.

It's important to note that the 7-day retention period mainly applies to stale read operations. For consistent import or export operations, Firestore supports data up to one hour ago.

**Recovering Data with PITR**

Firestore offers two ways to recover data using PITR:

1. **Recover a Portion of the Database**: This method involves performing a "stale read," where you specify a query condition or use a direct key lookup along with a timestamp from the past. You can then write the results back into the live database. This approach is typically used for precise, surgical operations on your live database. For instance, if you accidentally delete a specific document or make an incorrect update to a subset of data, this method allows you to recover it. For detailed instructions, refer to the [guide on recovering a portion of your database](https://cloud.google.com/firestore/docs/use-pitr#read-pitr).

2. **Recover the Entire Database**: To recover the entire database, you can export it by specifying a timestamp from the past and then import it into a new database. However, it's worth noting that exporting a database can be a time-consuming process, potentially taking several hours. It's essential to be aware that you can only export consistent PITR data where the timestamp is a whole minute timestamp within the past hour but not earlier than the earliestVersionTime. For details on this process, please refer to the guide on [exporting and importing from a consistent PITR version](https://cloud.google.com/firestore/docs/use-pitr#export_and_import_from_a_consistent_pitr_version).


## Recovering from Data Deletion: A Step-by-Step Guide (Entire Database)

To make this practical, let's walk through an example:

### 1. **Creating a Firestore Native Mode Database Using Terraform**

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

### 2. **Creating Sample Data using Python API**

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

### 3. **Deleting Data from the Collection using Python API**

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

### 5. **Restoring Data from the GCS Bucket**

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
