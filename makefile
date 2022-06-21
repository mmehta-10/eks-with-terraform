## Create AWS EKS. After that deploy app with ingress
create_all: 
	make create_backend
	make create_infra
	make deploy_kubernetes_app

## Destroy all resources in AWS and EKS created by this codebase
delete_all: 
	make delete_kubernetes_app
	make delete_infra
	make delete_tf_backend

## Create bucket using AWS S3 for acting as Terraform backend
create_backend:
	terraform -chdir=s3-backend init 
	terraform -chdir=s3-backend apply -var-file="variables.tfvars" -auto-approve

## Create infra using terraform, incl. EKS, subnets, VPC etc.
create_infra: 
	terraform init
	terraform apply -auto-approve
	terraform output eks_kubeconfig > /tmp/.kubeconfig
	sed -n -e "2,$$(($$(wc -l < /tmp/.kubeconfig) - 1))p" /tmp/.kubeconfig > .kubeconfig

## Create resources in kubernetes
deploy_kubernetes_app:
	# Deploy fluentd for cloudwatch logging of container logs
	KUBECONFIG=.kubeconfig kubectl apply -f kubernetes/amazon-cloudwatch-fluentd
	
	# Deploy clusterautoscaler and metrics-server for enabling HPA
	KUBECONFIG=.kubeconfig kubectl apply -f kubernetes/autoscaling

	# Deploy nginx-ingress-controller and the max-weather-app
	KUBECONFIG=.kubeconfig kubectl apply -f kubernetes/
	sleep 30
	nlbdns=$$(KUBECONFIG=.kubeconfig kubectl get ing max-weather-forecaster -n max-weather-forecaster -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2> /dev/null) && echo $$nlbdns

## Delete resources in kubernetes
delete_kubernetes_app:
	KUBECONFIG=.kubeconfig kubectl delete -f kubernetes/

## Delete TF backend
delete_tf_backend: 
	terraform -chdir=modules/terraform-backend-s3 destroy

## delete all infra set up using terraform, incl. EKS, subnets, VPC etc.
delete_infra: 
	terraform destroy