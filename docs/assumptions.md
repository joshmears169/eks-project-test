# Assumptions

Region: eu-west-2
AZs: eu-west-2a, eu-west-2b and eu-west-2c
NAT Gateways: 1 in each AZ for resilience (could scale this back to single NAT Gateway if cost was an issue)
Have kept state local for ease, but have included an example remote backend setup using S3 and DynamoDB lock table which is standard in enterprise environments
I have not used the new AWS EKS Capability for ArgoCD as there would be prerequisites that may stop you from deploying this successfully in your environment to see if it deploys properly. But, although its only just been released, I imagine this new feature from AWS will be popular! Instead, for this test, I have used a self-managed ArgoCD installation using Helm to keep it portable. The steps to get this all up and running are outlined in the runbook.md in this folder.