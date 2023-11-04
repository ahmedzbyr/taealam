output "this_stream_id" {
  description = "An identifier for the resource with format `projects/{{project}}/locations/{{location}}/streams/{{stream_id}}`"
  value       = google_datastream_stream.main.id
}

output "this_stream_name" {
  description = "The resource's name."
  value       = google_datastream_stream.main.name
}

output "this_stream_state" {
  description = "State of the Stream."
  value       = google_datastream_stream.main.state
}

output "this_stream_terraform_labels" {
  description = "The combination of labels configured directly on the resource and default labels configured on the provider."
  value       = google_datastream_stream.main.terraform_labels
}

output "this_stream_effective_labels" {
  description = "All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services."
  value       = google_datastream_stream.main.effective_labels
}
