#!/bin/bash
# Reactiva lo pausado: nodos EKS + RDS
set -e
CLUSTER="lab-it-support-lab-eks"
NODEGROUP="lab-it-support-lab-eks-ng-main"
DB="lab-it-support-lab-mssql"
REGION="us-east-1"

echo "Arrancando RDS..."
aws rds start-db-instance --db-instance-identifier $DB --region $REGION || echo "RDS ya activa"

echo "Escalando nodos EKS a 2..."
aws eks update-nodegroup-config --cluster-name $CLUSTER --nodegroup-name $NODEGROUP \
  --scaling-config desiredSize=2,minSize=1,maxSize=3 --region $REGION

echo "Resume aplicado. Espera ~5 min a que RDS y nodos esten listos."
