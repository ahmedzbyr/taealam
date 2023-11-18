# Establishing a Datastream from Cloud SQL (MySQL) to BigQuery (Private Connections)

Work in progress.

- Create a private network for the CloudSQL and GCE Instance. 
- Setup peering on the network so that the node can connect to the CloudSQL (MySQL) server.
- Create CloudSQL server on the new private network
  - Setup user
  - Setup database
- Create a GCE instance on the default network and setup Cloud Auth Proxy on the node.
  - We might have to setup firewall to install the client packages on the node.
  - Test the connection from the GCE to the MySQL instance.




## Create a Private Network for the CloudSQL and GCE Instance

1. **VPC Network**: This will create a VPC network named `private-interconnect` without automatic subnetwork creation.
2. **Global Private IP Address**: Allocates a global private IP address with the purpose set for VPC peering.
3. **Service Networking Connection**: Establishes a service networking connection with the reserved peering ranges for the purpose of VPC peering.
4. **Network Peering Routes Configuration**: Configures importing and exporting of custom routes in network peering.
5. **Subnetwork for Proxy Node**: Creates a subnetwork named `private-interconnect-subnetwork` with a specified IP range, intended for private access.
6. **Firewall Rule**: Sets up a firewall rule named `datastream-inbound-connections` to allow inbound connections on specified ports for instances with specific tags.

