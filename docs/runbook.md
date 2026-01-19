NOTE: Can take up to 20 mins to create and up to 5 mins to destroy AWS infrastructure.

Push the zipped repo to your GitHub

Update the terraform.tfvars.example to the values you need and rename to terraform.tfvars.

Pay close attention to the bootstrap_admin_principal_arn variable as that needs to be the role you are using for your AWS account which will be given EKS Cluster Admin permissions.

Run Terraform in your AWS account

Terraform outputs: clusterName/region/vpcId/albControllerRoleArn and others. Save these somewhere handy so you can enter them in the YAML manifests next.

Now run the following command:
aws eks update-kubeconfig --region eu-west-2 --name orders-platform-test-eks

To test you can use kubectl on your EKS cluster now, use the following command to list your nodes:
kubectl get nodes

Edit your "fork":

kubernetes/argocd/values/alb-controller-values.yaml with the outputted values from the terraform run
kubernetes/cluster_addons/aws_load_balancer_controller/serviceaccount.yaml with the ALB IRSA role arn outputted from the terraform run too.

and ALL mentions of "repoURL" and "targetRevision" to point to your repo fork (can use find and replace to save some time!)

Now we have to do a one-time installation of ArgoCD manually with Helm.
First create the namespace:
kubectl create namespace argocd

Then install ArgoCD with Helm:
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd `
  --namespace argocd

Wait a few seconds and then check the pods are running with:
kubectl -n argocd get pods -w

Run port forwarding command:
kubectl port-forward service/argocd-server -n argocd 8080:443
Then check you can visit the UI at http://localhost:8080

To login you can use admin for username and for password you can retrieve this by running the following command:
kubectl -n argocd get secret argocd-initial-admin-secret `
  -o jsonpath="{.data.password}" | %{ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }

Then, if you have updated your alb-controller-values.yaml and kubernetes/cluster_addons/aws_load_balancer_controller/serviceaccount.yaml with the terraform outputted values, you can commit and push the changes to the branch ArgoCD will track.

Then, bootstrap ArgoCD to sync your repo which will result in ArgoCD managing updates via GitOps from this point forward:

kubectl apply -n argocd -f kubernetes/argocd/apps/root-app.yaml
kubectl -n argocd annotate application root-app argocd.argoproj.io/refresh=hard --overwrite

Then see if your apps are appearing:
kubectl -n argocd get applications

You should see the following apps:
root-app
baseline
cluster-addons
metrics-server
aws-load-balancer-controller
apps

Validate each wave installed correctly:
kubectl get ns
kubectl -n ops get role,rolebinding

Check the metrics-server
kubectl top nodes
kubectl top pods -A

Check the AWS Load Balancer Controller is running:
kubectl -n kube-system get deploy aws-load-balancer-controller
kubectl get ingressclass

kubectl -n apps get deploy,svc,ingress -o wide
kubectl -n apps describe ingress order-processor
You should see an ALB provisioned in your AWS account in the EC2 console under Load Balancers.
Address should eventually show an ALB DNS name.

You can then test the application is working by curling the ALB DNS name:
curl http://<ALB_DNS_NAME>
or visiting the address name in your browser.

For this example, as we are using just the plain NGINX image, you should see the "Welcome to nginx!" screen.

If you need to refresh an application after making changes to the YAML manifests, you can use the following command:
kubectl -n argocd annotate application aws-load-balancer-controller argocd.argoproj.io/refresh=hard --overwrite

You can also check the logs of an application's pods by running a command like the below:
kubectl -n kube-system logs deploy/aws-load-balancer-controller -f --tail=80
Remove the -f if you don't want to see the live logs.

If you need to restart a deployment you can do a rolling update which will force new pods to be spun up and the old ones spun down. This is great for if you have updated IRSA permissions, have new config/values or just need to force a fresh reconcile:
kubectl -n kube-system rollout restart deploy/aws-load-balancer-controller

