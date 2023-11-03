output "this_private_connection_id" {
  description = "An identifier for the resource with format `projects/{{project}}/locations/{{location}}/privateConnections/{{private_connection_id}}`"
  value       = google_datastream_private_connection.main.id
}

output "this_private_connection_name" {
  description = "The resource's name."
  value       = google_datastream_private_connection.main.name
}

output "this_private_connection_state" {
  description = "State of the PrivateConnection."
  value       = google_datastream_private_connection.main.state
}

output "this_private_connection_error" {
  description = "The PrivateConnection error in case of failure."
  value       = google_datastream_private_connection.main.error
}

output "this_private_connection_terraform_labels" {
  description = "The combination of labels configured directly on the resource and default labels configured on the provider."
  value       = google_datastream_private_connection.main.terraform_labels
}

output "this_private_connection_effective_labels" {
  description = "All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services."
  value       = google_datastream_private_connection.main.effective_labels
}
