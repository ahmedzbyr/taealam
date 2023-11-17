module "create_private_connection_to_instance" {
  source                = "git::https://github.com/ahmedzbyr/taealam.git///tf_modules/datastream/datastream_private_connection"
  project               = var.project                           # Project where the connection profile will be created
  display_name          = "datastream-mysql-private-connection" # Display name for the connection profile
  location              = var.region                            # Location of the connection profile
  private_connection_id = "datastream-mysql-private-connection" # Unique identifier for the connection profile

  labels = {
    key = "datastream"
  }

  vpc_peering_config = {
    vpc    = data.google_compute_network.main.id # VPC network to peer with
    subnet = var.private_connection_cidr         # IP range for the subnet
  }
}


# Resource for creating a firewall rule in Google Compute Engine
resource "google_compute_firewall" "main" {
  project = var.project                         # The project ID where the firewall rule will be created
  name    = "datastream-inbound-connections"    # Name of the firewall rule
  network = data.google_compute_network.main.id # The network to which the rule applies

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


module "create_connection_profile_mysql" {
  source                = "git::https://github.com/ahmedzbyr/taealam.git//tf_modules/datastream/datastream_connection_profile"
  project               = var.project                              # Project where the connection profile will be created
  display_name          = "datastream-connection-csql-proxy-mysql" # Display name for the connection profile
  location              = var.region                               # Location of the connection profile
  connection_profile_id = "datastream-connection-csql-proxy-mysql" # Unique identifier for the connection profile

  labels = {
    key = "datastream"
  }

  mysql_profile = {
    hostname = google_compute_instance.main.network_interface.0.network_ip # (Required) Hostname for the MySQL connection.
    username = var.user                                                    # (Required) Username for the MySQL connection.
  }

  # Private connection to use.
  private_connectivity = module.create_private_connection_to_instance.this_private_connection_id

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    mysql_profile = {
      password = random_string.random.result
    }
  }
}
