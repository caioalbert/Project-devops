# EKS DevOps Project

Projeto completo de infraestrutura EKS com observabilidade, logging e CI/CD.

## Estrutura do Projeto

```
├── terraform/              # Infraestrutura EKS
├── .github/workflows/      # GitHub Actions
├── k8s-manifests/          # Manifests Kubernetes
├── monitoring/             # Prometheus, Grafana, AlertManager
├── logging/                # EFK Stack
├── argocd/                 # ArgoCD configs
└── sample-app/             # Aplicação Node.js exemplo
```

## Componentes

- **EKS Cluster** - Terraform
- **Prometheus Operator** - Monitoring e alertas
- **EFK Stack** - Elasticsearch, Fluentbit, Kibana
- **ArgoCD** - GitOps deployment
- **Sample Node App** - Com APM instrumentado

## Deploy

1. Configure AWS credentials
2. Execute pipeline GitHub Actions
3. Configure ArgoCD para aplicações
