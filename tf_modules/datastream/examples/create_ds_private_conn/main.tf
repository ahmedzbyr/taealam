module "create_private_connection" {
  source                = "../../datastream_private_connection"
  project               = "my-project-id"    # Project where the connection profile will be created
  display_name          = "ahmd-priv-connec" # Display name for the connection profile
  location              = "us-east1"         # Location of the connection profile
  private_connection_id = "ahmd-priv-connec" # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  vpc_peering_config = {
    vpc    = "projects/elevated-column-400011/global/networks/default" # VPC network to peer with
    subnet = "10.142.128.0/29"                                         # IP range for the subnet
  }
}

output "id" {
  value = module.create_private_connection.this_private_connection_id
}

output "name" {
  value = module.create_private_connection.this_private_connection_name
}

output "state" {
  value = module.create_private_connection.this_private_connection_state
}

output "error" {
  value = module.create_private_connection.this_private_connection_error
}
