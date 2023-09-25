# Project
variable "project_id" {
  default = "elevated-column-400011"
}

data "google_project" "project" {
  project_id = var.project_id
}

# Creating a RSA key pair to connect to the GCE instance.
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creating an instance. 
resource "google_compute_instance" "main" {
  project             = var.project_id
  machine_type        = "f1-micro"
  name                = "ahmed-instance-1"
  zone                = "us-west1-b"
  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  boot_disk {
    auto_delete = true
    device_name = "ahmed-instance-1"
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230912"
      size  = 10
      type  = "pd-balanced"
    }
    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    subnetwork = "projects/${var.project_id}/regions/us-west1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    # using this for example, use a custom sa here.
    email = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  # This is set to be used so we can login to the node.
  # Format is 
  #     username:public_key
  #
  metadata = {
    "ssh-keys" = "ubuntu:${tls_private_key.main.public_key_openssh}"
  }
}

# Installing nginx on the node which was create above.
# using the private key to connect to the node. 
resource "null_resource" "remote_example" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo apt-get update",
      "sudo mkdir -p /root/.ssh/",
      "sudo ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa <<<y >/dev/null 2>&1",
      "sudo cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys",
      #   "sudo chmod 700 /root/.ssh",
      #   "sudo chmod 600 /root/.ssh/id_rsa",
      #   "sudo chmod 644 /root/.ssh/id_rsa.pub",
      #   "sudo chmod 600 /root/.ssh/authorized_keys",
      "sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin\\ yes/g' /etc/ssh/ssh_config",
      "sudo systemctl restart ssh",
      "sudo apt-get install -y ansible",
      "sudo echo -e '[defaults]\\nhost_key_checking = False' > /etc/ansible/ansible.cfg",
    ]
  }
  connection {
    type        = "ssh"
    host        = google_compute_instance.main.network_interface.0.access_config.0.nat_ip
    user        = "ubuntu"
    private_key = tls_private_key.main.private_key_openssh
  }

  depends_on = [
    google_compute_instance.main
  ]
}
