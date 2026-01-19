# eks-project

Section 1B

The role trust policy is written to restrict assumption to:
- source IP 52.94.236.248/32
- principal ARN arn:aws:iam::1234566789001:user/ops-alice

The role will not deploy until that user is deployed so I have written the code but to test you will need to create the user first before deploying terraform. Then that user would assume the role.

For now I have commented it out so it doesn't block a Terraform run.