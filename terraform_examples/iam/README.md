One of the most important part of the setting up any resource in cloud or on-prem is to have security around it.
Security can be implemented in different scales, be it in network (firewall, natting, routing), encryption (encryption-at-rest, encryption-in-transit), Access control (kerberos, role based access control aka RBAC).

But in general cybersecurity has 7 layers of security.

1. Critical Assets.
2. Data Security
3. Application Security
4. Endpoint Security
5. Network
6. Perimeter
7. Human

### Application Security

Applications security controls protect access to an application, an application’s access to your mission critical assets, and the internal security of the application.

This post will be about one of the security measured (**Application Security**) on Cloud called IAM (Identity & Access Management) specific to **GCP** resource.
One of the core rules of IAM is to give access only _what is required_ not more.

### In this post

- We will create a design to generize the IAM information a given module.
- Create a template to setup IAM for a given resource using terraform.
- How we can incorporate IAM into modules.

### Why is it Important?

- This help is improving security around the resource.
- Give minimum access required to the Purpose the access was create.

### What is the IAM?

- Identity and Access Management (IAM) lets administrators authorize who can take action on specific resources, giving you full control and visibility to manage Google Cloud resources centrally.
- IAM provides tools to manage resource permissions with minimum fuss and high automation, using the terraform resource and APIs.
- Get granular with context-aware access to each resource.
- Streamline compliance with a built-in audit trails.

### How does IAM work?

- In General IAM has three main parts
  - **Principal**: user, group or service account.
  - **Role**: Collection of permissions.
  - **Policy**: Collection of role bindings that bind one or more principals to individual roles.
- Concepts related to access management
  - Resource: Cloud resource which we require the access on, example GCS bucket, GCE Instance, Bigquery Dataset are few examples of a resource.
  - Permissions: Permissions determine what operations are allowed on a resource. Example: `roles/storage.admin` for a GCS bucket, `roles/compute.instanceAdmin` for a GCE Instance, both give Admin permissions on the resource.
  - Roles: A role is a collection of permissions.
    - **Basic Roles**: :warning: [**NOT Recommended**] Roles historically available in the Google Cloud console. These roles are Owner, Editor, and Viewer.
    - **Predefined Roles**: Roles that give finer-grained access control than the basic roles.
    - **Custom Role**: [**Recommended**] Roles that you create to tailor permissions to the needs of your organization when predefined roles don't meet your needs.

## Setting IAM in Terraform Modules

Before we get started we need to design the workflow so that we can generalize the IAM for different resource.
Below is an example on how we would like end user to use or assign the IAM.

For our design we will restrict access to service_account and groups only. This is a good access restriction to start with, this will have access to specific service accounts and groups to which users can get access to using the access controls. Also this is an easy way manage access to a resource.

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

In the above example we are creating a design in which we create a bucket and then assign permissions to the bucket.

| :books: :warning: NOTE: We need to run this terraform from a elevated service account which has permissions to create buckets and assign IAM. |
| :-------------------------------------------------------------------------------------------------------------------------------------------- |

Variable `access_permissions` will be a list which takes `service_account`, `group`, `permission` as the keys for the list of maps inside it.

## Bucket Module.

:books: **NOTE**: These file are created in `module` directory.

### Creating Variable `module/variables.tf`

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

### Bucket Resource `module/main.tf`

Next we will create a simple bucket resource, which creates a bucket.

```hcl
resource "google_storage_bucket" "create_new_bucket" {
  name          = var.bucket_name
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
}
```

### IAM permissions for Bucket `module/iam.tf`

In this file we will create a mapping and assign `NON Authoritative` permissions to the bucket using `google_storage_bucket_iam_member`.

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

## Consumer or End User.

:books: **NOTE**: These file are created in `consumer` directory.

### Creating the `consumer_module/main.tf`

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

Running the above module will yeild the below output. All the list of permissions are added and mapped automatically to what we have defined. This will create a nicer interface to the user and we can then change these updates to a custom role later on the project lifecycle.

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
