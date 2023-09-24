# Harnessing the Power of `null_resource` with `local-exec` and `remote-exec` in Terraform

Terraform, a widely adopted Infrastructure as Code (IaC) tool, offers a rich array of resources and provisioners for efficiently managing and configuring infrastructure. Among these resources, the `null_resource` stands out as a versatile and potent tool that empowers you to execute custom code during Terraform's apply phase. In this blog post, we'll delve into the capabilities of the `null_resource` and explore how it can be harnessed alongside the `local-exec` and `remote-exec` provisioners to execute commands either on your local workstation or remotely on a target resource.

In a previous article, we discussed the use of the `null_resource` for validation purposes ([read it here](https://ahmedzbyr.gitlab.io/gcp/terraform-validation-using-null-res/)). In this post, we'll expand on its functionality and explore additional possibilities with the `null_resource`.

## What is `null_resource`?

The `null_resource` in Terraform is a resource that doesn't correspond to any real infrastructure element. Instead, it serves as a trigger for executing arbitrary actions, making it a valuable resource for performing tasks beyond the typical infrastructure provisioning process.

### Using `null_resource` with `local-exec` Provisioner

The `local-exec` provisioner enables you to run commands locally on your workstation when Terraform is applying changes. This can be useful for tasks like setting up local configurations, generating files, or running tests.

Here's an example of how to use `null_resource` with `local-exec`:

```hcl
resource "null_resource" "local_example" {
  provisioner "local-exec" {
    command = "echo 'Hello, Terraform!'"
  }
}
```

:books: In this example, upon applying the Terraform configuration, the `echo 'Hello, Terraform!'` command will be executed on the system where the Terraform commands are run. This execution location depends on the context in which you run the Terraform script. For instance, if you're running Terraform within a Jenkins pod, the command will execute within the pod's environment. Alternatively, it might run on your local workstation if you execute the Terraform script there.

### Using `null_resource` with `remote-exec` Provisioner

The `remote-exec` provisioner allows you to run commands on remote resources, such as virtual machines or cloud instances, after they have been created. This is particularly useful for configuring and provisioning software on remote servers.

Here's an example of how to use `null_resource` with `remote-exec`:

```hcl
# Project
variable "project_id" {
  default = "elevated-rows-400011"
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
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
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
```

In this example, following the creation of an AWS EC2 instance (`aws_instance.example`), we employ a `null_resource` along with a `remote-exec` provisioner. This provisioner facilitates SSH access to the instance and subsequently executes commands to update the package repository and install Nginx. It's important to note that the `remote-exec` provisioner runs within the context of the target resource instance.

> :books: **NOTE:** Remember to customize the `connection` block with the appropriate SSH connection details for your target resource.

### Output

This is the output generated after configuring and installing Nginx using the terraform above.

```hcl
Plan: 1 to add, 0 to change, 1 to destroy.
null_resource.remote_example: Destroying... [id=432198320028627343]
null_resource.remote_example: Destruction complete after 0s
null_resource.remote_example: Creating...
null_resource.remote_example: Provisioning with 'remote-exec'...
null_resource.remote_example (remote-exec): Connecting to remote host via SSH...
null_resource.remote_example (remote-exec):   Host: 33.83.59.25
null_resource.remote_example (remote-exec):   User: ubuntu
null_resource.remote_example (remote-exec):   Password: false
null_resource.remote_example (remote-exec):   Private key: true
null_resource.remote_example (remote-exec):   Certificate: false
null_resource.remote_example (remote-exec):   SSH Agent: true
null_resource.remote_example (remote-exec):   Checking Host Key: false
null_resource.remote_example (remote-exec):   Target Platform: unix
null_resource.remote_example (remote-exec): Connected!
null_resource.remote_example (remote-exec): 0% [Working]
null_resource.remote_example (remote-exec): Get:1 https://packages.cloud.google.com/apt google-compute-engine-bullseye-stable InRelease [5146 B]
...
...
null_resource.remote_example (remote-exec): Upgrading binary: nginx
null_resource.remote_example (remote-exec): .
null_resource.remote_example (remote-exec): Setting up nginx (1.18.0-6.1+deb11u3) ...
null_resource.remote_example (remote-exec): Processing triggers for man-db (2.9.4-2) ...
null_resource.remote_example (remote-exec): Processing triggers for libc-bin (2.31-13+deb11u6) ...
null_resource.remote_example: Creation complete after 14s [id=6433984879233046743]
```

## Conclusion

The `null_resource` in Terraform is a powerful tool for extending your infrastructure provisioning process. When combined with `local-exec` and `remote-exec` provisioners, you gain the flexibility to execute commands both locally and remotely as part of your infrastructure deployment.

Whether you're setting up local configurations or automating the setup of remote resources, the `null_resource` and provisioners can streamline your infrastructure management workflow in Terraform.

So, go ahead and leverage the full potential of `null_resource` in your Terraform projects to automate tasks and enhance your infrastructure provisioning process.
