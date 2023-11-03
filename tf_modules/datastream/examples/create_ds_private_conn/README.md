# Example to Create Private Connection

This is an example to create a simple private connection. 

## Overview

Private connectivity configurations are a crucial component of secure data transfer in Google Cloud Datastream. These configurations contain vital information that Datastream utilizes to establish a secure connection with a data source over a private network. This network can be either internal within the Google Cloud environment or external, connected through VPN or Interconnect.

The key to this secure communication is the use of a Virtual Private Cloud (VPC) peering connection. This networking feature establishes a connection between two Virtual Private Clouds (VPCs), allowing the exchange of data using private IPv4 addresses. To ensure smooth operation, it is essential to provide the private IP addresses during the setup of your private connectivity configuration, as Datastream does not support Domain Name System (DNS) resolution within private connections.

More Information: [Before you Begin](../../datastream_private_connection/README.md#before-you-begin)