# Unleash the Power of Google Cloud with the Cloud Asset Inventory Python API

Managing resources in your Google Cloud Platform (GCP) projects is a complex task, especially when dealing with multiple projects. Fortunately, Google offers a robust solution in the form of the Cloud Asset Inventory API, which allows you to access a wealth of data about your cloud resources. In this blog post, we'll explore how you can harness the capabilities of this API to gain insights into your projects, enhance security, and even automate critical tasks.

##  Understanding the Cloud Asset Inventory

###  What is the Cloud Asset Inventory?

The Cloud Asset Inventory (CAI) is a powerful service that provides a comprehensive view of all the resources within your GCP projects. It's like having a complete inventory of your cloud assets at your fingertips. Notably, it can also be used to pull data from multiple projects, making it a versatile tool for managing complex GCP environments.

###  Why is it Important?

The CAI plays a crucial role in project management, resource tracking, and security. Here are some key benefits:

**1. Visibility into New Resources**
One of the main advantages of the CAI is its ability to track new resources as they are created within your projects. This feature is invaluable for staying up-to-date with project changes.

**2. Project Utilization Analysis**
The data retrieved from the CAI can be used for in-depth analysis of your project's utilization. This information is vital for optimizing resource allocation and controlling costs.

**3. Enhanced Security**
Security is paramount in the cloud. By monitoring the CAI data, you can identify potential security vulnerabilities, such as misconfigured resources or unauthorized access. For example, you can quickly determine if backups are enabled on a critical Cloud SQL resource in a production project.

##  Getting Started with the Cloud Asset Inventory Python API

### Basic Data Retrieval

Let's dive into the basics of using the Cloud Asset Inventory Python API to retrieve data. In this blog post, we'll cover the foundational steps, and in subsequent posts, we'll explore advanced techniques like multi-threading for pulling data from multiple projects simultaneously.

### IAM Requirements for CAI Python Script

Before you can start using the CAI Python script, you need to set up the necessary Identity and Access Management (IAM) permissions. This ensures that your script can access the required resources. Here's how to get started:

We need to do below steps before we can run the script.

####  Step 1: Grant IAM Roles
Ensure that you have the following IAM roles on your project:

To get the permissions that you need to Create VMs that use service accounts, grant yourself IAM roles on your project.

- Compute Instance Admin (v1) (`roles/compute.instanceAdmin.v1`)
- Create Service Accounts (`roles/iam.serviceAccountCreator`)

####  Step 2: Create a Service Account

Create a service account that your script will use:

```sh
gcloud iam service-accounts create sa-cai-export-inventory --description="SA for Cloud Asset Inventory export"  --display-name="SA CAI Export"
```

####  Step 3: Enable the Cloud Asset Inventory API

- Enable the Cloud Asset Inventory API in the Google Cloud Console.
- Once enabled, you can assign the necessary permissions to the service account created in Step 2.

#### Step 4: Assign Permissions

Assign the `roles/cloudasset.viewer` permission to the service account with the following commands:

```sh
gcloud projects add-iam-policy-binding PROJECT_ID --member="serviceAccount:sa-cai-export-inventory@PROJECT_ID.iam.gserviceaccount.com" --role="roles/cloudasset.viewer"
```

Optional

```sh
gcloud iam service-accounts add-iam-policy-binding sa-cai-export-inventory@PROJECT_ID.iam.gserviceaccount.com --member="user:USER_EMAIL" --role="roles/iam.serviceAccountUser"
```

####  Step 5: Create a GCE Instance with the Service Account

To create a Google Compute Engine (GCE) instance that uses the service account, run the following command:

```sh
gcloud compute instances create cai-vm-node --service-account=sa-cai-export-inventory@PROJECT_ID.iam.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform
```

For a more streamlined approach, consider using Terraform to create instances.

```hcl
resource "google_compute_instance" "default" {
  name         = "cai-vm-node"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"
  }

  service_account {
    # Google recommends custom service accounts with `cloud-platform` scope with
    # specific permissions granted via IAM Roles.
    # This approach lets you avoid embedding secret keys or user credentials
    # in your instance, image, or app code
    email  = "sa-cai-export-inventory@PROJECT_ID.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
```

### Run the script on the GCE instance

Once the instance is created then we can logon to the node using below command.

```sh
gcloud compute ssh cai-vm-node --zone="us-central1-a" --project PROJECT_ID --internal-ip
```

Once you have login to the node then we can create a python venv and run the scripts.
This will then use the service account which has the permission to get all the data from the project.

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirement.txt

# Update the bucket / bigquery information in the script
python cai_gcs_bucket.py
```

##  Exploring the API

The core function used for data retrieval is `export_assets`. This method fetches information about resources within your projects. You can find more details in the [official documentation](https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.services.asset_service.AssetServiceClient#google_cloud_asset_v1_services_asset_service_AssetServiceClient_export_assets).

### Output Configuration

The API expects an `OutputConfig` that specifies where the results should be stored, either in a Google Cloud Storage (GCS) bucket or a BigQuery table. The `OutputConfig` has options for both GCS and BigQuery destinations.

| Name                   | Description                                                                                                                                                                                                                                                                                                                    |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `gcs_destination`      | [`google.cloud.asset_v1.types.GcsDestination`](https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.GcsDestination) Destination on Cloud Storage. This field is a member of `oneof`\_ `destination`.                                                                                   |
| `bigquery_destination` | [`google.cloud.asset_v1.types.BigQueryDestination`](https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.BigQueryDestination) Destination on BigQuery. The output table stores the fields in asset Protobuf as columns in BigQuery. This field is a member of `oneof`\_ `destination`. |

- **`gcs_destination`** takes 2 parameters.

  - `uri`
  - `uri_prefix`

- **`bigquery_destination`**
  - `dataset`
  - `table`
  - `partition_spec` - `partition_key` - `google.cloud.asset_v1.types.PartitionSpec.PartitionKey` The partition key for BigQuery partitioned table.
  - `force` - overwrite existing table.
  - `separate_tables_per_asset_type`.

### `export_assets` API takes below information for it to process the request

| Name       | Description                                                                                                                                                                                                     |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `request`  | [`google.cloud.asset_v1.types.ExportAssetsRequest`](https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.ExportAssetsRequest) The request object. Export asset request. |
| `retry`    | `google. api_core.retry.Retry` Designation of what errors, if any, should be retried.                                                                                                                           |
| `timeout`  | `float` The timeout for this request.                                                                                                                                                                           |
| `metadata` | `Sequence[Tuple[str, str]]` Strings which should be sent along with the request as metadata.                                                                                                                    |

###  `request` take `ExportAssetsRequest` Object

| Name                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `parent`             | `str` **Required**. The relative name of the root asset. This can only be an organization number (such as "organizations/123"), a project ID (such as "projects/my-project-id"), or a project number (such as "projects/12345"), or a folder number (such as "folders/123").                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `read_time`          | `google.protobuf.timestamp_pb2.Timestamp` Timestamp to take an asset **snapshot**. This can only be set to a timestamp between the current time and the current time minus 35 days (inclusive). If not specified, the current time will be used. Due to delays in resource data collection and indexing, there is a volatile window during which running the same query may get different results.                                                                                                                                                                                                                                                                                                                                                        |
| `asset_types`        | `MutableSequence[str]` A list of asset types to take a snapshot for. For example: "compute.googleapis.com/Disk". Regular expressions are also supported. For example: - "compute.googleapis.com.*" snapshots resources whose asset type starts with "compute.googleapis.com". - ".*Instance" snapshots resources whose asset type ends with "Instance". - "._Instance._" snapshots resources whose asset type contains "Instance". See `RE2`\_\_ for all supported regular expression syntax. If the regular expression does not match any supported asset type, an INVALID_ARGUMENT error will be returned. If specified, only matching assets will be returned, otherwise, it will snapshot all asset types. See `Introduction to Cloud Asset Inventory |
| `content_type`       | [`google.cloud.asset_v1.types.ContentType`](https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.ContentType) Asset content type. If not specified, no content but the asset name will be returned.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `output_config`      | [`google.cloud.asset_v1.types.OutputConfig`](https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.OutputConfig) Required. Output configuration indicating where the results will be output to.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `relationship_types` | `MutableSequence[str]` A list of relationship types to export, for example: `INSTANCE_TO_INSTANCEGROUP`. This field should only be specified if content_type=RELATIONSHIP. - If specified: it snapshots specified relationships. It returns an error if any of the [relationship_types] doesn't belong to the supported relationship types of the [asset_types] or if any of the [asset_types] doesn't belong to the source types of the [relationship_types]. - Otherwise: it snapshots the supported relationships for all [asset_types] or returns an error if any of the [asset_types] has no relationship support. An unspecified asset types field means all supported asset_types. See `Introduction to Cloud Asset Inventory                      |

- `operation = client.export_assets(request=request)` will return the Operations `google.api_core.operation.Operation` object.
- This can be used to check for the progress of the operation.

##  Python sample script

To help you get started, we've provided two Python sample scripts for exporting data to Google Cloud Storage (GCS) and BigQuery. You can use these as templates for your own data retrieval tasks.

###  Exporting to a GCS Bucket

```python
from google.cloud import asset_v1

def export_to_gcs_bucket():
    # Create a client
    client = asset_v1.AssetServiceClient()

    # Creating a outputConfiguration based on
    # https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.OutputConfig
    output_config = asset_v1.OutputConfig()
    output_config.gcs_destination.uri = "gs://my-bucket-information-11826735"

    request = asset_v1.ExportAssetsRequest(
        parent="my-project-name",


        # Asset content type.
        # Values:
        #   CONTENT_TYPE_UNSPECIFIED (0): Unspecified content type.
        #   RESOURCE (1): Resource metadata.
        #   IAM_POLICY (2): The actual IAM policy set on a resource.
        #   ORG_POLICY (4): The organization policy set on an asset.
        #   ACCESS_POLICY (5): The Access Context Manager policy set on an asset.
        #   OS_INVENTORY (6): The runtime OS Inventory information.
        #   RELATIONSHIP (7): The related resources.
        #
        content_type="RESOURCE",
        output_config=output_config
    )

    operation = client.export_assets(request=request)
    return operation.result()


if __name__ == '__main__':
    export_to_gcs_bucket
```

##  Exporting to a Bigquery Table

```python
from google.cloud import asset_v1

def export_to_bq_table():
    # Create a client
    client = asset_v1.AssetServiceClient()

    # Creating a outputConfiguration based on
    # https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.OutputConfig
    output_config = asset_v1.types.OutputConfig()
    output_config.bigquery_destination.dataset = "my-dataset-information"
    output_config.bigquery_destination.table = "my-table-information"

    request = asset_v1.ExportAssetsRequest(
        parent="my-project-name",


        # Asset content type.
        # Values:
        #   CONTENT_TYPE_UNSPECIFIED (0): Unspecified content type.
        #   RESOURCE (1): Resource metadata.
        #   IAM_POLICY (2): The actual IAM policy set on a resource.
        #   ORG_POLICY (4): The organization policy set on an asset.
        #   ACCESS_POLICY (5): The Access Context Manager policy set on an asset.
        #   OS_INVENTORY (6): The runtime OS Inventory information.
        #   RELATIONSHIP (7): The related resources.
        #
        content_type="RESOURCE",
        output_config=output_config
    )

    operation = client.export_assets(request=request)
    return operation.result()


if __name__ == '__main__':
    export_to_bq_table
```
