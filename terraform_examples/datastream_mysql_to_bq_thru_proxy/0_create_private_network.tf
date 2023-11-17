# Resource for creating a Google Compute VPC network
resource "google_compute_network" "main" {
  project                 = var.project            # Project this resource belongs in
  name                    = "private-interconnect" # Name of the VPC network
  auto_create_subnetworks = "false"                # Disables automatic subnetwork creation
}

# Resource for allocating a global private IP address for VPC peering
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
