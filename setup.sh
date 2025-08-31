#!/bin/bash

echo "🚀 Setting up EKS DevOps Project"

# Verificar se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não encontrado. Instale kubectl primeiro."
    exit 1
fi

# Verificar se aws cli está instalado
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI não encontrado. Instale AWS CLI primeiro."
    exit 1
fi

echo "✅ Pré-requisitos verificados"

# Aplicar CRDs do Prometheus Operator
echo "📊 Instalando Prometheus Operator CRDs..."
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml

# Aplicar CRDs do ECK
echo "📋 Instalando ECK CRDs..."
kubectl apply -f https://download.elastic.co/downloads/eck/2.9.0/crds.yaml

# Aplicar CRDs do ArgoCD
echo "🔄 Instalando ArgoCD CRDs..."
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.0/manifests/crds/application-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.0/manifests/crds/appproject-crd.yaml

echo "✅ Setup inicial concluído!"
echo ""
echo "📝 Próximos passos:"
echo "1. Configure suas credenciais AWS"
echo "2. Execute a pipeline GitHub Actions para deploy do EKS"
echo "3. Acesse os serviços através dos LoadBalancers criados"
echo ""
echo "🔗 URLs dos serviços (após deploy):"
echo "- Grafana: http://<grafana-lb>:3000 (admin/admin123)"
echo "- Prometheus: http://<prometheus-lb>:9090"
echo "- AlertManager: http://<alertmanager-lb>:9093"
echo "- Kibana: http://<kibana-lb>:5601"
echo "- ArgoCD: http://<argocd-lb>"
echo "- Sample App: http://<sample-app-lb>"
