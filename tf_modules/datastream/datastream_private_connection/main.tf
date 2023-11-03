# Create a Google Cloud Datastream private connection resource.
resource "google_datastream_private_connection" "main" {
  project               = var.project               # Project where the private connection is created.
  private_connection_id = var.private_connection_id # Unique identifier for the private connection.
  display_name          = var.display_name          # Display name for the private connection.
  location              = var.location              # Location where the private connection is located.
  labels                = var.labels                # Custom labels associated with the private connection.

  # Define VPC peering configuration for the private connection.
  vpc_peering_config {
    vpc    = var.vpc_peering_config.vpc    # ID or self_link of the VPC to peer with.
    subnet = var.vpc_peering_config.subnet # ID or self_link of the subnet within the VPC.
  }
}


