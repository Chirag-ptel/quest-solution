provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


terraform {
  backend "s3" {
    bucket = "tf-state-bucket-10101"
    key    = "rearc-quest/eks/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "tf-state-bucket-10101"
    key            = "rearc-quest/vpc/terraform.tfstate"
    region         = "ap-south-1"
  }
}


module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "${var.cluster_name}"
  cluster_version = "1.32"

  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.private_subnets
  cluster_endpoint_public_access = true
  
  cluster_addons = {
    eks-pod-identity-agent = {
      addon_version = "v1.3.4-eksbuild.1"
    }

    # aws-ebs-csi-driver = {
    #   #addon_version = "v1.40.0-eksbuild.1"  
    # }
      
  }
  # enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    c6a_x86_64 = {
      name = "${var.cluster_name}"

      ami_type       = "AL2_x86_64"
      instance_types = ["c6a.xlarge"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

    # AL2_x86_64_ondemand = {
    #       name = "node-group-ondemand"

    #       ami_type       = "AL2_x86_64"
    #       instance_types = ["t3a.micro"]
    #       capacity_type  = "ON_DEMAND"

    #       min_size     = 3
    #       max_size     = 3
    #       desired_size = 3
    #     }
  }
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# module "irsa-ebs-csi" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#   provider_url                  = module.eks.oidc_provider
#   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }

# resource "aws_eks_addon" "ebs-csi" {
#   cluster_name             = module.eks.cluster_name
#   addon_name               = "${var.cluster_name}-ebs-csi-driver"
#   service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
#   addon_version = "v1.40.0-eksbuild.1"
#   tags = {
#     "eks_addon" = "ebs-csi"
#     "terraform" = "true"
#   }
# }

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "eks_access_entry" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks-access-policy-attach" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "eks-admin-policy-attach" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type = "cluster"
  }
}



