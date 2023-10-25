---
toc: true
toc_label: "Contents"
toc_icon: "cog"
title: Data Export from Datastore & Firestore
category: ["GCP"]
tags: ["export", "recovery", "python"]
header:
  {
    overlay_image: /assets/images/unsplash-image-67.jpg,
    og_image: /assets/images/unsplash-image-67.jpg,
    caption: "Photo credit: [**Unsplash**](https://unsplash.com)",
  }
---

# Data Export from Datastore & Firestore

In this blog post, we will venture into exporting data from Firestore and Datastore modes. Find the code on [Github](https://github.com/ahmedzbyr/taealam/tree/master/python/datastore/export). 


## `Datastore` Data Exports in GCP with Python

The Google Cloud Platform (GCP) is known for its robust database management solutions. Among its offerings is the Google Cloud Datastore, a highly scalable NoSQL database designed to seamlessly handle automatic sharding and load balancing. There could be instances where exporting your data from Datastore to Google Cloud Storage (GCS) becomes essential, either for deeper analysis or for **backup purposes**. In this piece, we'll walk you through a Python script crafted to automate this data transfer process leveraging GCP's **Datastore Admin Client**. There are other ways to export the data as well using the `googleapiclient`, but this time we will be looking into the **Datastore Admin Client**. This script is designed to be triggered either through Google *Cloud Scheduler* or directly from a *Cloud Function*, offering flexibility in how you initiate the data export. Join us as we delve into the code and unravel its workings.

Code Location : [ds_export_cf.py](https://github.com/ahmedzbyr/taealam/blob/master/python/datastore/export/ds_export_cf.py)

### Importing Necessary Libraries

```python
import base64
import json
import os
from google.cloud import datastore_admin_v1
```

At the outset, the script imports essential libraries. The `datastore_admin_v1` from `google.cloud` is crucial as it provides the necessary interface to interact with Datastore admin services.

### Initializing Datastore Client

```python
client = datastore_admin_v1.DatastoreAdminClient()
```

Here, an instance of `DatastoreAdminClient` is created to interact with the Datastore admin service.

### Defining The Round Time Function

This function is utilized to round the time to the nearest minute. It will be applied to the bucket path ensuring that the exported data is directed to a specified directory.

```python
def round_time(dt=None, date_delta=datetime.timedelta(minutes=1), to='down'):
    #...
```

`round_time` function rounds a given datetime object to a multiple of a specified timedelta, which is useful when defining a snapshot time for the export.

### Understanding Export/Import Service

The script Export/Import service facilitates copying a subset or all entities to/from GCS. This data can then be imported into Datastore in any GCP project or loaded into Google BigQuery for analysis. These operations are performed asynchronously, with the ability to track their progress and errors through an Operation resource.

### Defining Expected JSON Payload

```python
#
# Define a JSON payload expected from Cloud Scheduler or Cloud Function
#
json_data = {
    "project_id": "elevated-column-400011",
    "export_bucket": "gs://ds-export-bucket/",
    "kinds": ["abc", "xyz", "axz"],
    "namespace_ids": ["my_nm"]
}
```

A sample JSON payload is outlined which is expected to be received from Cloud Scheduler or Cloud Function, containing necessary information such as project_id, export_bucket, kinds, and namespace_ids.

### The Main Export Function

```python
def datastore_export(event, context):
    #...
```

`datastore_export` is the primary function that handles the export process. It checks for a 'data' field in the event argument to decode the JSON payload accordingly. The request could be from cloud function which is `b64encode`d. Else we take the information directly from the Cloud function as it is.
 
```python
    # Check if the event contains 'data' field which is expected when triggered via Cloud Scheduler.
    # If so, decode the inner data field of the JSON payload.
    if "data" in event:
        json_data = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
    else:
        # If not, (e.g., if triggered via Cloud Console on a Cloud Function), the event itself is the data.
        json_data = json.loads(event)
```

### Setting Up Entity Filter

#### Entity Filter

`EntityFilter` is a configuration object that identifies a specific subset of entities in a project. This selection can be made based on combinations of kinds and namespaces. Below are some usage examples to illustrate how `EntityFilter` can be used:

- **Entire Project:**

  ```plaintext
  kinds=[], namespace_ids=[]
  ```

- **Specific Kinds in All Namespaces:**

  ```plaintext
  kinds=['Foo', 'Bar'], namespace_ids=[]
  ```

- **Specific Kinds in Default Namespace Only:**

  ```plaintext
  kinds=['Foo', 'Bar'], namespace_ids=['']
  ```

- **Specific Kinds in Both Default and Specified Namespaces:**

  ```plaintext
  kinds=['Foo', 'Bar'], namespace_ids=['', 'Baz']
  ```

- **All Kinds in a Specified Namespace:**

  ```plaintext
  kinds=[], namespace_ids=['Baz']
  ```

| Fields            | Type   | Description                                                                                                                                                                                                                                                                                             |
| ----------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `kinds[]`         | string | If empty, this represents all kinds.                                                                                                                                                                                                                                                                    |
| `namespace_ids[]` | string | An empty list represents all namespaces which is the preferred usage for projects that don't use namespaces. An empty string element represents the default namespace, advisable for projects with data in non-default namespaces but wish to exclude them. Each namespace in this list must be unique. |

```python
entity_filter = datastore_admin_v1.EntityFilter()
#...
```

An `EntityFilter` object is set up to specify which kinds and/or namespaces should be exported based on the provided documentation URL.

### Preparing the Export Request

```python
request = datastore_admin_v1.ExportEntitiesRequest(
    #...
)
```

An `ExportEntitiesRequest` object is created, populating the required fields with data from the JSON payload. This includes the project_id, output_url_prefix for GCS location, and the previously created entity_filter.

### Initiating the Export Request

| Fields            | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ----------------- | ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project_id        | string              | Required. Project ID against which to make the request.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| labels            | map<string, string> | Client-assigned labels.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| entity_filter     | EntityFilter        | Description of what data from the project is included in the export.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| output_url_prefix | string              | Required. Location for the export metadata and data files. The full resource URL of the external storage location. Currently, only Google Cloud Storage is supported. So `output_url_prefix` should be of the form: `gs://BUCKET_NAME[/NAMESPACE_PATH]`, where `BUCKET_NAME` is the name of the Cloud Storage bucket and `NAMESPACE_PATH` is an optional Cloud Storage namespace path (this is not a Cloud Datastore namespace). For more information about Cloud Storage namespace paths, see [Object name considerations](https://cloud.google.com/storage/docs/naming). The resulting files will be nested deeper than the specified URL prefix. The final output URL will be provided in the `google.datastore.admin.v1.ExportEntitiesResponse.output_url` field. That value should be used for subsequent `ImportEntities` operations. By nesting the data files deeper, the same Cloud Storage bucket can be used in multiple `ExportEntities` operations without conflict. |

```python
operation = client.export_entities(request=request)
```

The script then calls `client.export_entities` with the `request` object to initiate the export process.

### Monitoring the Operation

```python
print("Waiting for operation to complete...")
response = operation.result()
print(response)
```

The script waits for the operation to complete by calling `operation.result()`. Once completed, it prints the JSON representation of the response to the console.

## `Firestore` Data Exports in GCP with Python

We will now delve into a Python script designed to automate the export of data from Google Cloud Firestore to Google Cloud Storage. This script can be triggered by Google Cloud Scheduler or directly from a Cloud Function. Let's break down the code to understand its workings and how to potentially modify it for your use case.

Code Location : [fs_export_cf.py](https://github.com/ahmedzbyr/taealam/blob/master/python/datastore/export/fs_export_cf.py)


### Importing Necessary Libraries

```python
import base64
import json
import os
import datetime
from google.cloud import firestore_admin_v1
```

Here, we import the necessary libraries including `firestore_admin_v1` from `google.cloud`, which provides the interface to interact with Firestore Admin services.

### Defining Expected JSON Payload

```python
#
# Define a JSON payload expected from Cloud Scheduler or Cloud Function
#
json_data = {
    "project_id": "elevated-column-400011",
    "db_id": "db_id",
    "export_bucket": "gs://fs-export-bucket/",
    "collection_ids": ["abc", "xyz", "axz"],
    "namespace_ids": ["my_nm"]
}
```

### Setting Up Firestore Client

```python
client = firestore_admin_v1.FirestoreAdminClient()
```

We create an instance of `FirestoreAdminClient` to interact with Firestore.

### Defining The Round Time Function

This function is employed to round off the time to the nearest minute, enabling us to export data utilizing the `snapshot_time` parameter in the API. As of the time this blog was written, this feature is yet to be supported in the `FirestoreAdminClient`, although it's slated for inclusion in future releases. Additionally, this rounding function will be harnessed in crafting the bucket path, thereby creating backups in distinct timed directories, ensuring an organized data retrieval system.

```python
def round_time(dt=None, date_delta=datetime.timedelta(minutes=1), to='down'):
    #...
```

`round_time` function rounds a given datetime object to a multiple of a specified timedelta, which is useful when defining a snapshot time for the export.

### Defining The Main Export Function

```python
def firestore_export(event, context):
    #...
```

`firestore_export` is the core function that handles the export process. It takes in two arguments: `event` and `context`, where `event` contains the JSON payload with export details.

### Parsing The Event Data

We could get the data from cloud schedular to CF so we are handling this differently here.

```python
if "data" in event:
    json_data = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
else:
    json_data = json.loads(event)
```

Depending on the source of the trigger, it decodes the JSON payload from the `event` argument.

### Creating The Export Request

| Fields            | Type   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name              | string | Required. Database to export. Should be of the form: projects/{project_id}/databases/{database_id}.                                                                                                                                                                                                                                                                                                                                                                                                |
| collection_ids[]  | string | Which collection ids to export. Unspecified means all collections.                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| output_uri_prefix | string | The output URI. Currently only supports Google Cloud Storage URIs of the form: gs://BUCKET_NAME[/NAMESPACE_PATH], where BUCKET_NAME is the name of the Google Cloud Storage bucket and NAMESPACE_PATH is an optional Google Cloud Storage namespace path. When choosing a name, be sure to consider [Google Cloud Storage naming guidelines](https://cloud.google.com/storage/docs/naming). If the URI is a bucket (without a namespace path), a prefix will be generated based on the start time. |
| namespace_ids[]   | string | An empty list represents all namespaces. This is the preferred usage for databases that don't use namespaces. An empty string element represents the default                                                                                                                                                                                                                                                                                                                                       |

```python
request = firestore_admin_v1.ExportDocumentsRequest(
    #...
)
```

Here, an instance of `ExportDocumentsRequest` is created with necessary parameters extracted from the `json_data`. This includes project ID, database ID, export bucket URL, and optional fields like collection IDs.

### Initiating The Export Request

```python
operation = client.export_documents(request=request)
```

`client.export_documents` method is called with the `request` object to initiate the export process.

##  Testing Export Python Code

```shell
┌─(.venv)[ahmedzbyr][Zubairs-MacBook-Pro][±][master U:2 ✗][~/projects/taealam/python/datastore]
└─▪ nose2 export
{ "export_bucket": "gs://my-bucket/" , "db_id": "db_id", "project_id" : "my_project" }
Waiting for operation to complete...
<Mock name='mock.export_documents().result()' id='4528211664'>
{'request': name: "projects/my_project/databases/db_id"
output_uri_prefix: "gs://my-bucket/2023-10-25T12:42:00Z"
}
.Waiting for operation to complete...
<Mock name='mock.export_entities().result()' id='4528592144'>
.Waiting for operation to complete...
<Mock name='mock.export_entities().result()' id='4528728976'>
.
----------------------------------------------------------------------
Ran 3 tests in 0.005s

OK
```
