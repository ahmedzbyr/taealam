output "this_connection_profile_id" {
  description = "An identifier for the resource with format `projects/{{project}}/locations/{{location}}/connectionProfiles/{{connection_profile_id}}`"
  value       = google_datastream_connection_profile.main.id
}

output "this_connection_profile_name" {
  description = "The resource's name."
  value       = google_datastream_connection_profile.main.name
}

output "this_connection_profile_terraform_labels" {
  description = "The combination of labels configured directly on the resource and default labels configured on the provider."
  value       = google_datastream_connection_profile.main.terraform_labels
}

output "this_connection_profile_effective_labels" {
  description = "All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services."
  value       = google_datastream_connection_profile.main.effective_labels
}
