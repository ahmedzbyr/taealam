---
toc: true
toc_label: "Contents"
toc_icon: "cog"
title: Automating GCE Image Creation with Packer
category: ["GCP"]
tags: ["terraform", "packer", "gce"]
header:
  {
    overlay_image: /assets/images/unsplash-image-65.jpg,
    og_image: /assets/images/unsplash-image-65.jpg,
    caption: "Photo credit: [**Unsplash**](https://unsplash.com)",
  }
---

Ensuring consistency and streamlining infrastructure provisioning is crucial for effective cloud management. Creating custom virtual machine (VM) images on Google Compute Engine (GCE) is a powerful way to achieve this. In this guide, we'll explore how to automate the image creation process using a powerful tool called `packer`.

**Example**: You can find sample code for this guide on [GitHub](https://github.com/ahmedzbyr/taealam/tree/master/terraform_examples/packer_gce).

## Prerequisites

Before we dive into the automation process, make sure you have the following prerequisites in place:

1. **Google Cloud Platform (GCP) Account**: You should have a GCP account and a project set up.
2. **Packer**: Install Packer on your local machine. You can download it from the official website: [Packer Downloads](https://www.packer.io/downloads).

## Overview

Here's a high-level overview of the steps we'll follow to automate image creation with Terraform and Packer:

1. **Configure Packer**: Create a Packer template in HashiCorp Configuration Language (HCL) format (e.g., `googlecompute.pkr.hcl`) that specifies how your image should be built. This includes details like the source VM instance, image family, and additional provisioning steps.
2. **Build the Custom Image**: Use Packer to build a custom image based on your template (e.g., `build.pkr.hcl`). Packer automates the process of provisioning, configuring, and capturing the image.
3. **Clean Up**: Packer will automatically destroy the temporary VM instance created for image building.
4. **Use Your Custom Image**: Deploy new VMs from your custom image as needed.

### What We'll Accomplish in This Post

In this guide, we'll create a `googlecompute` HCL file for creating the image, a build file to execute a script on the image, and a script to set up an application on the image. This new image will have all the required configurations and applications, making it ideal for spinning up new GCE instances.

## What Is Packer?

[Packer](https://www.packer.io/) is an open-source tool for creating identical machine images for multiple platforms from a single source configuration. It is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management tools like Chef or Puppet; instead, it can use these tools to install software onto the image.

## Why Use Packer?

Packer addresses the challenge of creating machine images in a more streamlined and automated way, offering several benefits:

- **Super Fast Infrastructure Deployment**: Packer images enable you to launch fully provisioned and configured machines in seconds, significantly reducing provisioning times for both production and development environments.

- **Multi-Provider Portability**: Packer creates identical images for multiple platforms, allowing you to run your application in various environments such as AWS, OpenStack, or desktop virtualization solutions like VMware or VirtualBox.

- **Improved Stability**: Packer installs and configures all the software for a machine during image creation. This means that any issues or bugs in your configuration scripts are caught early in the process.

- **Greater Testability**: After building a machine image, you can quickly launch and test it to ensure that everything is working as expected. This confidence extends to any future instances launched from the image.

Packer modernizes the process of creating and managing machine images, unlocking new possibilities and improving operational agility.

## Step 1: Creating the `googlecompute` HCL Source File

Below is an example `googlecompute` HCL file for creating a custom GCE image. This file specifies various parameters, including the project ID, region, zone, source image, disk size, machine type, image family, and more.

```hcl
packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

# Name: ubuntu-2004-focal-v20230918
# Project: ubuntu-os-cloud
# Family: ubuntu-2004-lts

source "googlecompute" "create-new-custom-image" {
  project_id = "my-project-id" # The project ID that will be used to launch instances and store images.
  region     = "us-east1"               # The region in which to launch the instance. Defaults to the region hosting the specified zone.
  zone       = "us-east1-b"             # The zone in which to launch the instance used to create the image. Example: "us-central1-a"

  # The source image family to use to create the new image from.
  # The image family always returns its latest image that is not deprecated. Example: "ubuntu-2004-lts".
  source_image_family     = "ubuntu-2004-lts"
  source_image_project_id = ["ubuntu-os-cloud"]

  # Key/value pair labels to apply to the launched instance.
  labels = {
    "my_custom_image" = "imager_version_1"
  }

  # Key/value pair labels to apply to the created image.
  image_labels = {
    "my_custom_image" = "imager_version_1"
  }

  # The Google Compute subnetwork id or URL to use for the launched instance.
  #     Only required if the network has been created with custom subnetting.
  #
  # Note: the region of the subnetwork must match the region or zone in which the VM is launched.
  #     If the value is not a URL, it will be interpolated to `projects/((network_project_id))/regions/((region))/subnetworks/((subnetwork))`
  #
  subnetwork = "projects/elevated-column-400011/regions/us-east1/subnetworks/default"


  disk_size    = 20              # The size of the disk in GB. This defaults to 20, which is 20GB.
  disk_type    = "pd-standard"   # Type of disk used to back your instance, like pd-ssd or pd-standard. Defaults to pd-standard.
  machine_type = "n1-standard-1" # The machine type. Defaults to "e2-standard-2".

  # The name of the image family to which the resulting image belongs.
  #     You can create disks by specifying an image family instead of a specific image name.
  #     The image family always returns its latest image that is not deprecated.
  image_family = "my-custom-image-v${formatdate("DDMMYYYY", timestamp())}"

  image_description = "Custom image"                                            # The description of the resulting image.
  image_name        = "my-custom-image-v${formatdate("DDMMYYYY", timestamp())}" # The unique name of the resulting image. Defaults to packer-{{timestamp}}.
  instance_name     = "my-custom-image-v${formatdate("DDMMYYYY", timestamp())}" #

  # The username to connect to SSH with. Required if using SSH.
  ssh_username = "ubuntu"

}
```

## Step 2: Build File to Execute a Script on the Image

In this step, we'll create a build file that specifies the sources to be built and the script to execute on the image. The script will set up the required applications and configurations.

```hcl
build {
  sources = ["source.googlecompute.create-new-custom-image"]

  provisioner "shell" {
    script = "./scripts/startup.sh" # Path to your provisioning script.
  }
}
```

## Step 3: Running the Packer Commands

You can execute various Packer commands to manage the image creation process. Here are some essential commands:

- `packer init .`: Use this command to download Packer plugin binaries. It's the first step when working with a new or existing template.
- `packer validate .`: Validate the syntax and configuration of your Packer template. This command ensures that your template is valid.
- `packer build .`: Execute this command to start the image creation process based on your Packer template. Packer will automate provisioning, configuration, and image capture.

## Output

When you run the `packer build` command, you'll see an output similar to the following:

```shell
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/packer_gce]
└─▪ packer init .
Installed plugin github.com/hashicorp/googlecompute v1.1.1 in "/Users/ahmedzbyr/.config/packer/plugins/github.com/hashicorp/googlecompute/packer-plugin-googlecompute_v1.1.1_x5.0_darwin_amd64"
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/packer_gce]
└─▪ packer validate .
The configuration is valid.
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/packer_gce]
└─▪ packer build .
googlecompute.create-new-custom-image: output will be in this color.

==> googlecompute.create-new-custom-image: Checking image does not exist...
==> googlecompute.create-new-custom-image: Creating temporary RSA SSH key for instance...
==> googlecompute.create-new-custom-image: no persistent disk to create
==> googlecompute.create-new-custom-image: Using image: ubuntu-2004-focal-v20230918
==> googlecompute.create-new-custom-image: Creating instance...
    googlecompute.create-new-custom-image: Loading zone: us-east1-b
    googlecompute.create-new-custom-image: Loading machine type: n1-standard-1
    googlecompute.create-new-custom-image: Requesting instance creation...
    googlecompute.create-new-custom-image: Waiting for creation operation to complete...
    googlecompute.create-new-custom-image: Instance has been created!
==> googlecompute.create-new-custom-image: Waiting for the instance to become running...
    googlecompute.create-new-custom-image: IP: 34.74.212.5
==> googlecompute.create-new-custom-image: Using SSH communicator to connect: 34.74.212.5
==> googlecompute.create-new-custom-image: Waiting for SSH to become available...
==> googlecompute.create-new-custom-image: Connected to SSH!
==> googlecompute.create-new-custom-image: Provisioning with shell script: ./scripts/startup.sh
    googlecompute.create-new-custom-image: Installing Apache Webserver.
    googlecompute.create-new-custom-image: Reading package lists...
    googlecompute.create-new-custom-image: Building dependency tree...
    googlecompute.create-new-custom-image: Reading state information...
    googlecompute.create-new-custom-image: The following packages were automatically installed and are no longer required:
    googlecompute.create-new-custom-image:   libatasmart4 libblockdev-fs2 libblockdev-loop2 libblockdev-part-err2
    googlecompute.create-new-custom-image:   libblockdev-part2 libblockdev-swap2 libblockdev-utils2 libblockdev2
    googlecompute.create-new-custom-image:   libmbim-glib4 libmbim-proxy libmm-glib0 libnspr4 libnss3 libnuma1
    googlecompute.create-new-custom-image:   libparted-fs-resize0 libqmi-glib5 libqmi-proxy libudisks2-0 libxmlb2
    googlecompute.create-new-custom-image:   usb-modeswitch usb-modeswitch-data
    googlecompute.create-new-custom-image: Use 'sudo apt autoremove' to remove them.
    googlecompute.create-new-custom-image: The following additional packages will be installed:
    googlecompute.create-new-custom-image:   apache2-bin apache2-data apache2-utils libapr1 libaprutil1
    googlecompute.create-new-custom-image:   libaprutil1-dbd-sqlite3 libaprutil1-ldap libjansson4 liblua5.2-0 ssl-cert
    googlecompute.create-new-custom-image: Suggested packages:
    googlecompute.create-new-custom-image:   apache2-doc apache2-suexec-pristine | apache2-suexec-custom www-browser
    googlecompute.create-new-custom-image:   openssl-blacklist
    googlecompute.create-new-custom-image: The following NEW packages will be installed:
    googlecompute.create-new-custom-image:   apache2 apache2-bin apache2-data apache2-utils libapr1 libaprutil1
    googlecompute.create-new-custom-image:   libaprutil1-dbd-sqlite3 libaprutil1-ldap libjansson4 liblua5.2-0 ssl-cert
    googlecompute.create-new-custom-image: 0 upgraded, 11 newly installed, 0 to remove and 0 not upgraded.
    googlecompute.create-new-custom-image: Need to get 1867 kB of archives.
    googlecompute.create-new-custom-image: After this operation, 8098 kB of additional disk space will be used.
    ...
    ...
    googlecompute.create-new-custom-image: Enabling conf serve-cgi-bin.
    googlecompute.create-new-custom-image: Enabling site 000-default.
    googlecompute.create-new-custom-image: Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service → /lib/systemd/system/apache2.service.
    googlecompute.create-new-custom-image: Created symlink /etc/systemd/system/multi-user.target.wants/apache-htcacheclean.service → /lib/systemd/system/apache-htcacheclean.service.
    googlecompute.create-new-custom-image: Processing triggers for ufw (0.36-6ubuntu1.1) ...
    googlecompute.create-new-custom-image: Processing triggers for systemd (245.4-4ubuntu3.22) ...
    googlecompute.create-new-custom-image: Processing triggers for man-db (2.9.1-1) ...
    googlecompute.create-new-custom-image: Processing triggers for libc-bin (2.31-0ubuntu9.9) ...
==> googlecompute.create-new-custom-image: Deleting instance...
    googlecompute.create-new-custom-image: Instance has been deleted!
==> googlecompute.create-new-custom-image: Creating image...
==> googlecompute.create-new-custom-image: Deleting disk...
    googlecompute.create-new-custom-image: Disk has been deleted!
Build 'googlecompute.create-new-custom-image' finished after 2 minutes 24 seconds.

==> Wait completed after 2 minutes 24 seconds

==> Builds finished. The artifacts of successful builds are:
--> googlecompute.create-new-custom-image: A disk image was created: my-custom-image-v29092023
```

This output represents the successful creation of your custom GCE image. You can now use this image to deploy new VM instances with your desired configurations and applications.

By automating GCE image creation with Packer and Terraform, you can achieve greater consistency and efficiency in managing your cloud infrastructure. This approach is particularly valuable when you need to maintain multiple VM instances with consistent setups.
