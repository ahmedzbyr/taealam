<!-- BEGIN_TF_DOCS -->

#  Firestore Backup Schedule

- **About Backups:**
  - A backup provides a snapshot of the database at a specific moment in time.
  - It captures all data and index configurations of the database when the backup is created.
  - Database time to live policies are not included in backups.
  - The backup is stored in the same location as its source database.

- **Backup Retention and Deletion:**
  - Backups come with a set retention period.
  - They remain stored until either the retention period ends or the backup is manually deleted.
  - If the original database is deleted, its backups are not automatically removed.
  - For the default database, all associated backups must be deleted first before the database itself can be deleted.

- **Metadata and Backup Schedules:**
  - Cloud Firestore keeps metadata regarding backups and their schedules related to a database.
  - This metadata is preserved until all backups for that database either expire or are manually deleted.

- **Performance Implications:**
  - The process of creating or retaining backups doesn't impact the performance of live database read or write operations.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_frequency"></a> [frequency](#input\_frequency) | For a schedule that runs daily at a specified time. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_retention"></a> [retention](#input\_retention) | At what relative time in the future, compared to its creation time, the backup should be deleted, <br>  e.g. keep backups for 7 days. A duration in seconds with up to nine fractional digits, ending with 's'. <br><br>  Example: "3.5s". For a daily backup recurrence, set this to a value up to 7 days. <br>  If you set a weekly backup recurrence, set this to a value up to 14 weeks. | `string` | n/a | yes |
| <a name="input_database"></a> [database](#input\_database) | The Firestore database id. Defaults to `(default)`. | `string` | `"(default)"` | no |
| <a name="input_day_of_the_week"></a> [day\_of\_the\_week](#input\_day\_of\_the\_week) | The day of week to run (only used if frequency == WEEKLY). Possible values are: DAY\_OF\_WEEK\_UNSPECIFIED, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY. | `string` | `"SUNDAY"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_backup_schedule_id"></a> [this\_backup\_schedule\_id](#output\_this\_backup\_schedule\_id) | An identifier for the resource with format projects/{{project}}/databases/{{database}}/backupSchedules/{{name}} |
| <a name="output_this_backup_schedule_name"></a> [this\_backup\_schedule\_name](#output\_this\_backup\_schedule\_name) | The unique backup schedule identifier across all locations and databases for the given project. Format: `projects/{{project}}/databases/{{database}}/backupSchedules/{{backupSchedule}}` |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.2.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_firestore_backup_schedule.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/firestore_backup_schedule) | resource |


##  Managing Roles and Permissions

1. **Acquire Permissions for Backup Management:**
   - Request your administrator to grant you one or more of the following roles:
     - `roles/datastore.owner`: Full access to the Cloud Firestore database.
   - For roles not visible in the Google Cloud Platform Console:
     - Use the Google Cloud CLI to assign the following roles:
       - `roles/datastore.backupsAdmin`: Read and write access to backups.
       - `roles/datastore.backupsViewer`: Read access to backups.
       - `roles/datastore.backupSchedulesAdmin`: Read and write access to backup schedules.
       - `roles/datastore.backupSchedulesViewer`: Read access to backup schedules.
       - `roles/datastore.restoreAdmin`: Permissions to initiate restore operations.

##  **Backup Schedules**

1. **Setup Rules for Backup Scheduling:**
   - For each database:
     - Configure up to one daily backup schedule.
     - Set up one weekly backup schedule.
   - Note:
     - You can't schedule multiple weekly backups for different days.
     - Backups are at varied times each day.

2. **Creating a Backup Schedule:**
   - Use the command:

     ```
     gcloud alpha firestore backups schedules create --database='*DATABASE_ID*' --recurrence=*RECURRENCE_TYPE* --retention=*RETENTION_PERIOD* [--day-of-week=*DAY*]
     ```

     Replace:
     - `*DATABASE_ID*`: ID of the database. Use `(default)` for the default database.
     - `*RECURRENCE_TYPE*`: `daily` for daily backup, `weekly` for weekly backup.
     - `*RETENTION_PERIOD*`: Set to up to 7 days (`7d`) for daily, up to 14 weeks (`14w`) for weekly.
     - `*DAY*`: Day of the week for weekly backups.

3. **List All Backup Schedules:**
   - Use the command:

     ```
     gcloud alpha firestore backups schedules list --database='*DATABASE_ID*'
     ```

     Replace:
     - `*DATABASE_ID*`: ID of the database.

4. **Get Information about a Specific Backup Schedule:**
   - Use the command:

     ```
     gcloud alpha firestore backups schedules describe --database='*DATABASE_ID*' --backup-schedule=*BACKUP_SCHEDULE_ID*
     ```

     Replace:
     - `*DATABASE_ID*` and `*BACKUP_SCHEDULE_ID*` appropriately.

5. **Update an Existing Backup Schedule:**
   - Use the command:

     ```
     gcloud alpha firestore backups schedules update --database='*DATABASE_ID*' --backup-schedule=*BACKUP_SCHEDULE_ID* --retention=*RETENTION_PERIOD*
     ```

     Replace values as needed.

6. **Delete a Backup Schedule:**
   - Use the command:

     ```
     gcloud alpha firestore backups schedules delete --database='*DATABASE_ID*' --backup-schedule=*BACKUP_SCHEDULE_ID*
     ```

     Note: Deleting the schedule doesn't delete existing backups.

## Managing Backups

1. **List All Available Backups:**
   - Use the command:

     ```
     gcloud alpha firestore backups list --format="table(name, database, state)"
     ```

     For a specific location:

     ```
     gcloud alpha firestore backups list --location=*LOCATION* --format="table(name, database, state)"
     ```

2. **View Details of a Specific Backup:**
   - Use the command:

     ```
     gcloud alpha firestore backups describe --location=*LOCATION* --backup=*BACKUP_ID*
     ```

3. **Delete a Backup:**
    - WARNING: Cannot recover a deleted backup.
    - Use the command:

      ```
      gcloud alpha firestore backups delete --location=*LOCATION* --backup=*BACKUP_ID*
      ```

##  Restoring Data from a Backup**

1. **Initiate a Restore Operation:**
    - Use the command:

      ```
      gcloud alpha firestore databases restore --source-backup=projects/*PROJECT_ID*/locations/*LOCATION*/backups/*BACKUP_ID* --destination-database='*DATABASE_ID*'
      ```

    Replace:
    - `*PROJECT_ID*`, `*LOCATION*`, `*BACKUP_ID*`, and `*DATABASE_ID*` as needed.

---

## API JSON Information

```json
{
  "name": string,
  "createTime": string,
  "updateTime": string,
  "retention": string,

  // Union field recurrence can be only one of the following:
  "dailyRecurrence": {
    object (DailyRecurrence)
  },
  "weeklyRecurrence": {
    object (WeeklyRecurrence)
  }
  // End of list of possible types for union field recurrence.
}
```

##  API Information - Backup Schedule Fields

| Field Name               | Data Type & Format                                                                                                                           | Description                                                                                                                                                                                                                                          |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                   | `string`                                                                                                                                     | **Output only.** The unique backup schedule identifier across all locations and databases for the given project. This will be auto-assigned. Format is `projects/{project}/databases/{database}/backupSchedules/{backupSchedule}`.                   |
| `createTime`             | `string` ([Timestamp](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp) format)       | **Output only.** The timestamp at which this backup schedule was created and effective since. No backups will be created for this schedule before this time. Format examples: `"2014-10-02T15:01:23Z"` and `"2014-10-02T15:01:23.045123456Z"`.       |
| `updateTime`             | `string` ([Timestamp](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp) format)       | **Output only.** The timestamp at which this backup schedule was most recently updated. When a backup schedule is first created, this is the same as `createTime`. Format examples: `"2014-10-02T15:01:23Z"` and `"2014-10-02T15:01:23.045123456Z"`. |
| `retention`              | `string` ([Duration](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Duration) format)         | At what relative time in the future, compared to its creation time, the backup should be deleted, e.g., keep backups for 7 days. Example format: `"3.5s"`.                                                                                           |
| Union field `recurrence` | Can be only one of the following:                                                                                                            | Represents when backups will be taken.                                                                                                                                                                                                               |
| `dailyRecurrence`        | `object` ([DailyRecurrence](https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.backupSchedules#DailyRecurrence))   | For a schedule that runs daily at a specified time.                                                                                                                                                                                                  |
| `weeklyRecurrence`       | `object` ([WeeklyRecurrence](https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.backupSchedules#WeeklyRecurrence)) | For a schedule that runs weekly on a specific day and time.                                                                                                                                                                                          |

### DailyRecurrence

This type has no fields. Represents a recurring schedule that runs at a specific time every day. The time zone is UTC.

### WeeklyRecurrence

Represents a recurring schedule that runs on a specified day of the week. The time zone is UTC.

**JSON representation:**

```json
{
  "day": enum ([DayOfWeek](https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.backupSchedules#DayOfWeek))
}
```

**Fields:**

| Field Name | Data Type                                                                                                                    | Description                                                       |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `day`      | `enum` ([DayOfWeek](https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.backupSchedules#DayOfWeek)) | The day of week to run. `DAY_OF_WEEK_UNSPECIFIED` is not allowed. |

### DayOfWeek

Represents a day of the week.

**Enums:**

| Enum Value                | Description                         |
| ------------------------- | ----------------------------------- |
| `DAY_OF_WEEK_UNSPECIFIED` | The day of the week is unspecified. |
| `MONDAY`                  | Monday                              |
| `TUESDAY`                 | Tuesday                             |
| `WEDNESDAY`               | Wednesday                           |
| `THURSDAY`                | Thursday                            |
| `FRIDAY`                  | Friday                              |
| `SATURDAY`                | Saturday                            |
| `SUNDAY`                  | Sunday                              |

---
<!-- END_TF_DOCS -->    