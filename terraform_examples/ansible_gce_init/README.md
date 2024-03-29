# Google Compute Engine (GCE) Instance with Ansible

Using Ansible within the initialization script of a Google Compute Engine (GCE) instance can streamline and automate the configuration and setup of your virtual machines. In this guide, we will walk through the steps to achieve this process.

Example: [Sample Code on Github](https://github.com/ahmedzbyr/taealam/tree/master/terraform_examples/ansible_gce_init)

## 1. Setting Up the GCE Instance

Before diving into Ansible automation, you need to provision a GCE instance. This can be accomplished using Terraform. While setting up the instance, you can configure it to ensure that all necessary components are installed and configured. There are two primary approaches for this: running an `init` script or using `remote-exec` to execute commands when the node starts.

In this example, we'll demonstrate using `remote-exec`. However, you can also use an `init` script.

### SSH Configuration

Begin by configuring SSH to use private keys for secure access to the GCE instance. This step is crucial for communication with the service via Ansible. Below is a snippet of what this configuration looks like:

```shell
#!/bin/bash
mkdir -p /root/.ssh/
ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa <<<y >/dev/null 2>&1
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/authorized_keys
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/ssh_config
systemctl restart ssh
```

### Installing Ansible

Next, install the `ansible` package on the GCE instance:

```shell
apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install -y ansible
echo -e '[defaults]\\nhost_key_checking = False' > /etc/ansible/ansible.cfg
```

By this point, your GCE node is prepared to execute Ansible commands.

## 2. Creating an Ansible Playbook

Now, it's time to write an Ansible playbook that defines the tasks you want to execute on the GCE instance. These tasks can include installing software, configuring system settings, or deploying applications. Save this playbook as a YAML file. Here's a simple example that installs the `nginx` web server:

```yaml
---
- name: Configure GCE Instance
  hosts: all
  tasks:
    - name: Ensure a package is installed
      apt:
        name: nginx
        state: present
```

## 3. Copying Ansible Deployment Files

To copy your Ansible deployment files to the GCE instance, utilize the `provisioner` called `file`. This provisioner facilitates the transfer of files from your Terraform directory to the GCE node. Here's an example of how it looks:

```hcl
provisioner "file" {
    source      = "./ansible_deployment"
    destination = "/root/"
    connection {
      type        = "ssh"
      host        = google_compute_instance.main.network_interface.0.access_config.0.nat_ip
      user        = "root"
      private_key = tls_private_key.main.private_key_openssh
    }
  }
```

In this snippet, `source` points to the local file or directory, `destination` specifies where to place the files on the GCE node, and `connection` defines the SSH connection details.

## 4. Terraform Script

Here we orchestrates the GCE instance provisioning and Ansible setup. It involves several steps:

1. Defining variables such as `project_id` (replace it with your project ID).
2. Generating an RSA key pair for SSH access (`tls_private_key` resource).
3. Configuring the GCE instance (`google_compute_instance` resource) with settings like machine type, zone, and service account.
4. Setting up SSH access via metadata.
5. Using `provisioner "file"` to copy Ansible deployment files.
6. Leveraging a `null_resource` with `provisioner "remote-exec"` to run various shell commands for Ansible setup.
7. Ensuring proper dependencies between resources.

This script fully prepares the GCE instance for Ansible automation.

```hcl
# Project
variable "project_id" {
  default = "my-project-id"
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
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230918"
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
    "ssh-keys" = "root:${tls_private_key.main.public_key_openssh}"
  }

  provisioner "file" {
    source      = "./ansible_deployment"
    destination = "/root/"
    connection {
      type        = "ssh"
      host        = google_compute_instance.main.network_interface.0.access_config.0.nat_ip
      user        = "root"
      private_key = tls_private_key.main.private_key_openssh
    }
  }
}

# Installing nginx on the node which was create above.
# using the private key to connect to the node.
resource "null_resource" "remote_example" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "mkdir -p /root/.ssh/",
      "ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa <<<y >/dev/null 2>&1",
      "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
      "chmod 700 /root/.ssh",
      "chmod 600 /root/.ssh/id_rsa",
      "chmod 644 /root/.ssh/id_rsa.pub",
      "chmod 600 /root/.ssh/authorized_keys",
      "sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/ssh_config",
      "systemctl restart ssh",
      "apt-add-repository ppa:ansible/ansible -y",
      "apt-get update",
      "apt-get install -y ansible",
      "echo -e '[defaults]\\nhost_key_checking = False' > /etc/ansible/ansible.cfg",
    ]
  }
  connection {
    type        = "ssh"
    host        = google_compute_instance.main.network_interface.0.access_config.0.nat_ip
    user        = "root"
    private_key = tls_private_key.main.private_key_openssh
  }

  depends_on = [
    google_compute_instance.main
  ]
}
```

### 5. Running Terraform

The `terraform init` command is the first step when working with a Terraform configuration. It initializes a working directory containing Terraform configuration files. It is used to set up the environment and download any necessary plugins or providers.

```shell
terraform init
```

The `terraform plan`` command helps you preview the changes that Terraform will make to your infrastructure. It doesn't make any actual changes; it's a dry run to show you what will happen when you apply the configuration.

```shell
terraform plan
```

The `terraform apply` command is used to apply the changes specified in your Terraform configuration to your infrastructure. This command is responsible for creating, updating, or deleting resources as needed to match the desired state.

```shell
terraform apply
```

Output

```shell
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master U:1 ✗][~/work/git_repos/taealam/terraform_examples/ansible_gce_init]
└─▪ tfa
data.google_project.project: Reading...
data.google_project.project: Read complete after 1s [id=projects/elevated-column-400011]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # google_compute_instance.main will be created
  + resource "google_compute_instance" "main" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + enable_display       = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "f1-micro"
      + metadata             = (known after apply)
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "ahmed-instance-1"
      + project              = "my-project-id"
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + zone                 = "us-west1-b"

      + boot_disk {
          + auto_delete                = true
          + device_name                = "ahmed-instance-1"
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230918"
              + labels = (known after apply)
              + size   = 10
              + type   = "pd-balanced"
            }
        }

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_ip                  = (known after apply)
          + stack_type                  = (known after apply)
          + subnetwork                  = "projects/elevated-column-400011/regions/us-west1/subnetworks/default"
          + subnetwork_project          = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = "PREMIUM"
            }
        }

      + scheduling {
          + automatic_restart   = true
          + on_host_maintenance = "MIGRATE"
          + preemptible         = false
          + provisioning_model  = "STANDARD"
        }

      + service_account {
          + email  = "816777602913-compute@developer.gserviceaccount.com"
          + scopes = [
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring.write",
              + "https://www.googleapis.com/auth/service.management.readonly",
              + "https://www.googleapis.com/auth/servicecontrol",
              + "https://www.googleapis.com/auth/trace.append",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = true
          + enable_vtpm                 = true
        }
    }

  # null_resource.remote_example will be created
  + resource "null_resource" "remote_example" {
      + id = (known after apply)
    }

  # tls_private_key.main will be created
  + resource "tls_private_key" "main" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 4096
    }

Plan: 3 to add, 0 to change, 0 to destroy.
tls_private_key.main: Creating...
tls_private_key.main: Creation complete after 2s [id=dec1eea15df87a888f93e47567d7896e1a96fffb]
google_compute_instance.main: Creating...
google_compute_instance.main: Still creating... [10s elapsed]
google_compute_instance.main: Creation complete after 13s [id=projects/elevated-column-400011/zones/us-west1-b/instances/ahmed-instance-1]
null_resource.remote_example: Creating...
null_resource.remote_example: Provisioning with 'remote-exec'...
null_resource.remote_example (remote-exec): Connecting to remote host via SSH...
null_resource.remote_example (remote-exec):   Host: 104.196.251.234
null_resource.remote_example (remote-exec):   User: root
null_resource.remote_example (remote-exec):   Password: false
null_resource.remote_example (remote-exec):   Private key: true
null_resource.remote_example (remote-exec):   Certificate: false
null_resource.remote_example (remote-exec):   SSH Agent: true
null_resource.remote_example (remote-exec):   Checking Host Key: false
null_resource.remote_example (remote-exec):   Target Platform: unix
...
...
null_resource.remote_example (remote-exec):   Host: 104.196.251.234
null_resource.remote_example (remote-exec):   User: root
null_resource.remote_example (remote-exec):   Password: false
null_resource.remote_example (remote-exec):   Private key: true
null_resource.remote_example (remote-exec):   Certificate: false
null_resource.remote_example (remote-exec):   SSH Agent: true
null_resource.remote_example (remote-exec):   Checking Host Key: false
null_resource.remote_example (remote-exec):   Target Platform: unix
null_resource.remote_example: Still creating... [40s elapsed]
null_resource.remote_example (remote-exec): Connected!
null_resource.remote_example (remote-exec): 0% [Working]
...
...
null_resource.remote_example (remote-exec):  ansible
null_resource.remote_example: Still creating... [3m50s elapsed]
null_resource.remote_example: Creation complete after 3m56s [id=1933123675171073589]
```

### 6. Running the Playbook on the Node

#### Logging into the Node

You can log in to your virtual machine instance using the `gcloud compute ssh` command. Replace `<INSTANCE_NAME>`, `<PROJECT_ID>`, and `<ZONE>` with your specific values.

Command:

```shell
gcloud compute ssh <INSTANCE_NAME> --project <PROJECT_ID> --zone <ZONE>
```

Example:

```shell
gcloud compute ssh ahmed-instance-1 --project elevated-column-400011 --zone us-west1-b
```

#### Testing the Setup

After logging in, you can test your setup by running a few commands. Follow these steps:

1. Switch to the root user for administrative access:

```shell
ahmed@ahmed-instance-1:~$ sudo su
root@ahmed-instance-1:~#
```

2. Navigate to the directory where your Ansible deployment files are located:

```shell
root@ahmed-instance-1:~# cd /root/ansible_deployment/
```

3. Use Ansible to perform a ping test on all hosts specified in your inventory file (`hosts`):

```shell
root@ahmed-instance-1:~/ansible_deployment# ansible -i hosts all -m ping
```

If successful, you should see an output like this:

```shell
localhost | SUCCESS => {
      "ansible_facts": {
         "discovered_interpreter_python": "/usr/bin/python3"
      },
      "changed": false,
      "ping": "pong"
}
```

#### Running the Playbook

Finally, to apply your Ansible playbook and automate the desired configurations, use the `ansible-playbook` command. Make sure to specify your playbook's main YAML file (e.g., `main.yml`) and the inventory file (e.g., `hosts_file`):

```shell
ansible-playbook -i hosts_file main.yml
```

This command will execute the playbook and carry out the defined tasks on your target nodes as specified in the playbook.
