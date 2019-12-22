locals {
  cluster_name = "${var.phase}-${var.project}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source = "github.com/getamis/vishwakarma//modules/aws/network?ref=44964a60eed646fb4f44af3dee0b36010ada513d"

  bastion_key_name = var.key_pair_name
  project          = var.project
  phase            = var.phase
  extra_tags       = var.extra_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes" {
  source = "github.com/getamis/vishwakarma//modules/aws/elastikube?ref=44964a60eed646fb4f44af3dee0b36010ada513d"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version
  service_cidr       = var.service_cidr
  cluster_cidr       = var.cluster_cidr

  etcd_config = {
    instance_count   = "1"
    ec2_type         = "t3.medium"
    root_volume_iops = "0"
    root_volume_size = "100"
    root_volume_type = "gp2"
  }

  master_config = {
    instance_count   = "1"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
  }

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  reboot_strategy        = "off"

  extra_tags = merge(map(
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_spot" {
  source = "github.com/getamis/vishwakarma//modules/aws/kube-worker?ref=44964a60eed646fb4f44af3dee0b36010ada513d"

  cluster_name       = local.cluster_name
  kubernetes_version = var.kubernetes_version
  kube_service_cidr  = var.service_cidr

  security_group_ids = module.kubernetes.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  worker_config = {
    name             = "spot"
    instance_count   = "2"
    ec2_type_1       = "t2.2xlarge"
    ec2_type_2       = "t3.2xlarge"
    root_volume_iops = "0"
    root_volume_size = "40"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
  }

  s3_bucket = module.kubernetes.s3_bucket
  ssh_key   = var.key_pair_name

  extra_tags = merge(map(
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}
