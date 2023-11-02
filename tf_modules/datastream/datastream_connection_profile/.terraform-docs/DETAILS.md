
##  Example - Create a connection profile for Oracle database

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
