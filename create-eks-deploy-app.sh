#!/bin/bash

# Create terraform backend in AWS S3
terraform -chdir=modules/terraform-backend-s3 apply -auto-approve

# Create VPC, subnets, EKS cluster and ingress-controller
terraform apply -auto-approve
terraform output eks_kubeconfig > .kubeconfig

# Create kubernetes resources like alb-ingress-controller and deploy the 2048-game app
KUBECONFIG=.kubeconfig kubectl apply -f kubernetes/
