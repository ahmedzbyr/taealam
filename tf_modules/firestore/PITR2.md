# Firestore Native Mode: Point in Time Recovery (PITR)

Data is invaluable, and as any developer would testify, ensuring its security and availability in the event of unintended deletion or modification is paramount. Firestore, Google's NoSQL database service, has introduced PITR (Point in Time Recovery) in its native mode to address this very concern. In this blog, we will explore what PITR is and walk you through the process of recovering from data deletion.

### What is PITR in Firestore Native Mode?

Point in Time Recovery, abbreviated as PITR, is a feature that allows developers to recover data from a specific point in time. This is particularly useful in situations where data may be unintentionally deleted or modified. Firestore creates periodic backups of your data, which can be restored to regain lost information, ensuring continuity and peace of mind.

### Recovering from Data Deletion: A Step-by-Step Guide

To make this practical, let's walk through an example:

#### 1. **Creating a Firestore Native Mode Database Using Terraform**

```hcl
resource "google_firestore_database" "default" {
  project  = "your_project_id"
  location = "us-central"
}
```

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

Python script to add data:

```python
from google.cloud import firestore

# Initialize the client
db = firestore.Client()

# Create a reference to the collection
collection_ref = db.collection('sampleData')

# Add data
collection_ref.add({
    'name': 'John',
    'age': 28,
})
```

#### 3. **Deleting Data from the Collection using Python API**

Python script to delete data:

```python
# Using the previous code, get a reference to the document to be deleted
doc_ref = collection_ref.document('document_id_to_delete')

# Delete the document
doc_ref.delete()
```

#### 4. **Creating an Export of Data using SnapshotTime into a GCS Bucket**

To create an export, you'll need permissions to both Firestore and the GCS bucket.

Python script to export data:

```python
from google.cloud import firestore

# Initialize the client
db = firestore.Client()

# Specify the GCS bucket
bucket = "gs://your_bucket_name"

# Create an export
operation = db.export_documents_to_gcs(bucket, collection_ids=['sampleData'], output_uri_prefix="path/in/bucket")
```

#### 5. **Restoring Data from the GCS Bucket**

Python script to import data:

```python
# Using the previous code, now import the data
operation = db.import_documents_from_gcs(bucket, input_uri_prefix="path/in/bucket/where/export/is")
```

---

**Conclusion**

Data loss can be catastrophic, but with the right tools and knowledge at your disposal, recovery is not only possible but also straightforward. We hope this guide helps you navigate such challenges with ease. Always remember to test these procedures in a non-production environment before making any changes to production data!