#
# Validation using null resource. 
# When we want to validate between multiple variables then we can use null_resource to do this. 
#

locals {
  vars_a = "XYZ"
  vars_b = "ABC"
}

resource "null_resource" "check_for_information" {
  count = local.vars_a == local.vars_b ? 0 : "ERROR, vars_a and vars_b CANNOT be same."
}

#
# ┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/null_resource]
# └─▪ tfp
# ╷
# │ Error: Incorrect value type
# │ 
# │   on main.tf line 12, in resource "null_resource" "check_for_information":
# │   12:     count = local.vars_a != local.vars_b ? 0 : "ERROR, vars_a and vars_b CANNOT be same."
# │     ├────────────────
# │     │ local.vars_a is "XYZ"
# │     │ local.vars_b is "XYZ"
# │ 
# │ Invalid expression value: a number is required.