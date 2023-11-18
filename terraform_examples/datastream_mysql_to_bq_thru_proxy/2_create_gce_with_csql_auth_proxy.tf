# Resource for creating a Google service account
resource "google_service_account" "main" {
  project      = var.project                                                       # Project ID where the service account will be created
  account_id   = "datastream-sa"                                                   # Unique ID for the service account
  display_name = "Custom service account for datastream for Cloud SQL Proxy node." # Display name for the service account
}

# Resource for assigning an IAM role to a service account in a Google Cloud project
resource "google_project_iam_member" "main" {
  project = var.project # The project ID where the IAM role should be assigned

  # The IAM role to be assigned to the service account
  # This is required to grants permissions for managing Cloud SQL resources, 
  # by running the cloud auth proxy command. Else we get an NOT AUTHORIZED error from CloudSQL.
  role = "roles/cloudsql.editor"

  # The member to whom the role is assigned
  # In this case, it's the email of the previously created service account
  member = "serviceAccount:${google_service_account.main.email}"
}


# Data source to retrieve available compute zones in a specified region
data "google_compute_zones" "get_avail_zones_from_region" {
  project = var.project # Project ID
  region  = var.region  # Region to fetch the compute zones from
}

# Resource for creating a Google Compute Engine instance
resource "google_compute_instance" "main" {
  project      = var.project                   # Project ID where the instance will be created
  name         = "datastream-cloud-auth-proxy" # Name of the compute instance
  machine_type = "n2-standard-2"               # Machine type for the instance

  # Selects the first available zone from the fetched compute zones
  zone = data.google_compute_zones.get_avail_zones_from_region.names[0]
  tags = ["datastream", "cloud-sql-proxy"] # Tags to identify and categorize the instance

  # Configuration for the boot disk of the instance
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Operating system image for the boot disk
      labels = {
        type = "datastream" # Label for categorizing the disk
      }
    }
  }

  # Network interface configuration, attaching the instance to the our subnetwork created earlier.
  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.subnetwork_purpose_private_nat.self_link
  }

  # Metadata to describe the instance's purpose and use
  metadata = {
    purpose = "datastream"
    use     = "cloud-sql-proxy"
  }

  # Startup script to install and run Cloud SQL Proxy
  # https://cloud.google.com/sql/docs/mysql/connect-auth-proxy#start-proxy
  # https://stackoverflow.com/a/62478143 <- Need to make use of this here, so that it is moved to systemd
  metadata_startup_script = <<-EOF
    echo -e "Downloading cloud-sql-proxy script...";
    echo -e "----------------------------------";
    curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/${var.cloud_sql_proxy_version}/cloud-sql-proxy.linux.amd64; 
    echo -e "Update permissions on the script.";
    chmod +x cloud-sql-proxy; 
    echo -e "Running the script to connection \"${google_sql_database_instance.main.connection_name}\" node";
    ./cloud-sql-proxy --address 0.0.0.0  --port 3306 --private-ip ${google_sql_database_instance.main.connection_name} 
    EOF 

  # Service account configuration for the instance
  service_account {
    email  = google_service_account.main.email # Email of the created service account
    scopes = ["cloud-platform"]                # Scope specifying the instance should have access to all Cloud Platform services
  }
}
