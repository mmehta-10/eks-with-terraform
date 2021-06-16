## Create all resources 
create_all: create_tf_backend create_tf_infra deploy_kubernetes_app

## Delete everything
delete_all: delete_kubernetes_app delete_tf_infra delete_tf_backend

## Create bucket using AWS S3 for acting as Terraform backend
create_tf_backend:
	terraform init && terraform -chdir=modules/terraform-backend-s3 apply -auto-approve

## Create infra using terraform, incl. EKS, subnets, VPC etc.
create_tf_infra: 
	terraform init && terraform apply -var-file="network.tfvars"
	terraform output eks_kubeconfig > /tmp/.kubeconfig
	sed -n -e "2,$$(($$(wc -l < /tmp/.kubeconfig) - 1))p" /tmp/.kubeconfig > .kubeconfig

## Create resources in kubernetes
deploy_kubernetes_app:
	KUBECONFIG=.kubeconfig kubectl apply -f kubernetes/
	sleep 30
	albdns=$$(KUBECONFIG=.kubeconfig kubectl get ing 2048-ingress -n 2048-game -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2> /dev/null) && echo $$albdns

## Delete resources in kubernetes
delete_kubernetes_app:
	KUBECONFIG=.kubeconfig kubectl delete -f kubernetes/

## Delete TF backend
delete_tf_backend: 
	terraform -chdir=modules/terraform-backend-s3 destroy

## delete all infra set up using terraform, incl. EKS, subnets, VPC etc.
delete_tf_infra: 
	terraform destroy