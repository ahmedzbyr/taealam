# Terraform Validations

Validations are a great way to capture errors before we start creating plan for the infrastructure.
Some of the issues might also get affect further down the line during apply causing unnecessary issue to the infrastructure.

Below are few of the validations which can help during the terraform module creation.
This give a overview of what we can do to validate and block any issues.

## IP Address validation for a variable

Here we are check the IP address to be of the format `xxx.xxx.xxx.xxx`.
First `{3}` set can take

**Accept IP Address**

```
127.0.0.1
192.168.1.1
192.168.1.255
255.255.255.255
0.0.0.0
1.1.1.01
```

**Reject IP String**

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

Validating cron schdule timer.

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

##  Checking for keys in a map

Check the keys present on the map.

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

##  Validating list of options for a string variable

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

There are many function which are available in terraform which can be used to make the module handle different senarios. 
- [Terraform Functions](https://developer.hashicorp.com/terraform/language/functions)