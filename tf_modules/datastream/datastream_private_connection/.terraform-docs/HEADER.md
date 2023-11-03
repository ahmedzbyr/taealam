# Configuring Private Connectivity in Google Cloud Datastream

In the module will guide you through the process of creating a private connectivity configuration in Google Cloud Datastream. Private connectivity configurations are essential for secure data communication between Datastream and data sources, whether they are located within Google Cloud or external sources connected via VPN or Interconnect. This communication is facilitated through a Virtual Private Cloud (VPC) peering connection, ensuring the privacy and security of your data.

## Overview

Private connectivity configurations are a crucial component of secure data transfer in Google Cloud Datastream. These configurations contain vital information that Datastream utilizes to establish a secure connection with a data source over a private network. This network can be either internal within the Google Cloud environment or external, connected through VPN or Interconnect.

The key to this secure communication is the use of a Virtual Private Cloud (VPC) peering connection. This networking feature establishes a connection between two Virtual Private Clouds (VPCs), allowing the exchange of data using private IPv4 addresses. To ensure smooth operation, it is essential to provide the private IP addresses during the setup of your private connectivity configuration, as Datastream does not support Domain Name System (DNS) resolution within private connections.

In the following sections, we share information about the inputs to this module and details on how to create a private connection.

##  Before You Begin

Before you proceed with creating a private connectivity configuration, ensure that you have completed the following prerequisites:

1. **VPC Network**: You should have a Virtual Private Cloud (VPC) network in place that can be peered with Datastream's private network. This VPC network must meet specific requirements outlined in the [restrictions](https://cloud.google.com/vpc/docs/using-vpc-peering#restrictions) documentation. If you haven't created the VPC network yet, refer to [Using VPC Network Peering](https://cloud.google.com/vpc/docs/using-vpc-peering) for guidance.

2. **Available IP Range**: Ensure that you have an available IP range with a CIDR block of /29 on the VPC network. This IP range should not overlap with any existing subnets, Private Service Connection pre-allocated IP ranges, or pre-allocated route IP ranges. Datastream utilizes this IP range to create a subnet for communication with the source database. The valid IP ranges you can use are as follows:

   - `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`: Private IP addresses [RFC 1918](https://tools.ietf.org/html/rfc1918).
   - `100.64.0.0/10`: Shared address space [RFC 6598](https://tools.ietf.org/html/rfc6598).
   - `192.0.0.0/24`: IETF protocol assignments [RFC 6890](https://tools.ietf.org/html/rfc6890).
   - `192.0.2.0/24` (TEST-NET-1), `198.51.100.0/24` (TEST-NET-2), `203.0.113.0/24` (TEST-NET-3): Documentation [RFC 5737](https://tools.ietf.org/html/rfc5737).
   - `192.88.99.0/24`: IPv6 to IPv4 relay (deprecated) [RFC 7526](https://tools.ietf.org/html/rfc7526).
   - `198.18.0.0/15`: Benchmark testing [RFC 2544](https://tools.ietf.org/html/rfc2544).

3. **Firewall Rules**: Verify that both Google Cloud and your on-premises/other firewall allow traffic from the selected IP range. If not, you should create an ingress [firewall rule](https://cloud.google.com/vpc/docs/firewalls) that permits traffic on the source database port. Ensure that the IPv4 address range in the firewall rule matches the IP address range allocated when creating the private connectivity resource. Below is an example of how to create the firewall rule using `gcloud`:

   ```shell
   gcloud compute firewall-rules create FIREWALL-RULE-NAME \
       --direction=INGRESS \
       --priority=PRIORITY \
       --network=PRIVATE_CONNECTIVITY_VPC \
       --project=VPC_PROJECT \
       --action=ALLOW \
       --rules=FIREWALL_RULES \
       --source-ranges=IP-RANGE
   ```

   - *FIREWALL-RULE-NAME*: Name of the firewall rule to create.
   - *PRIORITY*: Priority of the rule (integer between 0 and 65535). It should be lower than the block traffic rule's value, if it exists.
   - *PRIVATE_CONNECTIVITY_VPC*: VPC network capable of peering with Datastream's private network, meeting specified restrictions. This is the VPC you specify when creating your private connectivity configuration.
   - *VPC_PROJECT*: Project associated with the VPC network.
   - *FIREWALL_RULES*: List of protocols and ports to which the rule applies (e.g., `tcp:80`). The rule must allow TCP traffic to the IP address and port of the source database or proxy. Consider the actual usage of your configuration, as private connectivity can support multiple databases.
   - *IP-RANGE*: Range of IP addresses used by Datastream to communicate with the source database. This matches the range you indicate in the "Allocate an IP range" field when creating your [private connectivity configuration](https://cloud.google.com/datastream/docs/create-a-private-connectivity-configuration#create-the-configuration).

   Additionally, you may need to create an identical egress firewall rule to allow traffic back to Datastream.

4. **IAM Permissions**: Ensure that you are assigned to a role containing the `compute.networks.list` permission. This permission is necessary to list VPC networks in your project. Refer to the [IAM permissions reference](https://cloud.google.com/iam/docs/permissions-reference) to find roles with this permission.

It's important to note that while private connectivity can be used to connect Datastream to any source, direct VPC network peering is the only supported method for network communication between VPCs. Transitive peering is not supported. If Datastream's peered network isn't the same as the network hosting your source, you're using a fully managed database (e.g., Cloud SQL), or Datastream doesn't run in the region where your source is located, a reverse proxy becomes necessary.

For more detailed information, please visit [Private Connectivity](https://cloud.google.com/datastream/docs/private-connectivity).

If you are using a [Shared VPC](https://cloud.google.com/vpc/docs/shared-vpc), follow these steps:

**On the Service Project**:

1. Enable the [Datastream API](https://console.cloud.google.com/flows/enableapi?apiid=datastream).
2. Obtain the email address associated with the Datastream [service account](https://cloud.google.com/docs/authentication#service-accounts). Datastream service accounts are created when you create a Datastream resource (e.g., connection profile or stream) or a private connectivity configuration. To find the email address, locate the Project number on the Google Cloud console home page. The service account's email address format is `service-[project_number]@gcp-sa-datastream.iam.gserviceaccount.com`.

**On the Host Project**:

1. Grant the `compute.networkAdmin` Identity and Access Management (IAM) role permission to the Datastream service account. If your organization doesn't allow granting this permission,

 create a custom role with the following minimum permissions to create and delete private connection resources:

- `compute.globalAddresses.*`
- `compute.globalOperations.*`
- `compute.networks.*`
- `compute.routes.*`
- `compute.subnetworks.*`

Refer to [Create and Manage Custom Roles](https://cloud.google.com/iam/docs/creating-custom-roles) for more information on custom roles.
