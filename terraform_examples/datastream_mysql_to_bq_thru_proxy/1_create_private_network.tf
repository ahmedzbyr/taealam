# Resource for creating a Google Compute VPC network
resource "google_compute_network" "main" {
  project                 = var.project            # Project this resource belongs in
  name                    = "private-interconnect" # Name of the VPC network
  auto_create_subnetworks = "false"                # Disables automatic subnetwork creation
}

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

# Resource to establish a service networking connection for VPC peering
resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.id                          # VPC network to which the service connection is made
  service                 = "servicenetworking.googleapis.com"                      # Service to be connected (Service Networking API)
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name] # Uses the reserved global address
}

# Resource for configuring network peering routes
resource "google_compute_network_peering_routes_config" "peering_routes" {
  project              = var.project                                       # Project this resource belongs in
  peering              = google_service_networking_connection.main.peering # Refers to the peering created in the service networking connection
  network              = google_compute_network.main.name                  # Network in which the routes are configured
  import_custom_routes = true                                              # Allows importing custom routes into the network peering
  export_custom_routes = true                                              # Allows exporting custom routes from the network peering
}

# Resource definition for a Google Compute Engine subnetwork we will be using this subnet to setup our proxy node.
resource "google_compute_subnetwork" "subnetwork_purpose_private_nat" {
  provider      = google-beta
  project       = var.project                       # Specifies the project ID where the subnetwork will be created
  name          = "private-interconnect-subnetwork" # Sets the name of the subnetwork
  region        = var.region                        # Defines the region where the subnetwork will reside
  ip_cidr_range = "192.168.1.0/24"                  # Determines the IP address range for the subnetwork in CIDR format

  # Sets the purpose of the subnetwork to 'PRIVATE_RFC_1918' which means the subnetwork
  # is intended for use with private Google Access and instances without external IP addresses
  purpose = "PRIVATE"

  private_ip_google_access = true                           # When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.
  network                  = google_compute_network.main.id # Links this subnetwork to the specified network resource's ID
}

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


resource "google_compute_router" "router" {
  project = var.project
  name    = "datastream-router"
  region  = google_compute_subnetwork.subnetwork_purpose_private_nat.region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project
  name                               = "datastream-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
