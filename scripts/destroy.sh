#!/bin/bash
# Destruye TODA la infraestructura del lab.
# El bootstrap (state backend) NO se destruye aqui - eso es manual.
set -e
cd "$(dirname "$0")/../terraform"

echo "ADVERTENCIA: esto destruira TODA la infra del lab."
read -p "Escribe 'destruir' para confirmar: " confirm
[ "$confirm" != "destruir" ] && echo "Cancelado" && exit 1

# Primero borrar el Ingress para que el ALB se elimine antes que la VPC
echo "Borrando Ingress (libera el ALB)..."
kubectl delete ingress it-support-ingress -n default --ignore-not-found=true || true
sleep 30

echo "Terraform destroy..."
terraform destroy -auto-approve

echo "Infra destruida. El bootstrap (S3 state + DynamoDB) sigue activo."
echo "Para destruir el bootstrap: cd ../bootstrap && terraform destroy"
