**Deployment Approach**

I’ve used the approach commonly used in enterprise Kubernetes platforms by separating infrastructure provisioning from in-cluster configuration and application delivery. Terraform is used to build the AWS layer (VPC, EKS, IAM/OIDC, node groups, logging), whist Kubernetes manifests/Helm are used for the cluster layer (namespaces, RBAC, service accounts, controllers/add-ons) which have a higher frequency of deployments by the app teams. This separation matches how larger organisations typically split ownership between platform and application teams, and it reduces operational risk by reducing the blast radius and separating concerns meaning that each team can arrange and do their own releases with their own approval/change processes.

This model also improves reliability and maintainability over time. Kubernetes resources are quite ephemeral compared to longer standing infrastructure that Terraform would more commonly manage, and managing them exclusively through Terraform can create noisy drift and difficult dependencies during applies. By treating Terraform as the source of truth for the platform foundation and using Kubernetes-native delivery (YAML/Helm, and GitOps with ArgoCD in this example) for what runs on the platform, changes become easier to review, test, and roll back with a clear audit trail. This also fits with common platform engineering practices where developers should not have to worry about traditional infrastructure and should be able to just deploy their app. In my current role I have also built out an IDP using Backstage to help with this developer self-service delivery pattern that is becoming more popular in the Platform Engineering space.

**Addons**

EKS managed add-ons (CNI/CoreDNS/kube-proxy/ebs-csi) are provisioned via Terraform as part of the EKS control plane lifecycle. Higher-level in-cluster add-ons (logging, ingress/aws-load-balancer, autoscaling controllers) are managed declaratively via GitOps (ArgoCD/Helm) to align with Kubernetes application lifecycle management, continuous reconciliation, and safe rollback.

**Achieving availability of up to 250 pods even after an AZ failure**

To achieve the requirement of being able to run up to 250 pods even after an AZ failure, I have configured the EKS cluster with the following considerations:

1. **Multi-AZ Node Groups**: The EKS cluster is set up with worker nodes distributed across three Availability Zones (eu-west-2a, eu-west-2b, eu-west-2c). This distribution ensures that if one AZ goes down, the remaining AZs can still handle the workload.

2. **Sufficient Node Capacity**: The node groups are sized to ensure that the combined capacity of the nodes in the remaining AZs can accommodate at least 250 pods. This involves calculating the maximum number of pods that can run on each node based on the instance type (m6i.2xlarge) and ensuring enough nodes are provisioned. 

To calculate the number of nodes required, I ran the following command to check the pods allocatable per node:

kubectl get nodes -o custom-columns=NAME:.metadata.name,PODS_ALLOCATABLE:.status.allocatable.pods

NAME                                        PODS_ALLOCATABLE
ip-10-0-52-235.eu-west-2.compute.internal   58
ip-10-0-62-144.eu-west-2.compute.internal   58
ip-10-0-64-179.eu-west-2.compute.internal   58
ip-10-0-74-150.eu-west-2.compute.internal   58
ip-10-0-85-17.eu-west-2.compute.internal    58
ip-10-0-86-139.eu-west-2.compute.internal   58

So 58 pods can be put on each node. 

Minus the daemonset pods per node which after running the following command was 6:
kubectl get ds -A

So if we lose an AZ, that's a third of our capcity we lose and therefore we have to be able to run 250 pods on 2 AZs. Going for around 0.8 utilisation as a target, gives us the following numbers:

(58 - 4) = 54 pods per node
250 / (54 x 0.8)
= 6 nodes needed after an AZ failure (rounded up from 5.78)

Therefore, I have configured the EKS cluster with a total of 9 nodes (3 nodes per AZ) to ensure that even if one AZ fails, the remaining 6 nodes can handle the workload of 250 pods with some buffer for scheduling and any overheads.

So: 

min = 9
desired = 9
max = 15 (gives room to burst for reschedules during upgrades)

3. **Potential CPU and Mem Constraints**

CPU and Mem of the m6i.2xlarge won't be a constraint, pods per node will constrain before that. Therefore, we will go with the above recommendations for number of nodes.
