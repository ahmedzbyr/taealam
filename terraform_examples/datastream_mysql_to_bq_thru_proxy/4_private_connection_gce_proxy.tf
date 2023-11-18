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
    vpc    = google_compute_network.main.id # VPC network to peer with
    subnet = var.private_connection_cidr    # IP range for the subnet
  }
}
