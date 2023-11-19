# Establishing a Datastream from Cloud SQL (MySQL) to BigQuery Through Cloud Auth Proxy

**Work in progress.**

```
[CloudSQL] -- > [Cloud Auth Proxy]      [Datastream] --[connProfile]--> [BigQuery]
                        ^                     |    
                        |                     |
                        \----[privateConn]----/
                        \----[connProfile]----/  
```

Welcome back to our series on datastream workflows! In our [previous article](https://ahmedzbyr.gitlab.io/gcp/datastream_mysql-bq/), we explored the basics of setting up a datastream workflow. Today, we're diving deeper by implementing a datastream from MySQL to BigQuery, utilizing the CloudSQL Proxy. This approach is particularly relevant in scenarios where CloudSQL is confined to a private network, making direct connections via external IP unfeasible. We'll guide you through the process of establishing a secure connection to CloudSQL using a proxy node equipped with the CloudSQL Auth Proxy binary, mirroring a common setup in many organizations where direct access to CloudSQL is restricted.


Below are the steps we will use to setup the Infra for our Datastream CDC Workflow. 

- **Step 1:** Create a BigQuery Dataset for our Destination.
- **Step 2:** Create a Private network for the CloudSQL and GCE instance.
- **Step 3:** Setup the firewall rules required for the network to communicate
- **Step 4:** Create the CloudSQL (MySQL) Instance on the Private network.
- **Step 5:** Create the GCE instance on private network (subnetwork).
- **Step 6:** Create Private connection to GCE proxy node.
- **Step 7:** Create Connection Profile to the Source MySQL using Private connection.
- **Step 8:** Create Connection Profile to the Destination BigQuery.
- **Step 9:** Create a Datastream stream to connection the source and destination.
- **Step 10:**  Insert Data into CloudMySQL.
- **Step 11:**  Verify data on the Destination BigQuery.

## Step 1: Create a BigQuery Dataset for our Destination.

Next, we'll focus on establishing a destination dataset for our data. For our setup, we're selecting the `single_target_dataset` option, which allows us to consolidate all our data into this single dataset.

Important: Keep in mind that when you opt for the `single_target_dataset` configuration, the tables inside this dataset will adopt a naming format that combines the database name with the table name, structured as `databaseName_tableName`.

```hcl
# Resource definition for creating a Google BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  project       = var.project                  # The Google Cloud project ID
  dataset_id    = "datastream_example_dataset" # Unique ID for the BigQuery dataset
  friendly_name = "datastream_example_dataset" # A user-friendly name for the dataset
  description   = "This is a test description" # Description of the dataset's purpose or contents
  location      = "us-east1"                   # The geographic location where the dataset should reside

  # Default expiration time for tables within this dataset (milliseconds)
  default_table_expiration_ms = 3600000 # 1 hour (3600000 milliseconds)

  # Labels for the dataset, useful for categorization or organization within GCP
  labels = {
    type = "datastream" # Example label indicating the dataset's intended for datastream
  }

  # If set to true, this ensures that all contents within the dataset will be deleted upon the dataset's destruction
  delete_contents_on_destroy = true # Use with caution to prevent accidental data loss here this is true for TESTING ONLY
}
```

## Step 2: Create a Private network for the CloudSQL and GCE instance.

1. **VPC Network**: Our next step involves setting up a VPC network, which we will name `private-interconnect`. We'll opt out of the automatic `subnetwork` creation, as our plan is to manually establish a subnet. This subnet will be specifically located in the `us-east1` region, aligning with our targeted regional requirements.

```hcl
# Resource for creating a Google Compute VPC network
resource "google_compute_network" "main" {
  project = var.project            # Project this resource belongs in
  name    = "private-interconnect" # Name of the VPC network

  # Disables automatic subnetwork creation we will create it for specific region below
  auto_create_subnetworks = "false"
}
```


2. **Global Private IP Address**: Allocates a global private IP address with the purpose set for VPC peering and this what we will be using the to setup the CloudSQL (MySQL) instance, This can only be accessed from the Cloud Auth Proxy Node which will be created in the subsequent steps.

```hcl
# Resource for allocating a global private IP address for VPC peering
# Internal IP address ranges that are allocated for services private connection
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project                       # Project this resource belongs in
  name          = "private-interconnect-ip-address" # Name for the global address resource
  purpose       = "VPC_PEERING"                     # Specifies the purpose as VPC Peering
  address_type  = "INTERNAL"                        # Type of address (Internal for VPC peering)
  prefix_length = 24                                # Prefix length of the IP range
  network       = google_compute_network.main.id    # Associates with the created VPC network
}
```

3. **Service Networking Connection**: Establishes a service networking connection with the reserved peering ranges for the purpose of VPC peering, this what we will be using to setup a peering from `"servicenetworking.googleapis.com"` so that we can communicate to the instance on this network.

```hcl
# Resource to establish a service networking connection for VPC peering
resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.id                          # VPC network to which the service connection is made
  service                 = "servicenetworking.googleapis.com"                      # Service to be connected (Service Networking API)
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name] # Uses the reserved global address
}
```

![datastream_pxy_private_interconnect_priv_service_access_service](images/datastream_pxy_private_interconnect_priv_service_access_service.png)

4. **Network Peering Routes Configuration**: Google Cloud VPC Network Peering is a powerful feature that links two Virtual Private Cloud (VPC) networks, allowing resources within each network to interact seamlessly. In our setup, we're utilizing this capability to facilitate communication between the GCE instance and the Cloud SQL instance. Additionally, this setup enables:
   - Communication across all subnets using internal IPv4 addresses.
   - For dual-stack subnets, the ability to communicate via both internal and external IPv6 addresses.

```hcl
# Resource for configuring network peering routes
resource "google_compute_network_peering_routes_config" "peering_routes" {
  project              = var.project                                       # Project this resource belongs in
  peering              = google_service_networking_connection.main.peering # Refers to the peering created in the service networking connection
  network              = google_compute_network.main.name                  # Network in which the routes are configured
  import_custom_routes = true                                              # Allows importing custom routes into the network peering
  export_custom_routes = true                                              # Allows exporting custom routes from the network peering
}
```

![datastream_pxy_private_interconnect_vpc_peering](images/datastream_pxy_private_interconnect_vpc_peering.png)

5. **Subnetwork for Proxy Node**: Creates a subnetwork named `private-interconnect-subnetwork` with a specified IP range, intended for private access and this is the network used for the GCE instance to setup the Cloud SQL Auth Proxy.

```hcl
# Resource definition for a Google Compute Engine subnetwork we will be using this subnet to setup our proxy node.
resource "google_compute_subnetwork" "subnetwork_purpose_private_nat" {
  provider      = google-beta                       # Using beta as the purpose PRIVATE is still in beta.
  project       = var.project                       # Specifies the project ID where the subnetwork will be created
  name          = "private-interconnect-subnetwork" # Sets the name of the subnetwork
  region        = var.region                        # Defines the region where the subnetwork will reside
  ip_cidr_range = "192.168.1.0/24"                  # Determines the IP address range for the subnetwork in CIDR format

  # Sets the purpose of the subnetwork to 'PRIVATE_RFC_1918' which means the subnetwork
  # is intended for use with private Google Access and instances without external IP addresses
  purpose = "PRIVATE"

  # When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.
  private_ip_google_access = true

  # Links this subnetwork to the specified network resource's ID
  network = google_compute_network.main.id
}
```

![datastream_pxy_private_interconnect_nw_subnet](images/datastream_pxy_private_interconnect_nw_subnet.png)

6. **Firewall Rule**: Sets up a firewall rule named `datastream-inbound-connections` to allow inbound connections `"172.31.200.0/29"` on specified ports (`3306`, `5432`) for instances with specific tags.
   1. `172.31.200.0/29` is the datastream private connection CIDR range we will be setting up later on this post.
   2. We are opening ports for MySQL `3306`, PostgreSQL `5432`.  
   3. (Optional) We also have a inbound `ssh` connection to reach the GCE instance over `ssh`. [ **NOTE:** This is optional for testing as in a org environment we would not set a rules `0.0.0.0/0` like we have done here]

```hcl
# Resource for creating a firewall rule for Google Compute Engine which will get requests from datastream private connection.
resource "google_compute_firewall" "main" {
  project = var.project                      # The project ID where the firewall rule will be created
  name    = "datastream-inbound-connections" # Name of the firewall rule
  network = google_compute_network.main.id   # The network to which the rule applies

  # A brief description of the firewall rule
  description = "Creates firewall rule targeting tagged instances"

  # Specifies the rule to allow incoming traffic
  allow {
    protocol = "tcp"              # The protocol for which the rule applies
    ports    = var.ports_to_allow # The port number (MySQL/PostgreSQL default port) to be allowed 
  }

  # The source IP ranges that will be allowed through the firewall
  source_ranges = [var.private_connection_cidr]

  # Targets the rule to instances tagged with these values
  target_tags = ["datastream", "cloud-sql-proxy"]
}

# Resource for creating a firewall rule for Google Compute Engine which will get requests from datastream private connection.
resource "google_compute_firewall" "main" {
  project = var.project                          # The project ID where the firewall rule will be created
  name    = "datastream-inbound-connections-ssh" # Name of the firewall rule
  network = google_compute_network.main.id       # The network to which the rule applies

  # A brief description of the firewall rule
  description = "Creates firewall rule for ssh targeting tagged instances"

  # Specifies the rule to allow incoming traffic
  allow {
    protocol = "tcp" # The protocol for which the rule applies
    ports    = "22"  # ssh to be allowed 
  }

  # The source IP ranges that will be allowed through the firewall
  # This is here for testing and needs to be a specific IP range. 
  source_ranges = "0.0.0.0/0"

  # Targets the rule to instances tagged with these values
  target_tags = ["datastream", "cloud-sql-proxy"]
}
```

![datastream_pxy_private_interconnect_firewall](images/datastream_pxy_private_interconnect_firewall.png)

7. **Setting Up Routing** (Optional): Optional Configuration for Updates: This setup is optional and primarily necessary if the GCE instance requires internet access for updates or software installations.

```hcl
# Resource definition for a Google Compute Engine router
resource "google_compute_router" "router" {
  project = var.project         # The project ID where the router will be created
  name    = "datastream-router" # The name of the router

  # The region where the router will be created, taken from the previously defined subnetwork
  region  = google_compute_subnetwork.subnetwork_purpose_private_nat.region
  network = google_compute_network.main.id # The network ID to which the router belongs

  # BGP configuration block for the router
  bgp {
    asn = 64514 # The Autonomous System Number (ASN) for BGP to use. 
    # This should be a private ASN (64512 - 65534 for 16-bit ASNs)
  }
}
```

![datastream_pxy_cloud_router](images/datastream_pxy_cloud_router.png)

```hcl
# Resource definition for a NAT service on the Google Compute Engine router
resource "google_compute_router_nat" "nat" {
  project = var.project                         # The project ID where the NAT will be created
  name    = "datastream-router-nat"             # The name of the NAT service
  router  = google_compute_router.router.name   # The router name where the NAT will reside
  region  = google_compute_router.router.region # The region of the router

  # NAT IP allocation option set to automatically allocate NAT IPs
  nat_ip_allocate_option = "AUTO_ONLY"

  # Source subnetwork IP ranges to include in NAT. 
  # 'ALL_SUBNETWORKS_ALL_IP_RANGES' indicates that all primary and secondary ranges in all subnetworks in the region are allowed
  # For better router configuration we can setup access to specific subnets as well. 
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Logging configuration block
  log_config {
    enable = true          # If logging should be enabled for the NAT
    filter = "ERRORS_ONLY" # Log level filter, which here is set to log only errors
  }
}
```

![datastream_pxy_cloud_nat](images/datastream_pxy_cloud_nat.png)