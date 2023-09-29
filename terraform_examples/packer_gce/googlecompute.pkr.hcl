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