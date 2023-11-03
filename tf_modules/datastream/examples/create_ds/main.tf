# Fetches the static IP addresses provided by Google Datastream in the specified region and project.
# These static IPs can be used to configure firewall rules for source database access.
data "google_datastream_static_ips" "datastream_ips" {
  location = "us-east1"      # Specify the desired location/region.
  project  = "my-project-id" # Specify your project ID.
}

# Define an output variable to access the list of static IP addresses.
output "ip_list" {
  value = data.google_datastream_static_ips.datastream_ips.static_ips
}

# Response:
# + ip_list = [
#     + "192.27.45.111",
#     + "192.7.216.111",
#     + "192.16.6.111",
#     + "192.76.166.111",
#     + "192.73.30.111",
# ]
#
# These IP addresses can now be used to configure firewall rules for allowing access from Datastream to the source database.
