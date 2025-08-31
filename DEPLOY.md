# Guia de Deploy - EKS DevOps Project

## Pré-requisitos

1. **AWS CLI** configurado com credenciais adequadas
2. **kubectl** instalado
3. **Terraform** instalado (v1.6+)
4. **Docker** para build local (opcional)

## Configuração Inicial

### 1. Configurar Secrets no GitHub

Configure os seguintes secrets no seu repositório GitHub:

```
AWS_ACCESS_KEY_ID=<sua-access-key>
AWS_SECRET_ACCESS_KEY=<sua-secret-key>
```

### 2. Executar Setup Inicial

```bash
./setup.sh
```

## Deploy da Infraestrutura

### 1. Deploy via GitHub Actions

Faça push para a branch `main` ou execute manualmente a workflow "Deploy EKS Infrastructure".

### 2. Deploy Manual (alternativo)

```bash
# Deploy Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Configurar kubectl
aws eks update-kubeconfig --region us-west-2 --name devops-eks

# Deploy aplicações
kubectl apply -f k8s-manifests/
kubectl apply -f monitoring/
kubectl apply -f logging/
kubectl apply -f argocd/
```

## Verificação dos Serviços

### 1. Obter URLs dos LoadBalancers

```bash
# Grafana
kubectl get svc grafana -n monitoring

# Prometheus
kubectl get svc prometheus -n monitoring

# Kibana
kubectl get svc kibana-lb -n logging

# ArgoCD
kubectl get svc argocd-server -n argocd

# Sample App
kubectl get svc sample-node-app -n sample-app
```

### 2. Credenciais de Acesso

**Grafana:**
- URL: `http://<grafana-lb>:3000`
- User: `admin`
- Password: `admin123`

**Kibana:**
- URL: `http://<kibana-lb>:5601`
- User: `elastic`
- Password: Obter com: `kubectl get secret elasticsearch-es-elastic-user -n logging -o jsonpath='{.data.elastic}' | base64 -d`

**ArgoCD:**
- URL: `http://<argocd-lb>`
- User: `admin`
- Password: Obter com: `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d`

## Configuração Pós-Deploy

### 1. Configurar AlertManager

Edite o secret `alertmanager-main` em `monitoring/alertmanager.yaml` com suas configurações de email:

```yaml
smtp_auth_username: 'seu-email@gmail.com'
smtp_auth_password: 'sua-app-password'
```

### 2. Configurar ArgoCD Applications

```bash
kubectl apply -f argocd/frontend-app.yaml
```

### 3. Testar Aplicação Sample

```bash
# Obter URL da aplicação
SAMPLE_APP_URL=$(kubectl get svc sample-node-app -n sample-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Testar endpoints
curl http://$SAMPLE_APP_URL/
curl http://$SAMPLE_APP_URL/health
curl http://$SAMPLE_APP_URL/metrics
curl http://$SAMPLE_APP_URL/error  # Para testar APM
```

## Monitoramento

### Métricas no Grafana

1. Acesse Grafana
2. Importe dashboards para Kubernetes
3. Visualize métricas da aplicação sample

### Logs no Kibana

1. Acesse Kibana
2. Configure index pattern: `fluentbit-*`
3. Visualize logs dos pods

### APM no Kibana

1. Acesse Kibana > APM
2. Visualize traces da aplicação Node.js
3. Monitore performance e erros

## Troubleshooting

### Verificar Status dos Pods

```bash
kubectl get pods -A
```

### Logs dos Serviços

```bash
# Prometheus Operator
kubectl logs -n monitoring deployment/prometheus-operator

# Fluent Bit
kubectl logs -n logging daemonset/fluent-bit

# ECK Operator
kubectl logs -n elastic-system statefulset/elastic-operator
```

### Verificar CRDs

```bash
kubectl get crd | grep -E "(monitoring|elastic|argo)"
```
