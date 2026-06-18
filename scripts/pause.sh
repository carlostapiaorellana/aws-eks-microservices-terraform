#!/bin/bash
# Apaga lo caro sin destruir: escala nodos EKS a 0 + para RDS
# Ahorra ~$1.6/dia (workers + RDS). El control plane EKS sigue cobrando ($2.4/dia).
set -e
CLUSTER="lab-it-support-lab-eks"
NODEGROUP="lab-it-support-lab-eks-ng-main"
DB="lab-it-support-lab-mssql"
REGION="us-east-1"

echo "Escalando nodos EKS a 0..."
aws eks update-nodegroup-config --cluster-name $CLUSTER --nodegroup-name $NODEGROUP \
  --scaling-config desiredSize=0,minSize=0,maxSize=3 --region $REGION

echo "Parando RDS..."
aws rds stop-db-instance --db-instance-identifier $DB --region $REGION || echo "RDS ya parada o no se puede"

echo "Pausa aplicada. Para destruir el NAT tambien: cd ../terraform && terraform apply -var=enable_nat_gateway=false"
