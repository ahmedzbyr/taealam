# Terraform Workflow Validation with `null_resource`

When working with Terraform, it's crucial to ensure that your infrastructure follows certain conditions or constraints. While Terraform provides validation mechanisms for variables, sometimes you need to perform more complex checks involving multiple variables. This is where the `null_resource` comes into play as a powerful tool for workflow validation.

##  What is the `null_resource`?

The `null_resource` in Terraform implements the standard resource lifecycle, but unlike other resources, it takes no further action. Instead, it serves as a control mechanism that allows you to perform custom logic or checks within your Terraform code. This makes it an excellent choice for validating conditions and preventing the workflow from proceeding if those conditions are not met.

##  Use Cases for Validation

Let's consider a scenario where you want to validate certain conditions between two or more variables. While Terraform does provide variable validation mechanisms, they are limited to individual variables. You cannot directly check relationships or conditions between different variables using Terraform's built-in validation.

Here's an example: You have two variables, `vars_a` and `vars_b`, and you want to ensure that they are never set to the same value. This kind of validation cannot be achieved using Terraform's standard variable validation. However, you can easily accomplish this with the `null_resource`.

```hcl
locals {
  vars_a = "XYZ"
  vars_b = "ABC"
}

resource "null_resource" "check_for_information" {
  count = local.vars_a != local.vars_b ? 0 : 1
}
```

In this example, we are checking if `local.vars_a` is not equal to `local.vars_b`. If they are not the same, the `count` attribute is set to `0`, effectively skipping the `null_resource`. However, if the condition is met (i.e., `local.vars_a` is equal to `local.vars_b`), Terraform will raise an error with a clear message: "ERROR, vars_a and vars_b CANNOT be the same."

##  Practical Implementation

When you run your Terraform workflow, and the `null_resource` encounters an error, it will halt the execution of the workflow, preventing any further Terraform actions. This gives you an opportunity to review the error message and take the necessary corrective actions.

Here's what the output might look like when the workflow fails:

```hcl
Error: Incorrect value type

on main.tf line 12, in resource "null_resource" "check_for_information":
12:     count = local.vars_a != local.vars_b ? 0 : "ERROR, vars_a and vars_b CANNOT be the same."

Invalid expression value: a number is required.
```

As shown in the output, Terraform detects the type mismatch error and provides a clear indication of the problem. You can then investigate the issue, correct it in your Terraform code, and rerun the workflow.

##  Conclusion

The `null_resource` in Terraform is not just an inert placeholder; it's a versatile tool for implementing custom workflow validation logic. By leveraging its capabilities, you can ensure that your infrastructure adheres to specific conditions and constraints, preventing unwanted changes and potential issues in your environment. Whether it's validating variable relationships or performing other custom checks, the `null_resource` empowers you to build robust and reliable Terraform configurations.
