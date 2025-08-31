#!/bin/bash

echo "🚨 DESTROY EKS Infrastructure"
echo "This will delete ALL resources created by this project!"
echo ""
read -p "Type 'DESTROY' to confirm: " confirm

if [ "$confirm" != "DESTROY" ]; then
    echo "❌ Aborted"
    exit 1
fi

echo "🗑️ Starting destruction process..."

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name devops-eks 2>/dev/null || echo "Cluster not found"

# Delete Kubernetes resources in order
echo "Deleting applications..."
kubectl delete -f sample-app/k8s-manifests.yaml --ignore-not-found=true

echo "Deleting ArgoCD..."
kubectl delete -f argocd/ --ignore-not-found=true

echo "Deleting logging stack..."
kubectl delete -f logging/fluentbit.yaml --ignore-not-found=true
kubectl delete -f logging/apm-server.yaml --ignore-not-found=true
kubectl delete -f logging/kibana.yaml --ignore-not-found=true
kubectl delete -f logging/elasticsearch.yaml --ignore-not-found=true
kubectl delete -f logging/eck-operator.yaml --ignore-not-found=true

echo "Deleting monitoring..."
kubectl delete -f monitoring/ --ignore-not-found=true

echo "Deleting namespaces..."
kubectl delete -f k8s-manifests/namespaces.yaml --ignore-not-found=true

echo "Waiting for cleanup..."
sleep 60

# Terraform destroy
echo "Running terraform destroy..."
cd terraform

# Setup backend if exists
BUCKET_NAME=$(aws s3 ls | grep terraform-state-eks-devops | awk '{print $3}' | head -1)
if [ ! -z "$BUCKET_NAME" ]; then
    cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "eks/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
EOF
fi

terraform init
terraform destroy -auto-approve

cd ..

# Clean up backend resources
echo "Cleaning up backend resources..."
if [ ! -z "$BUCKET_NAME" ]; then
    aws s3 rm s3://$BUCKET_NAME --recursive
    aws s3 rb s3://$BUCKET_NAME
fi

aws dynamodb delete-table --table-name terraform-state-lock --region us-west-2 2>/dev/null || echo "DynamoDB table not found"

# Delete ECR repository
aws ecr delete-repository --repository-name sample-node-app --region us-west-2 --force 2>/dev/null || echo "ECR repository not found"

echo "✅ Destruction complete!"
