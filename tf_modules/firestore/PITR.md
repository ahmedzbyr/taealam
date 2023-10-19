# Disaster Recovery Planning with Firestore

Introduction:
Disaster recovery planning is crucial when it comes to safeguarding your data and applications in the cloud. Firestore, a part of Google Cloud, offers a range of features designed to help you establish effective disaster recovery plans. This article will delve into Firestore's capabilities for mitigating both cloud infrastructure outages and data disasters, ensuring the continuity and integrity of your critical data.

Disaster Recovery for Cloud Infrastructure Outages:
----------------------------------------------

In the event of cloud infrastructure disruptions, Firestore employs robust replication strategies to safeguard your data. The approach to replication varies based on whether your Firestore database is in a regional or multi-region location.

**Regional Databases:**
Regional databases ensure data consistency by synchronously replicating data across a minimum of three zones. This architecture provides a 99.99% availability, which can be essential for critical applications.

**Multi-Region Databases:**
For even higher availability and durability, multi-region databases are the go-to choice. They synchronously replicate data across five zones, spread across three regions, including two serving regions and one witness region. This setup guarantees an impressive 99.999% availability.

Firestore automates replication, sparing you the need for additional configuration or provisioning. For an in-depth understanding of Firestore's replication architecture, please visit [Architecting disaster recovery for cloud infrastructure outages](https://cloud.google.com/architecture/disaster-recovery#Firestore). If you want to explore more about recovery time objectives (RTO) and recovery point objectives (RPO), check out [Google Cloud service recovery objectives](https://cloud.google.com/architecture/disaster-recovery/product-commitments).

Disaster Recovery for Data:
-------------------------------

Firestore offers various tools to protect your data against disasters like accidental deletion or modification. These tools include scheduled backups and point-in-time recovery (PITR), which can be used in combination to meet your specific disaster recovery requirements.

**Scheduled Backups:**
With scheduled backups, you can choose daily or weekly backup intervals. Daily backups have a maximum retention period of 7 days, while weekly backups can be retained for up to 14 weeks. Restoring from a backup to a new Firestore database within the same project is straightforward, and you can find detailed instructions in the [Back up and restore data](https://cloud.google.com/firestore/docs/backups) guide.

It's important to note that weekly backups offer a longer retention period compared to PITR, and they are more cost-effective for restoring an entire database.

**Point in Time Recovery (PITR):**
PITR is your solution for reading documents from a specific point in time, up to seven days in the past. This granular approach allows you to recover data at a one-minute interval with a recovery time objective (RTO) of 0 and a recovery point objective (RPO) of 1 minute. More information on how to implement PITR can be found in the [Point in time recovery](https://cloud.google.com/firestore/docs/pitr) documentation.

PITR is particularly valuable when you don't need to restore the entire database, offering a lower RTO and RPO compared to backups.

**Consistent Data Exports:**
For data retention needs that extend beyond 14 weeks, PITR can be used to create consistent exports of your entire database. This data can then be saved in Cloud Storage indefinitely. These consistent exports capture data from a timestamp up to one hour in the past, making them a practical choice for archiving purposes.

It's worth noting that recovering a database from a consistent export can be costlier than restoring the same data from a backup. To initiate a consistent export operation, refer to the instructions in [Export and import from a consistent PITR version](https://cloud.google.com/firestore/docs/use-pitr#export_and_import_from_a_consistent_pitr_version).

# Firestore Backup and Data Restoration Guide

**Introduction**

Before diving into Firestore's scheduled backups and data restoration capabilities, it's important to note that this feature is subject to the "Pre-GA Offerings Terms" outlined in the General Service Terms of the [Service Specific Terms](https://cloud.google.com/terms/service-terms#1). Pre-GA features are provided "as is" and may have limited support. For a more detailed understanding of launch stages and their descriptions, refer to the [product launch stages](https://cloud.google.com/products#product-launch-stages) page.

**Scheduled Backups with Firestore**

Here we focus on how to effectively use Firestore's scheduled backups feature. These scheduled backups are invaluable for protecting your data from application-level data corruption or accidental data deletion.

**Understanding Backups**

A Firestore backup is essentially a consistent snapshot of your database at a specific point in time. It encompasses all the data and index configurations existing at that particular moment. However, it's important to note that backups do not include database [time-to-live policies](https://cloud.google.com/firestore/docs/ttl). These backups are stored in the same location as the source database.

It's crucial to understand that backups have a configurable retention period. They are stored until this retention period expires or until you manually delete them. Deleting the source database does not automatically remove the related backups. However, for the `(default)` database, you must delete all related backups before deleting the database.

Firestore retains metadata associated with backups and backup schedules for a database until all backups for that database either expire or are deleted.

The creation and retention of backups have no impact on the performance of reads or writes in your live database.

**Costs Associated with Backups**

When you utilize backups, there are associated costs, including:

- Storage costs for each backup.
- Costs based on the size of the backup during restore operations.

For specific pricing details and exact rates, consult the [Firestore Pricing](https://cloud.google.com/firestore/pricing) page.

**Before You Begin**

Before you can start using scheduled backups with Firestore, ensure that billing is enabled for your Google Cloud project. You can learn how to verify billing status for your project by following the steps in [check if billing is enabled on a project](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled).

**Required Roles**

To manage backups and backup schedules, you'll need certain Identity and Access Management roles. These permissions can be granted by your administrator:

- `roles/datastore.owner`: Provides full access to the Firestore database.
- The following roles are also available, although they are not visible in the Google Cloud console. You can assign these roles using the [Google Cloud CLI](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role):
  - `roles/datastore.backupsAdmin`: Allows read and write access to backups.
  - `roles/datastore.backupsViewer`: Provides read access to backups.
  - `roles/datastore.backupSchedulesAdmin`: Allows read and write access to backup schedules.
  - `roles/datastore.backupSchedulesViewer`: Grants read access to backup schedules.
  - `roles/datastore.restoreAdmin`: Provides permissions for initiating restore operations.

**Creating and Managing Backup Schedules**

Now, let's delve into creating and managing backup schedules. Firestore enables you to configure up to one daily and one weekly backup schedule for each database. Note that it's not possible to configure multiple weekly backup schedules for different days of the week. Additionally, you cannot specify the exact time of day for the backup. Backups are taken at varying times each day. For weekly backups, you can, however, choose the day of the week for the backup.

**Creating a Backup Schedule**

To create a backup schedule for a database, you can use the `gcloud alpha firestore backups schedules create` command. Here's how you can create daily and weekly backup schedules:

**Create a Daily Backup Schedule**

To establish a daily backup schedule, use the `--recurrence` flag set to `daily`. The following command provides an example:

```shell
gcloud alpha firestore backups schedules create \
--database='*DATABASE_ID*' \
--recurrence=daily \
--retention=*RETENTION_PERIOD*
```

- Replace `*DATABASE_ID*` with the ID of the database you want to back up (set to `(default)` for the default database).
- For a daily backup recurrence, set `*RETENTION_PERIOD*` to a value up to 7 days (`7d`). If you're configuring a weekly backup recurrence, set it to a value up to 14 weeks (`14w`).

**Create a Weekly Backup Schedule**

For a weekly backup schedule, set the `--recurrence` flag to `weekly`. Here's an example:

```shell
gcloud alpha firestore backups schedules create \
--database='*DATABASE_ID*' \
--recurrence=weekly \
--retention=*RETENTION_PERIOD* \
--day-of-week=*DAY*
```

- Replace `*DATABASE_ID*` with the database ID (set to `(default)` for the default database).
- Configure `*RETENTION_PERIOD*` according to the desired weekly backup period (up to 14 weeks).
- Specify `*DAY*` as the day of the week for the backup, choosing from options like `SUN` for Sunday, `MON` for Monday, and so on.

**Listing Backup Schedules**

To list all backup schedules for a database, use the `gcloud alpha firestore backups schedules list` command. This command provides information about all existing backup schedules.

```shell
gcloud alpha firestore backups schedules list --database='*DATABASE_ID*'
```

Replace `*DATABASE_ID*` with the ID of your database (use `(default)` for the default database).

**Describing a Backup Schedule**

To retrieve details about a specific backup schedule, use the `gcloud alpha firestore backups schedules describe` command. Here's how:

```shell
gcloud alpha firestore backups schedules describe --database='*DATABASE_ID*' --backup-schedule=*BACKUP_SCHEDULE_ID*
```

- Replace `*DATABASE_ID*` with the database ID (use `(default)` for the default database).
- Specify `*BACKUP_SCHEDULE_ID*` as the ID of the backup schedule. You can obtain the ID when you list all backup schedules.

**Updating a Backup Schedule**

To update the retention period of a backup schedule, you can use the `gcloud alpha firestore backups schedules update` command:

```shell
gcloud alpha firestore backups schedules update --database='*DATABASE_ID*' --backup-schedule=*BACKUP_SCHEDULE_ID* --retention=*RETENTION_PERIOD*
```

- Replace `*DATABASE_ID*` with the database ID (use `(default)` for the default database).
- Specify `*BACKUP_SCHEDULE_ID*` as the ID of the backup schedule, which you can find when listing all backup schedules.
- Adjust `*RETENTION_PERIOD*` based on your requirements, considering the specified backup recurrence (up to 7 days for daily backups and up to 14 weeks for weekly backups).

**Deleting a Backup Schedule**

To delete a backup schedule, use the `gcloud alpha firestore backups schedules delete` command:

```shell
gcloud alpha firestore backups schedules delete --database='*DATABASE_ID*' --backup-schedule=*BACKUP_SCHEDULE_ID*
```

- Replace `*DATABASE_ID*` with the database ID (use `(default)` for the

 default database).
- Specify `*BACKUP_SCHEDULE_ID*` as the ID of the backup schedule. You can find this ID when you list all backup schedules.

It's important to note that deleting a backup schedule won't remove backups that were already created by that schedule. You can either wait for them to expire as per their retention period or manually delete them. For manual deletion, refer to the [delete backup](https://cloud.google.com/firestore/docs/backups#delete_backup) instructions.

**Managing Backups**

Now, let's explore how to manage backups within Firestore.

**Listing Backups**

To list available backups, you can use the `gcloud alpha firestore backups list` command. This command can be useful for gaining insights into the status of your backups:

```shell
gcloud alpha firestore backups list --format="table(name, database, state)"
```

The `--format="table(name, database, state)"` flag structures the output in a more readable format. You can also filter backups by location using the `--location` flag:

```shell
gcloud alpha firestore backups list --location=*LOCATION* --format="table(name, database, state)"
```

Replace `*LOCATION*` with the name of your Firestore location.

**Describing a Backup**

For a detailed view of a specific backup, utilize the `gcloud alpha firestore backups describe` command:

```shell
gcloud alpha firestore backups describe --location=*LOCATION* --backup=*BACKUP_ID*
```

- `*LOCATION*` denotes the location of the database.
- `*BACKUP_ID*` represents the ID of the backup. You can find this ID by listing all backups.

**Deleting a Backup**

To delete a backup, use the `gcloud alpha firestore backups delete` command. Be cautious when deleting backups, as they cannot be recovered:

```shell
gcloud alpha firestore backups delete --location=*LOCATION* --backup=*BACKUP_ID*
```

- `*LOCATION*` signifies the location of the database.
- `*BACKUP_ID*` denotes the ID of the backup. You can find this ID by listing all backups.

It's essential to note that Firestore stores metadata associated with backups and backup schedules for a database. This metadata is retained until all backups for the database either expire or are deleted.

**Restoring Data from a Database Backup**

Restoring data from a backup allows you to write the data from the backup into a new Firestore database. To initiate a restore operation, use the `gcloud alpha firestore databases restore` command:

```shell
gcloud alpha firestore databases restore --source-backup=projects/*PROJECT_ID*/locations/*LOCATION*/backups/*BACKUP_ID* --destination-database='*DATABASE_ID*'
```

- `*PROJECT_ID*` should be replaced with your project ID.
- `*LOCATION*` is the location of the database backup and the location for the new database created for the restored data.
- `*BACKUP_ID*` is the ID of the backup. You can find this ID when you list all backups.
- `*DATABASE_ID*` represents the ID for the new database. You cannot use an ID that is already in use, and the database mode will match that of the backup.


# Firestore Point-in-Time Recovery (PITR)

**Introduction**

Firestore's Point-in-Time Recovery (PITR) feature offers a safety net for your data, protecting it against accidental deletions or erroneous writes. With PITR, you can maintain consistent versions of your documents from past timestamps, allowing you to recover your data to a specific point in time, seamlessly. In this article, we'll explore the benefits of PITR and how to harness its capabilities effectively.

**A Note on Pre-GA Offerings**

Before diving into the specifics of PITR, it's important to mention that this feature is subject to the "Pre-GA Offerings Terms" outlined in the General Service Terms of the [Service Specific Terms](https://cloud.google.com/terms/service-terms#1). Pre-GA features are provided "as is" and may have limited support. To understand the different launch stages, you can refer to the [product launch stages](https://cloud.google.com/products#product-launch-stages) page.

**The Power of Point-in-Time Recovery**

PITR is your guardian against data disasters. It helps you safeguard your data from accidental mishaps such as data deletions or incorrect writes. The key advantage of PITR is that it allows you to recover your data to any point in time within the last 7 days. This means that even if a developer inadvertently pushes incorrect data or deletes essential information, you can turn back the clock and restore your data to a previous state.

It's essential to highlight that for any live database that adheres to Firestore's [Best Practices](https://cloud.google.com/firestore/docs/best-practices), using PITR doesn't impact the performance of read or write operations. It operates seamlessly in the background, ensuring data integrity without causing any slowdowns.

**Understanding the PITR Window**

After enabling PITR, Firestore starts retaining your data within what's known as the "PITR window." This window extends over a 7-day period. The PITR window timeline depends on the enablement status, as follows:

- When PITR is disabled, you can read data starting from one hour before the time of your read request.
- If PITR is enabled within the last 7 days, you can read data from one hour before the moment PITR was enabled.
- In case PITR was enabled more than 7 days ago, you can read data dating back to 7 days before the time of your read request.

Please note that you can't immediately start reading data from 7 days in the past right after enabling PITR. There's an initial one-hour buffer.

In the PITR window, Firestore retains a single version per minute. This means you can read documents at minute granularity using timestamps. In situations where multiple writes occurred for a document, only one version is retained. For example, if a document had multiple writes (v1, v2, ... vk) between timestamps like `2023-05-30 09:00:00 AM` (exclusive) and `2023-05-30 09:01:00 AM` (inclusive), a read request at `2023-05-30 09:01:00 AM` will return the `vk` version of the document.

It's important to note that the 7-day retention period mainly applies to stale read operations. For consistent import or export operations, Firestore supports data up to one hour ago.

**Recovering Data with PITR**

Firestore offers two ways to recover data using PITR:

1. **Recover a Portion of the Database**: This method involves performing a "stale read," where you specify a query condition or use a direct key lookup along with a timestamp from the past. You can then write the results back into the live database. This approach is typically used for precise, surgical operations on your live database. For instance, if you accidentally delete a specific document or make an incorrect update to a subset of data, this method allows you to recover it. For detailed instructions, refer to the [guide on recovering a portion of your database](https://cloud.google.com/firestore/docs/use-pitr#read-pitr).

2. **Recover the Entire Database**: To recover the entire database, you can export it by specifying a timestamp from the past and then import it into a new database. However, it's worth noting that exporting a database can be a time-consuming process, potentially taking several hours. It's essential to be aware that you can only export consistent PITR data where the timestamp is a whole minute timestamp within the past hour but not earlier than the earliestVersionTime. For details on this process, please refer to the guide on [exporting and importing from a consistent PITR version](https://cloud.google.com/firestore/docs/use-pitr#export_and_import_from_a_consistent_pitr_version).

