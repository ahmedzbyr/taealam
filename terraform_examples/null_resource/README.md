# Validation using `null_resource`

The `null_resource` resource implements the standard resource lifecycle but takes no further action. So this can be used to check condition and stop the workflow from moving forward if the conditions are not met. 

This comes in handy when we want to check one or more variables to be of specific value. This cannot be validated in the terraform validation (as we did in the earlier post) in the variables as we can only validate the variable, but cannot check other variables. 

We can use  `count` to do this, since `count` only expects numeric values, we then can pass a string when the conditions are not met. 

**Example:** Lets say we have 2 variables which should never be same then we can check this condition in the `null_resource` and block the workflow. 

```hcl
#
# Validation using null resource. 
# When we want to validate between multiple variables then we can use null_resource to do this. 
#

locals {
  vars_a = "XYZ"
  vars_b = "ABC" 
}

resource "null_resource" "check_for_information" {
    count = local.vars_a != local.vars_b ? 0 : "ERROR, vars_a and vars_b CANNOT be same."
}
```

Here we are checking `local.vars_a != local.vars_b` and they are not same then we set the count to `0`, so the resource will be skipped, else the reource will `ERROR` out with type mismatch as we are passing a string to count `"ERROR, vars_a and vars_b CANNOT be same."`.


Output of this will look as below if the workflow fails. 

```hcl
┌─[ahmedzbyr][Ahmeds-MacBook-Pro][±][master ?:1 ✗][~/work/git_repos/taealam/terraform_examples/null_resource]
└─▪ tfp
╷
│ Error: Incorrect value type
│ 
│   on main.tf line 12, in resource "null_resource" "check_for_information":
│   12:     count = local.vars_a != local.vars_b ? 0 : "ERROR, vars_a and vars_b CANNOT be same."
│     ├────────────────
│     │ local.vars_a is "XYZ"
│     │ local.vars_b is "XYZ"
│ 
│ Invalid expression value: a number is required.
```

So this block the workflow and necessary action can be taken. 