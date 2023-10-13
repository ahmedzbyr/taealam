# All outputs

output "this_database_id" {
  description = "An identifier for the resource with format `projects/{{project}}/databases/{{name}}`"
  value       = google_firestore_database.main.id
}

output "this_key_prefix" {
  description = <<EOF
  The keyPrefix for this database. 
  
  - This keyPrefix is used, in combination with the project id (\~) to construct the application id that is returned from the Cloud Datastore APIs in Google App Engine first generation runtimes. 
  - This value may be empty in which case the appid to use for URL-encoded keys is the project_id (eg: foo instead of v\~foo).

  EOF
  value       = google_firestore_database.main.key_prefix
}

output "this_etag" {
  description = "This checksum is computed by the server based on the value of other fields, and may be sent on update and delete requests to ensure the client has an up-to-date value before proceeding."
  value       = google_firestore_database.main.etag
}

output "this_create_time" {
  description = "The timestamp at which this database was created."
  value       = google_firestore_database.main.create_time
}

output "this_update_time" {
  description = "The timestamp at which this database was most recently updated."
  value       = google_firestore_database.main.update_time
}

output "this_uid" {
  description = "The system-generated UUID4 for this Database."
  value       = google_firestore_database.main.uid
}

output "this_version_retention_period" {
  description = " The period during which past versions of data are retained in the database. \n  - Any read or query can specify a readTime within this window, and will read the state of the database at that time.\n  - If the PITR feature is enabled, the retention period is 7 days.\n  - Otherwise, the retention period is 1 hour.\n  - A duration in seconds with up to nine fractional digits, ending with 's'. Example: \"3.5s\"."
  value       = google_firestore_database.main.version_retention_period
}

output "this_earliest_version_time" {
  description = <<EOF
  The earliest timestamp at which older versions of the data can be read from the database. 
  
  - See versionRetentionPeriod above; this field is populated with now - versionRetentionPeriod. 
  - This value is continuously updated, and becomes stale the moment it is queried. 
  - If you are using this value to recover data, make sure to account for the time from the moment when the value is queried to the moment when you initiate the recovery. 
  - A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. 
  
  Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".

  EOF
  value       = google_firestore_database.main.earliest_version_time
}
