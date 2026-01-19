# eks-project

Section 1C

The role permissions is written to restrict to a supplied S3 bucket in terraform.tfvars

The role will not deploy until that bucket is deployed so I have written the code but to test you will need to create the s3 bucket first that will contain the orders before deploying terraform.

For now I have commented it out so it doesn't block a Terraform run.