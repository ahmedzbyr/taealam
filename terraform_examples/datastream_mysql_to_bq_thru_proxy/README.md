# Establishing a Datastream from Cloud SQL (MySQL) to BigQuery (Private Connections)

Work in progress.

- Create a private network for the CloudSQL
- Setup peering on the network so that the node can connect to the CloudSQL (MySQL) server. 
- Create CloudSQL server on the new private network
  - Setup user
  - Setup database
- Create a GCE instance on the default network and setup Cloud Auth Proxy on the node. 
  - We might have to setup firewall to install the client packages on the node. 
  - Test the connection from the GCE to the MySQL instance. 