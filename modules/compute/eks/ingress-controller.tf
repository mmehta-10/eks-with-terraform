# data "aws_acm_certificate" "default" {
#   domain   = var.domain
#   statuses = ["ISSUED"]
# }

# Policy taken from https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/master/docs/examples/iam-policy.json
# Create a policy that will allow the ingress controller to have rights to create the ALB and register/remove target pods at the ALB

resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name   = "ALBIngressControllerIAMPolicy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

data "aws_eks_cluster" "aws_eks" {
  name = "eks_cluster_using_terraform"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name        = "eks-alb-ingress-controller"
  description = "Permissions required by AWS ALB Ingress controller"

  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.aws_eks.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.aws_eks.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }
  ]
}
ROLE
}

resource "aws_iam_role_policy_attachment" "ALBIngressControllerIAMPolicy" {
  policy_arn = aws_iam_policy.ALBIngressControllerIAMPolicy.arn
  role       = aws_iam_role.eks_alb_ingress_controller.name
}

# resource "kubernetes_service_account" "alb-ingress" {
#   metadata {
#     name = "alb-ingress-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name" = "alb-ingress-controller"
#     }
#   }

#   automount_service_account_token = true
# }

# resource "kubernetes_cluster_role" "alb-ingress" {
#   metadata {
#     name = "alb-ingress-controller"
#     labels = {
#       "app.kubernetes.io/name" = "alb-ingress-controller"
#     }
#   }

#   rule {
#     api_groups = ["", "extensions"]
#     resources  = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
#     verbs      = ["create", "get", "list", "update", "watch", "patch"]
#   }

#   rule {
#     api_groups = ["", "extensions"]
#     resources  = ["nodes", "pods", "secrets", "services", "namespaces"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "alb-ingress" {
#   metadata {
#     name = "alb-ingress-controller"
#     labels = {
#       "app.kubernetes.io/name" = "alb-ingress-controller"
#     }
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "alb-ingress-controller"
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = "alb-ingress-controller"
#     namespace = "kube-system"
#   }
# }

# resource "kubernetes_deployment" "alb-ingress" {
#   metadata {
#     name = "alb-ingress-controller"
#     labels = {
#       "app.kubernetes.io/name" = "alb-ingress-controller"
#     }
#     namespace = "kube-system"
#   }

#   spec {
#     selector {
#       match_labels = {
#         "app.kubernetes.io/name" = "alb-ingress-controller"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           "app.kubernetes.io/name" = "alb-ingress-controller"
#         }
#       }
#       spec {
#         volume {
#           name = kubernetes_service_account.alb-ingress.default_secret_name
#           secret {
#             secret_name = kubernetes_service_account.alb-ingress.default_secret_name
#           }
#         }
#         container {
#           # This is where you change the version when Amazon comes out with a new version of the ingress controller
#           image = "docker.io/amazon/aws-alb-ingress-controller:v1.1.8"
#           name  = "alb-ingress-controller"
#           args = [
#             "--ingress-class=alb",
#             "--cluster-name=${var.cluster_name}",
#             "--aws-vpc-id=${var.vpc_id}",
#             "--aws-region=${var.aws_region}"
#           ]
#           volume_mount {
#             name       = kubernetes_service_account.alb-ingress.default_secret_name
#             mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
#             read_only  = true
#           }
#         }

#         service_account_name = "alb-ingress-controller"

#       }
#     }
#   }
# }

# resource "kubernetes_ingress" "main" {
#   metadata {
#     name = "main-ingress"
#     annotations = {
#       "alb.ingress.kubernetes.io/scheme" = "internet-facing"
#       "kubernetes.io/ingress.class" = "alb"
#       "alb.ingress.kubernetes.io/subnets" = "${var.app_subnet_ids}"
#       "alb.ingress.kubernetes.io/certificate-arn" = "${data.aws_acm_certificate.default.arn}"
#       "alb.ingress.kubernetes.io/listen-ports" = <<JSON
# [
#   {"HTTP": 80},
#   {"HTTPS": 443}
# ]
# JSON
#       "alb.ingress.kubernetes.io/actions.ssl-redirect" = <<JSON
# {
#   "Type": "redirect",
#   "RedirectConfig": {
#     "Protocol": "HTTPS",
#     "Port": "443",
#     "StatusCode": "HTTP_301"
#   }
# }
# JSON
#     }
#   }

#   spec {
#     rule {
#       host = "app.xactpos.com"
#       http {
#         path {
#           backend {
#             service_name = "ssl-redirect"
#             service_port = "use-annotation"
#           }
#           path = "/*"
#         }
#         path {
#           backend {
#             service_name = "app-service1"
#             service_port = 80
#           }
#           path = "/service1"
#         }
#         path {
#           backend {
#             service_name = "app-service2"
#             service_port = 80
#           }
#           path = "/service2"
#         }
#       }
#     }

#     rule {
#       host = "api.xactpos.com"
#       http {
#         path {
#           backend {
#             service_name = "ssl-redirect"
#             service_port = "use-annotation"
#           }
#           path = "/*"
#         }
#         path {
#           backend {
#             service_name = "api-service1"
#             service_port = 80
#           }
#           path = "/service3"
#         }
#         path {
#           backend {
#             service_name = "api-service2"
#             service_port = 80
#           }
#           path = "/service4"
#         }
#       }
#     }
#   }

#   wait_for_load_balancer = true
# }