locals {
  account_id = data.aws_caller_identity.current.account_id
  cluster_name = "${var.environment}_${var.region}_cluster"
  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
