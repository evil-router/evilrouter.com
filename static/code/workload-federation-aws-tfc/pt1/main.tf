terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

variable "workspace" {
  type = string
  description = "Terraform Cloud Workspace to be granted access to AWS"
}
variable "organization" {
  type = string
  description = "Terraform Cloud Organization to be granted access"
}
variable "project" {
  type  = string
  description = "Terraform Cloud Project to be granted access"
}
variable "audience" {
  type = string
  default = "aws.workload.identity"
  description = "The audience to be configured for AWS to be looking for"
}

provider "aws" {
  region = "us-east-1"
}

### Getting the certificate information for Terraform cloud endpoint
data "tls_certificate" "app_terraform" {
  url = "https://app.terraform.io"
}


### Registering the Identity provider of Terraform Cloud with the audience above
resource "aws_iam_openid_connect_provider" "oidc" {
  url = "https://app.terraform.io"
  client_id_list = [var.audience]
  thumbprint_list = [data.tls_certificate.app_terraform.certificates[0].sha1_fingerprint]
}

# Creating Policy to allow the workspace to assume the role.
# The format of the Sub is defined here https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens#token-specification
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      # This creates a mapping to the workspace based on an Exact match organization,project,workspace.
      values   = ["organization:${var.organization}:project:${var.project}:workspace:${var.workspace}:run_phase:*"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

# Create the role for Terraform to use, in this case we are giving admin as we want it to create IAM permissions
# You should create narrower roles for less privileged workspaces.
resource "aws_iam_role" "tfc_role" {
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  name                  = "TFC-Admin"
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  force_detach_policies = true
}

# Output the Role ARN so that it can be read to be used in Workload Federation.
output "role_arn" {
  value = aws_iam_role.tfc_role.arn
  description = "Role created that Terraform Cloud can assume with STS"
}