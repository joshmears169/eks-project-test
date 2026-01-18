# GitOps workflow

## Overview

Git is the source of truth for the desired state of the Kubernetes cluster. Terraform for the EKS platform and yaml/Argo CD for the in-cluster elements. ArgoCD continuously reconciles the cluster state to match what is written in Git.

Usually you have two repositories involved, managed by two different teams:

- Application repo: source code for a service (`order-processor` in this test).
- GitOps repo: Kubernetes configuration for environments/clusters (this repo’s `infrasrtucture/` folder).

---

## App Developer Workflow

### 1) Make a code change (application repo)

1. Create a feature branch from latest stable release (probably tagged in dot notation).
2. Implement the change.
3. Create PR.
4. CI runs tests, linting, and any SAST/dependency scanning.
5. Merge PR into the main branch.

**Outcome:** Application code is merged, but nothing has been deployed yet unless your pipeline is configured to.

### 2) Build and publish a container image (CI)

After the PR is merged, CI typically:

- Builds a container image.
- Tags it with a commit SHA hash so you can refer back to it in git history.
- Pushes the image to a registry (I use Amazon ECR but you can use DockerHub or others too).
- Publishes build metadata (SBOM, scan results, provenance if used).

**Outcome:** New immutable image exists in the registry and is ready to be deployed.

### 3) Trigger a deployment by changing desired state in the GitOps repo

To deploy, the developer (or a release automation job) updates the GitOps configuration:

- Updates the image tag in a Helm values file or manifest.
- Opens a PR with the config change (image tag and any config values if needed).

**Outcome:** Deployment is represented as a PR in Git.

### 4) Review and approve (PR gate)

This PR is the approval point for deployment and normally includes:

- YAML/Helm linting
- Policy-as-code checks (E.g. OPA)
- Security checks (image scan, allowed registries/tags)
- Change management approvals (in highly regulated environments)

### 5) Merge triggers deployment (ArgoCD reconciles)

After the GitOps PR is merged:

- ArgoCD detects the change in the watched branch/path.
- ArgoCD applies the updated manifests to the target cluster and namespace.
- Kubernetes performs a rollout (E.g. rolling update) based on the Deployment strategy.
- Argo reports status:
  - **Synced/OutOfSync** (does desired state (Git) match current state (live cluster)?)
  - **Healthy/Degraded** (are resources healthy?)

**Outcome:** Deployment done with status available in ArgoCD.

### 6) Validate and observe

Developers validate via:

- ArgoCD UI (sync and health statuses)
- Application dashboards/metrics/logs (E.g. CloudWatch dashboard or Grafana etc.)
- Developers could also have read-only `kubectl` access in their namespace to make calls themselves

### 7) Rollback if needed via a Git revert

If needed, rollback is done by reverting the GitOps change:

- Revert the PR (or create a new PR changing the image tag back).
- Merge the reverted PR.
- ArgoCD reconciles the cluster back to the last known good state.

---

## Platform workflow

Platform responsibilities are split between infrastructure (Terraform) and in-cluster configuration (GitOps YAML).

### A) Provision the platform foundation (Terraform)

Platform team provisions and manages:

- VPC, subnets, routing and all other networking
- EKS cluster + node groups
- EKS managed add-ons (e.g., VPC CNI, CoreDNS, kube-proxy, ebs-csi-driver)
- IAM/OIDC for IRSA to map service accounts to IAM Roles
- Logging targets if not letting the AWS-approved Helm charts create them automatically (CloudWatch log groups, retention, etc.)
- New optional Argo CD capability (as of ReInvent 2025 Dec) enabled for the cluster (managed GitOps controller that AWS scale for you - I haven't done that here though as it would be hard to reproduce in your environment without seeing what you have)

**Outcome:** EKS cluster deployed with all the AWS elements required for GitOps, security and networking.

### B) Bootstrap the cluster baseline (GitOps)

Platform team define a baseline in `kubernetes/baseline/` that is applied to every cluster/environment:

- Namespaces (`ops`, team namespaces, `observability`, etc.)
- RBAC (who can do what in each namespace)
- ServiceAccounts (including the IRSA annotations so the mapping with the IAM role can be made)
- Any other guardrails (ResourceQuotas, NetworkPolicies etc.)

This baseline is usually applied by a “root” ArgoCD Application that targets the `kubernetes/` folder structure in this test.

**Outcome:** Cluster becomes governed and ready for onboarding teams consistently in this shared cluster model.

### C) Manage shared platform add-ons (GitOps)

Platform team also manages shared in-cluster tooling in `kubernetes/cluster_addons/`, typically via Helm:

- Observability agents (log shippers, metrics collectors like metrics-server)
- Ingress controllers like aws-load-balancer
- DNS/cert management (ExternalDNS, cert-manager)

**Outcome:** Platform capabilities are improved and rolled out using the same GitOps workflow.

### D) Onboard application teams

Onboarding typically includes:

- Create team namespace folder under `kubernetes/apps/<team>/`
- Assign access groups via EKS access entries + roles
- Provide a template for app deployment manifests (Helm values)
- Configure IRSA roles/policies for AWS service access per workload

**Outcome:** App teams can deploy through PRs without needing cluster-admin access. They just check status after with their read-only kubectl access.

---

## Prerequisites (what must exist for GitOps to work)

- Cluster reachable by ArgoCD (EKS capability or standard) and configured to read the GitOps repo
- Namespaces + RBAC in place (bootstrap applied)
- Images published to a registry reachable by the cluster (ECR + node/pod permissions)
- Any required AWS access configured via IRSA (service accounts annotated to IAM roles)
- Observability in place so teams can validate deployments (logs/metrics)

---

## Repo layout used here

- `infrastructure/` - Terraform-owned AWS and EKS infrastructure split into modules and environments
- `kubernetes/baseline/` - baseline namespaces/RBAC/service accounts/guardrails
- `kubernetes/cluster_addons/` - shared platform tooling deployed into the cluster like container-insights
- `kubernetes/apps/` - application desired state (or Argo Applications pointing to it)
- `kubernetes/argocd/` - ArgoCD bootstrap manifests: ArgoCD applications (app-of-apps) and root configuration that tells ArgoCD what to sync from this repo. Also shared tooling managed by ArgoCD like aws-load-balncer and metrics-server
- `docs/` - architecture decisions, assumptions, runbooks

---

## Access and permissions

- Humans should generally have read-only access to their namespace and deploy through GitOps.
- CI/CD roles handle image publishing and automated GitOps updates.
- Platform team haselevated access for cluster-wide operations and break-glass scenarios.
