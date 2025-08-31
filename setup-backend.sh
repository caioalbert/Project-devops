#!/bin/bash

REGION="us-west-2"
BUCKET_SUFFIX=$(openssl rand -hex 4)
BUCKET_NAME="terraform-state-eks-devops-${BUCKET_SUFFIX}"
DYNAMODB_TABLE="terraform-state-lock"

echo "🪣 Criando bucket S3 para Terraform state..."

# Criar bucket S3
aws s3 mb s3://${BUCKET_NAME} --region ${REGION}

# Habilitar versionamento
aws s3api put-bucket-versioning \
    --bucket ${BUCKET_NAME} \
    --versioning-configuration Status=Enabled

# Habilitar criptografia
aws s3api put-bucket-encryption \
    --bucket ${BUCKET_NAME} \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

echo "🔒 Criando tabela DynamoDB para lock..."

# Criar tabela DynamoDB para lock
aws dynamodb create-table \
    --table-name ${DYNAMODB_TABLE} \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region ${REGION}

echo "✅ Backend configurado!"
echo ""
echo "📝 Atualize o arquivo terraform/backend.tf com:"
echo "bucket = \"${BUCKET_NAME}\""
echo ""
echo "Ou adicione estas secrets no GitHub:"
echo "TF_STATE_BUCKET=${BUCKET_NAME}"
