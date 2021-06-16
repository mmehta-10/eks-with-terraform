#!/bin/bash

terraform init

# Create terraform backend in AWS S3
terraform -chdir=modules/terraform-backend-s3 apply -auto-approve

# Create VPC, subnets, EKS cluster and ingress-controller
terraform apply -auto-approve
terraform output eks_kubeconfig > /tmp/.kubeconfig

sed -n -e "2,$(($(wc -l < /tmp/.kubeconfig) - 1))p" /tmp/.kubeconfig > .kubeconfig

# Create kubernetes resources like alb-ingress-controller and deploy the 2048-game app
KUBECONFIG=.kubeconfig kubectl apply -f kubernetes/

# Wait for ingress to complete
KUBECONFIG=.kubeconfig kubectl get ing 2048-ingress -n 2048-game