
- [ Example - Create a connection profile for Oracle database](#example---create-a-connection-profile-for-oracle-database)
  - [Configure a Self-Hosted Oracle Database:](#configure-a-self-hosted-oracle-database)
    - [Step 1: Verify Database Mode](#step-1-verify-database-mode)
    - [Step 2: Define Data Retention Policy](#step-2-define-data-retention-policy)
    - [Step 3: Configure Log File Rotation](#step-3-configure-log-file-rotation)
    - [Step 4: Enable Supplemental Log Data](#step-4-enable-supplemental-log-data)
    - [Step 5: Grant Privileges to User Account](#step-5-grant-privileges-to-user-account)
  - [JSON representation](#json-representation)
  - [ Connectivity Methods](#connectivity-methods)
- [ Example - Create a connection profile for MySQL database](#example---create-a-connection-profile-for-mysql-database)
  - [ Configure a Cloud SQL for MySQL database:](#configure-a-cloud-sql-for-mysql-database)
  - [JSON representation](#json-representation-1)
- [Example - Create a connection profile for Cloud PostgreSQL database](#example---create-a-connection-profile-for-cloud-postgresql-database)
  - [ Configure a Cloud SQL for PostgreSQL database:](#configure-a-cloud-sql-for-postgresql-database)
    - [Enable Logical Replication](#enable-logical-replication)
    - [Create a Publication and a Replication Slot](#create-a-publication-and-a-replication-slot)
  - [Create a Datastream User](#create-a-datastream-user)
  - [JSON representation](#json-representation-2)


##  Example - Create a connection profile for Oracle database

This is an example for oracle self-hosted. Please here for more details for [Amazon RDS Oracle](https://cloud.google.com/datastream/docs/configure-your-source-oracle-database#aurorardsfororacle).

### Configure a Self-Hosted Oracle Database:

This guide outlines the steps to configure a self-hosted Oracle database for Change Data Capture (CDC) using Datastream.

#### Step 1: Verify Database Mode

- Ensure that your Oracle database is running in `ARCHIVELOG` mode. To check, log in to your Oracle database and run the following SQL command:

   ```sql
   SELECT LOG_MODE FROM V$DATABASE;
   ```

  - If the result is `ARCHIVELOG`, proceed to step 2.
  - If the result is `NOARCHIVELOG`, you'll need to enable `ARCHIVELOG` mode for your database. Follow these steps:
    - Run the following commands while logged in as `SYSDBA`:

       ```sql
       SHUTDOWN IMMEDIATE;
       STARTUP MOUNT;
       ALTER DATABASE ARCHIVELOG;
       ALTER DATABASE OPEN;
       ```

    - Note: Enabling `ARCHIVELOG` mode generates archived log files, which consume disk space.

#### Step 2: Define Data Retention Policy

- Define a data retention policy for your database using Oracle Recovery Manager (RMAN) commands:

   ```sql
   TARGET /
   CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 4 DAYS;
   ```

  - The `TARGET /` command starts an RMAN client and connects to the source database.
  - We recommend retaining backups and archive logs for a minimum of 4 days, with 7 days as a recommended duration.
  - Executing this command will restart your database instance to apply the changes.

#### Step 3: Configure Log File Rotation

- Return to the SQL prompt of your database tool and configure the Oracle log file rotation policy. It's advisable to set a maximum log file size of no more than 512MB.

#### Step 4: Enable Supplemental Log Data

- Enable supplemental log data as follows:

  - Start by enabling minimal database-level supplemental logging:

     ```sql
     ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
     ```

  - Next, choose whether to enable logging for specific tables or the entire database:

     To log changes for specific tables, run the following command for each table:

     ```sql
     ALTER TABLE SCHEMA.TABLE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
     ```

    - Replace `SCHEMA` with the schema name and `TABLE` with the table name.

     To replicate most or all tables, enable supplemental log data for the entire database:

     ```sql
     ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
     ```

    - Ensure that the supplemental logging mode is set to `ALL`; it cannot be set to `PK_ONLY`.

#### Step 5: Grant Privileges to User Account

- Grant the necessary privileges to the user account that will be used to connect to your database:

   ```sql
   GRANT EXECUTE_CATALOG_ROLE TO USER_NAME;
   GRANT CONNECT TO USER_NAME;
   GRANT CREATE SESSION TO USER_NAME;
   GRANT SELECT ON SYS.V_$DATABASE TO USER_NAME;
   GRANT SELECT ON SYS.V_$ARCHIVED_LOG TO USER_NAME;
   GRANT SELECT ON SYS.V_$LOGMNR_CONTENTS TO USER_NAME;
   GRANT EXECUTE ON DBMS_LOGMNR TO USER_NAME;
   GRANT EXECUTE ON DBMS_LOGMNR_D TO USER_NAME;
   GRANT SELECT ANY TRANSACTION TO USER_NAME;
   GRANT SELECT ANY TABLE TO USER_NAME;
   ```

  - Replace `USER_NAME` with the name of the user account.
  - If your organization prohibits granting `GRANT SELECT ANY TABLE` permission, refer to the [Oracle CDC section](https://cloud.google.com/datastream/docs/faq#grant-select) of the Datastream FAQ for an alternative solution.
  - For Oracle 12c or newer databases, grant the additional privilege:

     ```sql
     GRANT LOGMINING TO USER_NAME;
     ```

| Field                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Connection profile name | Enter the display name of the connection profile to the source Oracle database. This is used in the connection profile list as well as when an existing connection profile is selected in the creation of a stream.                                                                                                                                                                                                                                          |
| Connection profile ID   | Datastream populates this field automatically based on the connection profile name that you enter. You can keep the ID that's auto-generated or change it.                                                                                                                                                                                                                                                                                                   |
| Region                  | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream can only use connection profiles that are stored in the same region as the stream. Region selection doesn't impact whether Datastream can connect to the source or the destination, but can impact availability if the region experiences downtime.                                                                   |
| Hostname or IP          | Enter a hostname or IP address that Datastream can use to connect to the source Oracle database. If you're using private connectivity to communicate with the source database, then specify the private (internal) IP address for the source database. :books: NOTE: If you're using a reverse proxy for private connectivity, then use the IP address of the proxy. For other connectivity methods, such as IP allowlisting, provide the public IP address. |
| Port                    | Enter the port number that's reserved for the source database (The default port is typically 1521.).                                                                                                                                                                                                                                                                                                                                                         |
| Username                | Enter the username of the account for the source database (for example, ROOT). This is the Datastream user that you created for the database. For more information about creating this user, see Configure your source Oracle database.                                                                                                                                                                                                                      |
| Password                | Enter the password of the account for the source database.                                                                                                                                                                                                                                                                                                                                                                                                   |
| System identifier (SID) | Enter the service that ensures that the source Oracle database is protected and monitored. For Oracle databases, the database service is typically ORCL. For pluggable databases, SID is the pluggable database name.                                                                                                                                                                                                                                        |

### JSON representation

```json
{
  "project": string,
  "display_name": string,
  "connection_profile_id": string,
  "lcoation": string,
  "labels": {
    string: string,
    ...
  },
  "display_name": string,
  "oracle_profile": {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
    "database_service": string,
    "connection_attributes": {
      string: string,
      ...
    }
  }
}
```

###  Connectivity Methods

1. Select a network connectivity method for Datastream from the following options:
   - IP allowlisting
   - Forward-SSH tunnel
   - Private connectivity (VPC peering) **[Recommended for External Sources like `AWS`]**

2. If you choose "**Forward-SSH tunnel**" as the network connectivity method:
   - Enter the hostname or IP address and port of the tunnel host server.
   - Specify the username of the account for the tunnel host server.
   - Select the authentication method for the SSH tunnel, either "Password" or "Private/Public key pair."
   - Provide the password of the account for the bastion host VM (if using Password as the authentication method) or provide a private key (if using Private/Public key pair).
   - Configure the tunnel host to allow incoming connections from the Datastream public IP addresses for the specified region.

3. If you choose "**Private connectivity (VPC peering)**" as the network connectivity method:
   - Establish secure connectivity between Datastream and the source database, either internally within Google Cloud or with external sources connected over VPN or Interconnect.
   - Select a private connectivity configuration from the list if you've created one, containing information for Datastream to communicate with the source database over a private network.
   - If you haven't created a private connectivity configuration, you can create one by clicking "CREATE PRIVATE CONNECTIVITY CONFIGURATION" at the bottom of the drop-down list and following the steps to create it.

##  Example - Create a connection profile for MySQL database

Certainly, here are the points summarizing the provided information:

###  Configure a Cloud SQL for MySQL database:

- **Enable binary logging:**
  - To enable binary logging for Cloud SQL for MySQL, follow the instructions in [Enabling point-in-time recovery](https://cloud.google.com/sql/docs/mysql/backup-recovery/pitr).

- **Create a Datastream user:**
  - To create a Datastream user for Cloud SQL, execute the following MySQL commands:

```sql
CREATE USER 'datastream'@'%' IDENTIFIED BY '[YOUR_PASSWORD]';
GRANT REPLICATION SLAVE, SELECT, REPLICATION CLIENT ON *.* TO 'datastream'@'%';
FLUSH PRIVILEGES;
```

| Field                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Connection profile name | Enter the display name of the connection profile to the source MySQL database. This is used in the connection profile list as well as when an existing connection profile is selected in the creation of a stream.                                                                                                                                                                                                                                           |
| Connection profile ID   | Datastream populates this field automatically based on the connection profile name that you enter. You can keep the ID that's auto-generated or change it.                                                                                                                                                                                                                                                                                                   |
| Region                  | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream can only use connection profiles that are stored in the same region as the stream. Region selection doesn't impact whether Datastream can connect to the source or the destination, but can impact availability if the region experiences downtime.                                                                   |
| Hostname or IP          | Enter a hostname or IP address that Datastream can use to connect to the source MySQL database. If you're using private connectivity to communicate with the source database, then specify the private (internal) IP address for the source database. If you're using a reverse proxy for private connectivity, then use the IP address of the proxy. For other connectivity methods, such as IP allowlisting or Forward-SSH, provide the public IP address. |
| Port                    | Enter the port number that's reserved for the source database (The default port is typically 3306.).                                                                                                                                                                                                                                                                                                                                                         |
| Username                | Enter the username of the account for the source database (for example, root). This is the Datastream user that you created for the database. For more information about creating this user, see Configure a source MySQL database.                                                                                                                                                                                                                          |
| Password                | Enter the password of the account for the source database.                                                                                                                                                                                                                                                                                                                                                                                                   |

### JSON representation

```json
{
  "project": string,
  "display_name": string,
  "connection_profile_id": string,
  "lcoation": string,
  "labels": {
    string: string,
    ...
  },
  "display_name": string,
  "mysql_profile":   {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
    "ssl_config": {
      {
      "client_key": string,
      "client_key_set": boolean,
      "client_certificate": string,
      "client_certificate_set": boolean,
      "ca_certificate": string,
      "ca_certificate_set": boolean
      }
    }
  }
}
```

## Example - Create a connection profile for Cloud PostgreSQL database

###  Configure a Cloud SQL for PostgreSQL database:

The following sections cover how to configure a Cloud SQL for PostgreSQL database.

#### Enable Logical Replication

1. Navigate to Cloud SQL in the Google Cloud console.
2. Open the Cloud SQL instance and click **EDIT**.
3. Scroll down to the **Flags** section.
4. Click **ADD FLAG**.
5. Choose the `cloudsql.logical_decoding` flag from the drop-down menu.
6. Set the flag value to `on`.
7. Click **SAVE** to save your changes. You'll need to restart your instance to update it with the changes.
8. After your instance has been restarted, confirm your changes under **Database flags** on the **Overview** page.

#### Create a Publication and a Replication Slot

**1. Connect to the database as a user with sufficient privileges to create a replication slot. If not, run the following command to grant replication privileges to a user:**

```sql
ALTER USER USER_NAME WITH REPLICATION;
```

Replace `USER_NAME` with the name of the user to whom you want to grant replication privileges. If your current user can't run the command, reconnect to the database with the default `postgres` username and execute the command.

**2. Create a publication for the changes in the tables that you want to replicate.**

- To include changes from all tables in the database, use the following SQL command:

```sql
CREATE PUBLICATION PUBLICATION_NAME FOR ALL TABLES;
```

- It's recommended to create a publication that includes only the changes from the tables you want to replicate. This allows Datastream to read only the relevant data. To create such a publication, use this command:

     ```sql
     CREATE PUBLICATION PUBLICATION_NAME FOR TABLE SCHEMA1.TABLE1, SCHEMA2.TABLE2;
     ```

     Replace:
  - `PUBLICATION_NAME`: The name of your publication, which you'll need when creating a stream in the Datastream stream creation wizard.
  - `SCHEMA`: The name of the schema containing the table.
  - `TABLE`: The name of the table you want to replicate.

**3. Create a replication slot with the following SQL command:**

   ```sql
   SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT(REPLICATION_SLOT_NAME, 'pgoutput');
   ```

   Replace `REPLICATION_SLOT_NAME` with the name of your replication slot, which you'll need when creating a stream in the Datastream stream creation wizard. Ensure that the replication slot name is unique for each stream replicating from this database.

### Create a Datastream User

1. Connect to the database using a PostgreSQL client.

2. Execute the following PostgreSQL command to create a Datastream user:

   ```sql
   CREATE USER USER_NAME WITH REPLICATION LOGIN PASSWORD 'USER_PASSWORD';
   ```

   Replace:

   - `USER_NAME`: The name of the Datastream user you want to create.
   - `USER_PASSWORD`: The login password for the Datastream user you want to create.

3. Grant the following privileges to the user you created:

   ```sql
   GRANT SELECT ON ALL TABLES IN SCHEMA SCHEMA_NAME TO USER_NAME;
   GRANT USAGE ON SCHEMA SCHEMA_NAME TO USER_NAME;
   ALTER DEFAULT PRIVILEGES IN SCHEMA SCHEMA_NAME GRANT SELECT ON TABLES TO USER_NAME;
   ```

   Replace:

   - `SCHEMA_NAME`: The name of the schema to which you want to grant privileges.
   - `USER_NAME`: The user to whom you want to grant privileges.

This guide provides step-by-step instructions for configuring a Cloud SQL for PostgreSQL database to enable logical replication and set up a Datastream user for replication purposes.

### JSON representation

```json
{
  "project": string,
  "display_name": string,
  "connection_profile_id": string,
  "lcoation": string,
  "labels": {
    string: string,
    ...
  },
  "display_name": string,
  "postgres_profile":   {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
    "database": string
  }
}
```
