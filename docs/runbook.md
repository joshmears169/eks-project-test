Push the zipped repo to your GitHub

Update the terraform.tfvars.example to the values you need and rename to terraform.tfvars. Don't worry about commiting it as it is ignored in the .gitignore file.

Run Terraform in your AWS account

Terraform outputs: clusterName/region/vpcId/roleArn and others

Edit your "fork":

kubernetes/argocd/values/alb-controller-values.yaml with the outputted values from the terraform run

and ALL mentions of "repoURL" and "targetRevision" to point to your repo fork (can use find and replace to save some time!)

Apply root-app