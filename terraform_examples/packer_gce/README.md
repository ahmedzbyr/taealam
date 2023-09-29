# Setting up GCE Images using Packer

Creating custom virtual machine (VM) images on Google Compute Engine (GCE) can be a powerful way to ensure consistency and streamline your infrastructure provisioning. In this guide, we'll explore how to automate the image creation process using two powerful tools: Terraform and Packer.

Example: [Sample Code on Github](https://github.com/ahmedzbyr/taealam/tree/master/terraform_examples/ansible_gce_init)

## Prerequisites

Before we begin, make sure you have the following prerequisites:

1. **Google Cloud Platform (GCP) Account**: You should have a GCP account and a project set up.
2. **Terraform**: Install Terraform on your local machine. You can download it from the official website: [Terraform Downloads](https://www.terraform.io/downloads.html).
3. **Packer**: Install Packer on your local machine. You can download it from the official website: [Packer Downloads](https://www.packer.io/downloads).

## Overview

Here's a high-level overview of the steps we'll follow to automate image creation with Terraform and Packer:

1. **Create a Custom VM Instance**: Use Terraform to define and provision a VM instance on GCE. This instance will serve as the basis for your custom image.
2. **Configure Packer**: Create a Packer template HCL `googlecompute.pkr.hcl` file that specifies how your image should be built. This includes details like the source VM instance, image family, and additional provisioning steps.
3. **Build the Custom Image**: Use Packer to build a custom image based on your template `build.pkr.hcl`. Packer will automate the process of provisioning, configuring, and capturing the image.
4. **Clean Up**: Packer will automatically destroy the temporary VM instance created for image building.
5. **Use Your Custom Image**: Deploy new VMs from your custom image as needed.

### What are we doing this post?

1. Create a `googlecompute` hcl file which will create the image.
2. build file to execute a script oon the image
3. Script to setup application on the image.

## What is Packer?

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef or Puppet. In fact, when building images, Packer is able to use tools like Chef or Puppet to install software onto the image.

## Why Use Packer?

Pre-baked machine images have a lot of advantages, but most have been unable to benefit from them because images have been too tedious to create and manage. There were either no existing tools to automate the creation of machine images or they had too high of a learning curve. The result is that, prior to Packer, creating machine images threatened the agility of operations teams, and therefore aren't used, despite the massive benefits.

Packer changes all of this. Packer automates the creation of any type of machine image. It embraces modern configuration management by encouraging you to use a framework such as Chef or Puppet to install and configure the software within your Packer-made images.

In other words: Packer brings pre-baked images into the modern age, unlocking untapped potential and opening new opportunities.

## Advantages of Using Packer

Super fast infrastructure deployment. Packer images allow you to launch completely provisioned and configured machines in seconds, rather than several minutes or hours. This benefits not only production, but development as well, since development virtual machines can also be launched in seconds, without waiting for a typically much longer provisioning time.

Multi-provider portability. Because Packer creates identical images for multiple platforms, you can run production in AWS, staging/QA in a private cloud like OpenStack, and development in desktop virtualization solutions such as VMware or VirtualBox. Each environment is running an identical machine image, giving ultimate portability.

Improved stability. Packer installs and configures all the software for a machine at the time the image is built. If there are bugs in these scripts, they'll be caught early, rather than several minutes after a machine is launched.

Greater testability. After a machine image is built, that machine image can be quickly launched and smoke tested to verify that things appear to be working. If they are, you can be confident that any other machines launched from that image will function properly.

Packer makes it extremely easy to take advantage of all these benefits.

## Step 1: Creating the `hcl` source file.

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
  project_id = "elevated-column-400011" # The project ID that will be used to launch instances and store images.
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

## Step 2. Build file to execute a script oon the image

This file contains the dources to be build and the script which needs to be executed on the image, once the script is executed successfully a new fresh image is created with the include configurations, applications in the script provided.

Now the new image will have all the required configuration and this can then be used to build new GCE instance with.

```hcl
build {
  sources = ["sources.googlecompute.create-new-custom-image"]
  provisioner "shell" {
    script = "./scripts/startup.sh"
  }
}
```

## Step 3. Running the `packer` commands

There are few command which we can execute

- `packer init .`
- `packer validate .`
- `packet fmt -recursive`
- `packer build`

```shell
$ packer
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           build image(s) from template
    console         creates a console for testing variable interpolation
    fix             fixes templates from old versions of packer
    fmt             Rewrites HCL2 config files to canonical format
    hcl2_upgrade    transform a JSON template into an HCL2 configuration
    init            Install missing plugins or upgrade plugins
    inspect         see components of a template
    validate        check that a template is valid
    version         Prints the Packer version
```

## Output

This is a sample output for the build.

### `init`

The `packer init` command is used to download Packer plugin binaries. This is the first command that should be executed when working with a new or existing template. This command is always safe to run multiple times. Though subsequent runs may give errors, this command will never delete anything.

```shell
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/packer_gce]
└─▪ packer init .
Installed plugin github.com/hashicorp/googlecompute v1.1.1 in "/Users/ahmedzbyr/.config/packer/plugins/github.com/hashicorp/googlecompute/packer-plugin-googlecompute_v1.1.1_x5.0_darwin_amd64"
```

### `validate`

The `packer validate` Packer command is used to validate the syntax and configuration of a template. The command will return a zero exit status on success, and a non-zero exit status on failure.

```shell
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/packer_gce]
└─▪ packer validate .
The configuration is valid.
```

### `build`

The `packer build` command takes a template and runs all the builds within it in order to generate a set of artifacts. The various builds specified within a template are executed in parallel, unless otherwise specified. And the artifacts that are created will be outputted at the end of the build.

```shell
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
