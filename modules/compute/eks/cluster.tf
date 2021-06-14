# data "terraform_remote_state" "vpc" {
#   backend = "s3"
#   config = {
#     bucket = "terraform-backend-in-s3-for-eks-with-terraform"
#     key    = "terraform.tfstate"
#     region = var.region
#   }
# }

provider "external" {
  # version = "~> 1.2"
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "aws_eks" {
  name     = "eks_cluster_using_terraform"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    //    subnet_ids = ["subnet-1", "subnet-2"] //TODO: fill
    //subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
    subnet_ids = var.subnet_ids
  }

  tags = {
    Name = "eks_cluster_using_terraform"
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-tuto"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "node_eks_with_terraform"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  # subnet_ids      = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  //subnet_ids      = ["<subnet-1>", "<subnet-2>"]
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Get the OIDC provider thumbprint for root CA
data "external" "thumbprint" {
  program =    ["${path.module}/get_oidc_thumbprint.sh", var.region]
  depends_on = [aws_eks_cluster.aws_eks]
}

resource "aws_iam_openid_connect_provider" "aws_eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = data.aws_eks_cluster.aws_eks.identity[0].oidc[0].issuer

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}


# generate KUBECONFIG as output to use as ~/.kube/config locally
# save the 'terraform output eks_kubeconfig > config', run 'mv config ~/.kube/config' to use it for kubectl
locals {
  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.aws_eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.aws_eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --cluster-name
      - ${aws_eks_cluster.aws_eks.name}
      - --region
      - us-east-1
      command: aws
KUBECONFIG
}

output "eks_kubeconfig" {
  value = local.kubeconfig
  depends_on = [aws_eks_cluster.aws_eks]
}

output "eks_cluster_name" {
  value    = aws_eks_cluster.aws_eks.name
}

output "cluster_name" {
  value = aws_eks_cluster.aws_eks.name
}
