module "eks" {
  source = "../../modules/eks"

  prefix       = local.name_prefix
  cluster_name = local.cluster_name
  bootstrap_admin_principal_arn = var.bootstrap_admin_principal_arn

  incoming_orders_bucket_name = var.incoming_orders_bucket_name

  cluster_version = "1.32"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  private_ec2_instance_types = ["m6i.2xlarge"] # Need at least 28GB memory peak for nodes  according to the brief, so have chosen a type with 32GB. Would normally stress test workload requirements to right-size this.
  node_min_size       = 9 # Minimum nodes to achieve high availability and withstand an AZ failure (see comments in architecture_desicion_record.md)
  node_desired_size   = 9
  node_max_size       = 12
  node_disk_size      = 50

  tags = local.common_tags
}
