# eks-with-terraform

# Deploying to EKS 

To create the EKS cluster and deploy a sample application, run below command -

```
make create_all
```

For ingress, ALB ingress controller is used which creates an AWS ALB with listener rules, target group etc., to allow traffic from outside the cluster. The ALB DNS to access the app is printed at the end. 

To delete the apps and EKS cluster, run below command -

```
make delete_all
```
