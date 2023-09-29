build {
  sources = ["sources.googlecompute.create-new-custom-image"]
  provisioner "shell" {
    script = "./scripts/startup.sh"
  }
}