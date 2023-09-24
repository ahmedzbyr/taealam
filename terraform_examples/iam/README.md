# Design IAM on Google Cloud Platform

Security is paramount when setting up resources in the cloud or on-premises. It encompasses various layers of protection, including network security, encryption, access control, and more. In the realm of cybersecurity, there are seven critical layers of security:

1. **Critical Assets**
2. **Data Security**
3. **Application Security**
4. **Endpoint Security**
5. **Network**
6. **Perimeter**
7. **Human**

In this post, we will delve into one of these security layers, namely **Application Security**, focusing on Google Cloud Platform (GCP). Specifically, we will explore Identity & Access Management (IAM) in GCP, a fundamental aspect of application security. IAM plays a pivotal role in ensuring that the right users or entities have the appropriate level of access, adhering to the principle of least privilege.

## What is IAM?

**Identity and Access Management (IAM)** in Google Cloud allows administrators to control and authorize actions on specific resources, providing comprehensive control and visibility over GCP resources. IAM offers tools to manage resource permissions with minimal complexity, using both Terraform resources and APIs. It enables granular, context-aware access control and simplifies compliance with built-in audit trails.

## The Components of IAM

In IAM, three primary components work together:

1. **Principal**: These are entities like users, groups, or service accounts.
2. **Role**: Roles are collections of permissions.
3. **Policy**: Policies are collections of role bindings that associate one or more principals with specific roles.

## Access Management Concepts

Understanding key concepts related to access management is essential:

- **Resource**: A resource is a GCP entity to which access is required, such as a Google Cloud Storage (GCS) bucket, a Google Compute Engine (GCE) instance, or a BigQuery dataset.
- **Permissions**: Permissions dictate what operations are allowed on a resource. For instance, `roles/storage.admin` grants administrative permissions for a GCS bucket, while `roles/compute.instanceAdmin` provides administrative access to a GCE instance.
- **Roles**: Roles are predefined or custom collections of permissions.
  - **Basic Roles**: :warning: [**Not Recommended**] These legacy roles include Owner, Editor, and Viewer, which are not recommended for fine-grained access control.
  - **Predefined Roles**: These roles offer more granular access control than the basic roles.
  - **Custom Roles**: [**Recommended**] Custom roles can be created to tailor permissions to your organization's specific needs.

## Implementing IAM in Terraform Modules

Now, let's explore how to operationalize IAM in Terraform modules, making it easier to manage access permissions for different resources.

### Designing the Workflow

To ensure a standardized approach to IAM across various resources, it's beneficial to design a workflow that simplifies IAM assignment. We'll focus on a design where we create a resource and assign permissions to it. Here's an example using a Google Cloud Storage (GCS) bucket:

```hcl
module "gcs_bucket_creation" {
  source        = "../module"
  project       = "my_project"
  bucket_name   = "my-bucket-123"
  location      = "US"
  storage_class = "MULTI_REGIONAL"

  # Access permissions on the resource created
  access_permissions = [
    {
      service_account = "my-sa-1@gcs.iam.gserviceaccount.com"
      permission      = "ADMIN"
    },
    {
      group      = "my-group@my-org.com"
      permission = "ADMIN"
    }
  ]
}
```

| :books: :warning: NOTE: We need to run this terraform from a elevated service account which has permissions to create buckets and assign IAM. |
| :-------------------------------------------------------------------------------------------------------------------------------------------- |

In this example, we create a GCS bucket named "my-bucket-123" and assign permissions to it. The `access_permissions` variable is a list containing maps with keys such as `service_account`, `group`, and `permission`.

## Bucket Module.

Now, let's create a Terraform module to encapsulate the GCS bucket creation and IAM assignment logic.
:books: **NOTE**: These file are created in `module` directory.

### Creating Variable `module/variables.tf`

Define variables that allow users to provide input while ensuring proper validation and documentation:

First we will be creating variables for our module which take information from the consumer and do few inital validations.
Also add proper `description`, `type` and `defaults` as this will come in handy when we generate the `README.md` using `terraform-docs`.

```hcl
variable "bucket_name" {
  description = "The name of the bucket."
  type        = string
}

variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = "my-project"
}

variable "location" {
  description = "The [GCS location](https://cloud.google.com/storage/docs/locations)."
  type        = string
  default     = "US"
  validation {
    # Adding these conditions to show how we can limit the locations based on requirments
    condition     = contains(["US", "EU", "US-CENTRAL1", "US-EAST1", "US-WEST1", "US-WEST2"], var.location)
    error_message = "ERROR Location: We can only select options - US, EU, US-CENTRAL1, US-EAST1, US-WEST1, US-WEST2."
  }
}

variable "storage_class" {
  description = "The Storage Class of the new bucket. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  type        = string
  default     = "MULTI_REGIONAL"
  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "ERROR Storage Class: We can only select options - STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "access_permissions" {
  description = "Access permission to the bucket."
  type        = any
  default     = []
  validation {
    condition = alltrue([
      for map_key in
      distinct(
        flatten([
          for each_access in var.access_permissions : keys(each_access)
        ])
    ) : contains(["permission", "group", "service_account"], map_key)])
    error_message = "ERROR Access Permissions: We only accept these keys on the access list - service_accounts, permission, groups."
  }
}
```

### Bucket Resource `module/main.tf`

Now, create the GCS bucket resource:

```hcl
resource "google_storage_bucket" "create_new_bucket" {
  name          = var.bucket_name
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
}
```

### IAM permissions for Bucket `module/iam.tf`

In this file, we'll define IAM permissions and roles based on user input. We'll map access permissions to predefined roles and create bindings.

- First part, creating a map.

```hcl
  # Creating a permission map so that we have a consistant permission across all the modules
  iam_mapping = {
    "ADMIN"   = "roles/storage.admin"
    "WRTITER" = "roles/storage.objectUser"
    "READER"  = "roles/storage.objectViewer"
  }
```

- Creating a `sa` map using the access permissions list to use it with `for_each`

```hcl
  # Creating service account map
  sa_map = {
    for permissions in var.access_permissions : "${permissions.permission}-${permissions.service_account}" => permissions if contains(keys(permissions), "service_account")
  }
```

This creates a map as below

```hcl
{
  "ADMIN-my-sa-1@gcs.iam.gserviceaccount.com" = {
    "permission" = "ADMIN"
    "service_account" = "my-sa-1@gcs.iam.gserviceaccount.com"
  }
}
```

- Creating a `group` map using the access permissions list to use it with `for_each`

```hcl
  # Creating group map
  group_map = {
    for permissions in var.access_permissions : "${permissions.permission}-${permissions.group}" => permissions if contains(keys(permissions), "group")
  }
```

This creates a map as below

```hcl
  {
    "ADMIN-my-group@my-org.com" = {
      "group" = "my-group@my-org.com"
      "permission" = "ADMIN"
    }
  }
```

- This we then use with the resource as below

```hcl
resource "google_storage_bucket_iam_member" "sa_permission" {
  for_each = local.sa_map
  bucket   = google_storage_bucket.create_new_bucket.name
  role     = each.value.permission
  member   = "ServiceAccount:${each.value.service_account}"
}
```

Complete `iam.tf` file with resources.

```hcl
locals {

  # Creating a permission map so that we have a consistant permission across all the modules
  iam_mapping = {
    "ADMIN"   = "roles/storage.admin"
    "WRTITER" = "roles/storage.objectUser"
    "READER"  = "roles/storage.objectViewer"
  }

  # Creating service account map
  sa_map = {
    for permissions in var.access_permissions : "${permissions.permission}-${permissions.service_account}" => permissions if contains(keys(permissions), "service_account")
  }

  # Creating group map
  group_map = {
    for permissions in var.access_permissions : "${permissions.permission}-${permissions.group}" => permissions if contains(keys(permissions), "group")
  }
}

resource "google_storage_bucket_iam_member" "sa_permission" {
  for_each = local.sa_map
  bucket   = google_storage_bucket.create_new_bucket.name
  role     = each.value.permission
  member   = "ServiceAccount:${each.value.service_account}"
}

resource "google_storage_bucket_iam_member" "group_permission" {
  for_each = local.group_map
  bucket   = google_storage_bucket.create_new_bucket.name
  role     = each.value.permission
  member   = "group:${each.value.group}"
}
```

## Consumer or End User.

:books: **NOTE**: These file are created in `consumer` directory.

### Creating the `consumer_module/main.tf`

Creating a file which will use the module created above.

```hcl
module "gcs_bucket_creation" {
  source        = "../module"
  project       = "my_project"
  bucket_name   = "my-bucket-123"
  location      = "US"
  storage_class = "MULTI_REGIONAL"

  # Access permissions on the resource created
  access_permissions = [
    {
      service_account = "my-sa-1@gcs.iam.gserviceaccount.com"
      permission      = "ADMIN"
    },
    {
      group      = "my-group@my-org.com"
      permission = "ADMIN"
    }
  ]
}
```

## Implementation and Usage

By organizing your IAM configurations in Terraform modules, you can create a cleaner and more user-friendly interface for managing access permissions. Users can easily specify the required permissions and resources without needing in-depth knowledge of IAM roles and policies.

Running the module example provided earlier will generate output that automatically maps the permissions defined in `access_permissions` to their corresponding IAM roles. This approach streamlines IAM management and provides a foundation that can be adapted and extended as your project evolves.

```hcl
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.gcs_bucket_creation.google_storage_bucket.create_new_bucket will be created
  + resource "google_storage_bucket" "create_new_bucket" {
      + force_destroy               = false
      + id                          = (known after apply)
      + labels                      = (known after apply)
      + location                    = "US"
      + name                        = "my-bucket-123"
      + project                     = "my_project"
      + public_access_prevention    = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "MULTI_REGIONAL"
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)
    }

  # module.gcs_bucket_creation.google_storage_bucket_iam_member.group_permission["ADMIN-my-group@my-org.com"] will be created
  + resource "google_storage_bucket_iam_member" "group_permission" {
      + bucket = "my-bucket-123"
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "group:my-group@my-org.com"
      + role   = "roles/storage.admin"
    }

  # module.gcs_bucket_creation.google_storage_bucket_iam_member.sa_permission["ADMIN-my-sa-1@gcs.iam.gserviceaccount.com"] will be created
  + resource "google_storage_bucket_iam_member" "sa_permission" {
      + bucket = "my-bucket-123"
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "ServiceAccount:my-sa-1@gcs.iam.gserviceaccount.com"
      + role   = "roles/storage.admin"
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```
