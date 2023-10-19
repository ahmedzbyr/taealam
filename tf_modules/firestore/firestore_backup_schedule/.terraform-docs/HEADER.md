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

