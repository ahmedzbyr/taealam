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
  role     = local.iam_mapping[each.value.permission]
  member   = "ServiceAccount:${each.value.service_account}"
}

resource "google_storage_bucket_iam_member" "group_permission" {
  for_each = local.group_map
  bucket   = google_storage_bucket.create_new_bucket.name
  role     = local.iam_mapping[each.value.permission]
  member   = "group:${each.value.group}"
}
