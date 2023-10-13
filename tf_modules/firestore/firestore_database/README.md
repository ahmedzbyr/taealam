<!-- BEGIN_TF_DOCS -->

#  Cloud Firestore Database Creation Module.

If you wish to use Firestore with App Engine, use the `google_app_engine_application` resource instead.

## Key Features

1. **Serverless and Fully Managed:**
   - Firestore is a fully managed, serverless database, meaning you don't need to worry about server provisioning or maintenance.
   - It seamlessly scales to meet any demand without maintenance windows or downtime.

2. **Powerful Query Engine:**
   - Firestore enables sophisticated ACID transactions against your document data, offering flexibility in data structure design.

3. **AI Integrations:**
   - Firestore offers turn-key extensions for easy integration with popular AI services, such as automated language translations and image classification.

4. **Easily Share Data with BigQuery:**
   - Capture document changes in Firestore and replicate them to BigQuery for analytics.
   - Pull data from BigQuery into Firestore to enhance your applications with analytics.

5. **Security and Identity Integration:**
   - Firestore seamlessly integrates with Firebase Authentication and Identity Platform.
   - It allows customizable identity-based security access controls and data validation through a configuration language.

6. **Multi-Region Replication:**
   - Firestore provides automatic multi-region replication with strong consistency.
   - It guarantees 99.999% availability, even during disasters.

7. **Live Synchronization and Offline Mode:**
   - Firestore offers built-in live synchronization and offline mode.
   - Ideal for developing multi-user, collaborative applications across mobile, web, and IoT, including real-time analytics and various media and communication applications.

8. **Libraries for Popular Languages:**
   - Firestore offers client-side development libraries for popular platforms such as Web, iOS, Android, Flutter, C++, and Unity.
   - Traditional server-side development libraries are available for Node.js, Java, Go, Ruby, and PHP.

9. **Datastore Mode Compatibility:**
   - Firestore supports the Datastore API, ensuring a smooth transition for existing Datastore apps.
   - It retains the same performance characteristics and pricing while adding strong consistency.

Firestore provides a robust, scalable, and user-friendly database solution for a wide range of applications, making it a powerful choice for developers looking to build modern, cloud-native applications.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location_id"></a> [location\_id](#input\_location\_id) | The location of the database. Available locations are listed at https://cloud.google.com/firestore/docs/locations. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The ID to use for the database, which will become the final component of the database's resource name. <br><br>    - This value should be 4-63 characters. <br>    - Valid characters are /[a-z][0-9]-/ with first character a letter and the last a letter or a number. <br>    - Must not be UUID-like /[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/. <br>    - `"(default)"` database id is also valid. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | The type of the database. <br>  - Please See [firestore-or-datastore](https://cloud.google.com/datastore/docs/firestore-or-datastore) for information about how to choose. <br>  - Possible values are: `FIRESTORE_NATIVE`, `DATASTORE_MODE`. | `string` | n/a | yes |
| <a name="input_app_engine_integration_mode"></a> [app\_engine\_integration\_mode](#input\_app\_engine\_integration\_mode) | App Engine integration mode to use for this database. Possible values are: `ENABLED`, `DISABLED`. | `string` | `null` | no |
| <a name="input_concurrency_mode"></a> [concurrency\_mode](#input\_concurrency\_mode) | The concurrency control mode to use for this database. <br>  Possible values are: `OPTIMISTIC`, `PESSIMISTIC`, `OPTIMISTIC_WITH_ENTITY_GROUPS`. | `string` | `null` | no |
| <a name="input_delete_protection_state"></a> [delete\_protection\_state](#input\_delete\_protection\_state) | State of delete protection for the database. <br><br>    Possible values are: `DELETE_PROTECTION_STATE_UNSPECIFIED`, `DELETE_PROTECTION_ENABLED`, `DELETE_PROTECTION_DISABLED`. | `string` | `null` | no |
| <a name="input_point_in_time_recovery_enablement"></a> [point\_in\_time\_recovery\_enablement](#input\_point\_in\_time\_recovery\_enablement) | Whether to enable the PITR feature on this database. <br><br>  - If `POINT_IN_TIME_RECOVERY_ENABLED` is selected, reads are supported on selected versions of the data from within the past 7 days. <br>    - `versionRetentionPeriod` and `earliestVersionTime` can be used to determine the supported versions. <br>    - These include reads against any timestamp within the past hour and reads against 1-minute snapshots beyond 1 hour and within 7 days. <br>  - If `POINT_IN_TIME_RECOVERY_DISABLED` is selected, reads are supported on any version of the data from within the past 1 hour. <br>  - Default value is `POINT_IN_TIME_RECOVERY_DISABLED`. <br><br>  Possible values are: `POINT_IN_TIME_RECOVERY_ENABLED`, `POINT_IN_TIME_RECOVERY_DISABLED`. | `string` | `"POINT_IN_TIME_RECOVERY_DISABLED"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_create_time"></a> [this\_create\_time](#output\_this\_create\_time) | The timestamp at which this database was created. |
| <a name="output_this_database_id"></a> [this\_database\_id](#output\_this\_database\_id) | An identifier for the resource with format `projects/{{project}}/databases/{{name}}` |
| <a name="output_this_earliest_version_time"></a> [this\_earliest\_version\_time](#output\_this\_earliest\_version\_time) | The earliest timestamp at which older versions of the data can be read from the database. <br><br>  - See versionRetentionPeriod above; this field is populated with now - versionRetentionPeriod. <br>  - This value is continuously updated, and becomes stale the moment it is queried. <br>  - If you are using this value to recover data, make sure to account for the time from the moment when the value is queried to the moment when you initiate the recovery. <br>  - A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. <br><br>  Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z". |
| <a name="output_this_etag"></a> [this\_etag](#output\_this\_etag) | This checksum is computed by the server based on the value of other fields, and may be sent on update and delete requests to ensure the client has an up-to-date value before proceeding. |
| <a name="output_this_key_prefix"></a> [this\_key\_prefix](#output\_this\_key\_prefix) | The keyPrefix for this database. <br><br>  - This keyPrefix is used, in combination with the project id,  to construct the application id that is returned from the Cloud Datastore APIs in Google App Engine first generation runtimes. <br>  - This value may be empty in which case the appid to use for URL-encoded keys is the project\_id (eg: foo instead of v~foo). |
| <a name="output_this_uid"></a> [this\_uid](#output\_this\_uid) | The system-generated UUID4 for this Database. |
| <a name="output_this_update_time"></a> [this\_update\_time](#output\_this\_update\_time) | The timestamp at which this database was most recently updated. |
| <a name="output_this_version_retention_period"></a> [this\_version\_retention\_period](#output\_this\_version\_retention\_period) | The period during which past versions of data are retained in the database. <br>  - Any read or query can specify a readTime within this window, and will read the state of the database at that time.<br>  - If the PITR feature is enabled, the retention period is 7 days.<br>  - Otherwise, the retention period is 1 hour.<br>  - A duration in seconds with up to nine fractional digits, ending with 's'. Example: "3.5s". |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.1.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 5.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_firestore_database.main](https://registry.terraform.io/providers/hashicorp/google/5.1.0/docs/resources/firestore_database) | resource |

## JSON Information

```json
{
  "name": string,
  "uid": string,
  "createTime": string,
  "updateTime": string,
  "locationId": string,
  "type": enum (DatabaseType),
  "concurrencyMode": enum (ConcurrencyMode),
  "versionRetentionPeriod": string,
  "earliestVersionTime": string,
  "pointInTimeRecoveryEnablement": enum (PointInTimeRecoveryEnablement),
  "appEngineIntegrationMode": enum (AppEngineIntegrationMode),
  "keyPrefix": string,
  "deleteProtectionState": enum (DeleteProtectionState),
  "etag": string
}
```

##  API Information

- [REST Resource: projects.databases](https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases)

| Field                         | Type                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ----------------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name                          | string                               | The resource name of the Database. Format: `projects/{project}/databases/{database}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| uid                           | string                               | Output only. The system-generated `UUID4` for this Database.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| createTime                    | string (Timestamp format)            | Output only. The timestamp at which this database was created. Databases created before 2016 do not populate createTime. A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".                                                                                                                                                                                                                                                                                                                                    |
| updateTime                    | string (Timestamp format)            | Output only. The timestamp at which this database was most recently updated. Note this only includes updates to the database resource and not data contained by the database. A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".                                                                                                                                                                                                                                                                               |
| locationId                    | string                               | The location of the database. Available databases are listed at [https://cloud.google.com/firestore/docs/locations](https://cloud.google.com/firestore/docs/locations).                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| type                          | enum (DatabaseType)                  | The type of the database. See [https://cloud.google.com/datastore/docs/firestore-or-datastore](https://cloud.google.com/datastore/docs/firestore-or-datastore) for information about how to choose.                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| concurrencyMode               | enum (ConcurrencyMode)               | The concurrency control mode to use for this database.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| versionRetentionPeriod        | string (Duration format)             | Output only. The period during which past versions of data are retained in the database. Any read or query can specify a readTime within this window, and will read the state of the database at that time. If the PITR feature is enabled, the retention period is 7 days. Otherwise, the retention period is 1 hour. A duration in seconds with up to nine fractional digits, ending with 's'. Example: "3.5s".                                                                                                                                                                                                                         |
| earliestVersionTime           | string (Timestamp format)            | Output only. The earliest timestamp at which older versions of the data can be read from the database. See [versionRetentionPeriod] above; this field is populated with now - versionRetentionPeriod. This value is continuously updated and becomes stale the moment it is queried. If you are using this value to recover data, make sure to account for the time from the moment when the value is queried to the moment when you initiate the recovery. A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z". |
| pointInTimeRecoveryEnablement | enum (PointInTimeRecoveryEnablement) | Whether to enable the PITR feature on this database.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| appEngineIntegrationMode      | enum (AppEngineIntegrationMode)      | The App Engine integration mode to use for this database.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| keyPrefix                     | string                               | Output only. The keyPrefix for this database. This keyPrefix is used, in combination with the project id ("~") to construct the application id that is returned from the Cloud Datastore APIs in Google App Engine first generation runtimes. This value may be empty in which case the appid to use for URL-encoded keys is the projectId (e.g., foo instead of v~foo).                                                                                                                                                                                                                                                                  |
| deleteProtectionState         | enum (DeleteProtectionState)         | State of delete protection for the database.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| etag                          | string                               | This checksum is computed by the server based on the value of other fields and may be sent on update and delete requests to ensure the client has an up-to-date value before proceeding.                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

## Pricing

Cloud Firestore detailed pricing is available on [pricing page](https://cloud.google.com/firestore/pricing).

| Feature          | Price                |
| ---------------- | -------------------- |
| Stored data      | $0.18/GB             |
| Bandwidth        | Google Cloud pricing |
| Document writes  | $0.18/100K           |
| Document reads   | $0.06/100K           |
| Document deletes | $0.02/100K           |
<!-- END_TF_DOCS -->    