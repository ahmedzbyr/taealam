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
