# Effective Terraform Validation Techniques

Validation in Terraform is an essential practice to detect and prevent errors early in the infrastructure provisioning process. By incorporating robust validation checks, you can avoid issues that might otherwise surface during the apply phase, potentially causing disruptions to your infrastructure. In this blog post, we'll explore various validation techniques that can enhance the reliability of your Terraform modules.

##  IP Address Validation for a Variable

Ensuring that an IP address adheres to a specific format is a common validation task. You can use regular expressions to validate IP addresses.

**Acceptable IP Addresses**

```
127.0.0.1
192.168.1.1
192.168.1.255
255.255.255.255
0.0.0.0
1.1.1.01
```

**Invalid IP Strings**

```
30.168.1.255.1
127.1
192.168.1.256
-1.2.3.4
3...3
```

```hcl
variable "ip_address" {
  description = "IP Address to be assigned to the node."
  type        = string
  default     = "192.168.2.1"
  validation {
    condition     = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.ip_address))
    error_message = "IP address is incorrect please correct it."
  }
}
```

##  Cron Schedule Syntax Validation

Validating the syntax of a cron schedule timer is crucial to ensure that your scheduled tasks run as expected.

**Accepts**

```
0 0 * * *
@daily
@every 20h
```

**Rejects**

```
* * * * *
0 * * * 
```

```hcl
variable "cron_schedule" {
    description = "Setting up cron time for the schedular."
    type = string
    default = "0 0 * * *"
    validation {
      condition = can(regex("(@(annually|yearly|monthly|weekly|daily|hourly|reboot))|(@every (\\d+(ns|us|µs|ms|s|m|h))+)|((((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7})", var.cron_schedule))
      error_message = "Please use a valid cron schedule time."
    }
}
```

## Checking for Keys in a Map

Validating the presence of specific keys in a map is essential to ensure that required configuration options are provided.

```hcl
# Validation keys in a map

variable "access_map" {
  description = "Access map for a given resource"
  type        = map(any)
  default = {
    "permission"     = "ADMIN"
    "resource"        = "GCS"
    "service_account" = "sa-permissions@gproject.iam.gserviceaccount.com"
  }
  validation {
    condition     = length(setsubtract(keys(var.access_map), ["permission", "resource", "service_account"])) == 0
    error_message = "ERROR, check access_map We conly accept permission, resource, service_account as the key."
  }
}
```

##  Validating a String Variable Against a List of Options

Sometimes, you need to validate that a string variable matches one of several allowed values.

```hcl
# Validation for list of options for a variable 

variable "location" {
  description = "List of location which can be set for this resource."
  type = string
  default = "US"
  validation {
    condition = contains(["US", "EU", "ASIS"], var.location)
    error_message = "Location can be US, EU, ASIA only"
  }
}
```

##  Leveraging Terraform Functions

Terraform provides a rich set of functions that you can utilize to handle various scenarios and implement custom validations. These functions can significantly enhance your Terraform modules by allowing you to enforce specific conditions and constraints. For more information, refer to the [Terraform Functions documentation](https://developer.hashicorp.com/terraform/language/functions).

By incorporating these validation techniques into your Terraform modules, you can build more robust and reliable infrastructure, reducing the chances of errors and ensuring smooth operations throughout the lifecycle of your resources.
