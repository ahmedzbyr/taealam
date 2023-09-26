Using Ansible in the init script of a Google Compute Engine (GCE) instance can be a powerful way to automate the configuration and setup of your virtual machines. Here are the general steps to achieve this:

### 1. Setting Up Instance

Before we start we need to setup a GCE instance. We can setup the instance using terraform. And while we are doing so we can setting the configuration on for the node to make sure we have all the components installed. We can do this in 2 ways running an `init` script or using `remote-exec` to execute commands we when to run when the node starts.

To demonstrate the use of `remote-exec` we will be using that in this example. But we can use the `init` script as well.
In the setup we are initially setting a `ssh` configuration to use `private` keys to access the node. This will also help us to communicate with the service with ansible.

Here is a snippet on what it would look like.

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

Next, we install the `ansible` package.

```shell
apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install -y ansible
echo -e '[defaults]\\nhost_key_checking = False' > /etc/ansible/ansible.cfg
```

By this point we have the node ready to execute `ansible`.

### 2. Getting Ansible Deployment Files Ready

Write an Ansible playbook that defines the tasks you want to execute on the GCE instance. For example, you might want to install software, configure system settings, or deploy applications. Save this playbook as a YAML file.

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

This `yaml` installs `nginx` on the node.

### 3. Copying Ansible Deployment

We do this using the `provisioner` called `file`. This will help us to copy the files from the terraform directory to the `gce` node.

Here is snippet on how it looks like.

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

Here `source` is a file or directory, `destination` is where we want on the node. `connection` to connect to the node.
We are using `metadata` configuration to setup the ssh and copy it using that, we are using the same connect for `remote-exec`.

### 4. Terraform Script

1. The script begins with defining variables, including the `project_id`, which should be replaced with your specific project ID.
2. It generates an RSA key pair using the `tls_private_key` resource, which will be used for SSH access to the GCE instance.
3. The `google_compute_instance` resource defines the GCE instance configuration, including its machine type, name, zone, boot disk, networking details, and service account settings.
4. Within the `metadata` section, it specifies SSH keys for secure access to the instance.
5. Using the `provisioner "file"`, it copies the Ansible deployment files from your local machine to the GCE instance.
6. The `null_resource` named `remote_example` uses a `provisioner "remote-exec"` to execute a series of shell commands on the GCE instance. These commands perform various tasks, including setting up SSH keys, installing Ansible, and configuring Ansible settings.
7. The `depends_on` attribute ensures that the `null_resource` provisioning only starts after the GCE instance is created.

This Terraform script provisions a GCE instance, prepares it for Ansible deployment, and installs the necessary software for further configuration.

```hcl
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
