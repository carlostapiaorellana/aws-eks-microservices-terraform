# Laboratorio 5 — IT Support System en AWS

Sistema de tickets con 3 microservicios en EKS, desplegado con Terraform + GitHub Actions.

## Arquitectura

```
Usuario → CloudFront ─┬→ S3 (frontend)
                      └→ /api/* → API Gateway → (VPC Link → ALB → EKS pods)
                                                  ├ tickets-api → RDS SQL Server
                                                  ├ files-api   → S3 (adjuntos)
                                                  └ metrics-api → RDS SQL Server
```

## Stack
EKS 1.31 · RDS SQL Server Express · S3 · CloudFront · API Gateway HTTP API · ECR · Secrets Manager · OIDC · IRSA · CloudTrail · AWS Budgets · Node.js 20 · GitHub Actions + Trivy

## Costo aproximado
~$160/mes 24/7. Usa `scripts/pause.sh` al terminar cada sesión → ~$2-30/mes real.
EKS control plane ($73/mes) y NAT ($32/mes) son lo más caro.

---

## PASO A PASO DE IMPLEMENTACIÓN

### Prerequisitos
```
aws --version        # v2
terraform --version  # >= 1.6
kubectl version --client
docker --version
helm version
node --version       # >= 20
aws configure        # access key + secret + us-east-1
aws sts get-caller-identity   # verificar
```

### FASE 0 — Bootstrap (state backend)
```bash
cd bootstrap
terraform init
terraform apply        # crea bucket S3 + DynamoDB. Anota el output backend_config_snippet
```

### FASE 1 — Configurar backend
1. Copia el `backend_config_snippet` del paso anterior.
2. Pega los valores reales en `terraform/backend.tf` (bucket y dynamodb_table).
3. Edita `terraform/terraform.tfvars`: cambia `github_org`, `github_repo`, `alert_email`.

```bash
cd ../terraform
terraform init    # conecta al backend remoto
```

### FASES 2-5 + 8 — Infraestructura (un solo apply)
```bash
# Prerequisito Helm (evita el error "no cached repo"):
helm repo add eks https://aws.github.io/eks-charts
helm repo update

terraform fmt -recursive
terraform validate
terraform plan
terraform apply      # ~20-25 min (EKS + CloudFront son lentos)
```

Si `terraform apply` falla con **"log group already exists"** (porque un intento previo dejó el log group):
```bash
terraform import module.eks.aws_cloudwatch_log_group.cluster /aws/eks/lab-it-support-lab-eks/cluster
terraform apply
```

### Configurar kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name lab-it-support-lab-eks
kubectl get nodes        # 2 nodos Ready
kubectl get pods -n kube-system | grep aws-load-balancer   # LBC corriendo
```

### FASE 6-7 — Desplegar microservicios

# 1. Obtener cuenta y definir región
$ACCOUNT = aws sts get-caller-identity --query Account --output text
$REGION = "us-east-1"

# 2. Login en ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

# 3. Bucle para compilar y subir cada microservicio
foreach ($svc in @("tickets-api", "files-api", "metrics-api")) {
    Set-Location "..\app\$svc"
    docker build -t $svc .
    docker tag "${svc}:latest" "${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/lab-it-support-lab/${svc}:latest"
    docker push "${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/lab-it-support-lab/${svc}:latest"
    Set-Location "..\..\terraform"
}

**B) Rellenar los manifests con tus valores reales:**

En `k8s-manifests/`, reemplaza los `REEMPLAZAR_*` usando los outputs de Terraform:
```bash
cd terraform
terraform output    # copia los ARNs y nombres
```
- `REEMPLAZAR_*_ROLE_ARN` → `irsa_*_role_arn`
- `REEMPLAZAR_ECR_*` → `ecr_repository_urls`
- `REEMPLAZAR_DB_SECRET_ARN` → `db_secret_arn`
- `REEMPLAZAR_ATTACHMENTS_BUCKET` → `attachments_bucket_name`

**C) Aplicar los manifests:**
```bash
cd ../k8s-manifests
kubectl apply -f 00-serviceaccounts.yaml
kubectl apply -f 01-tickets-api.yaml
kubectl apply -f 02-files-api.yaml
kubectl apply -f 03-metrics-api.yaml
kubectl apply -f 04-ingress.yaml

kubectl get pods                          # 6 pods Running (2 por servicio)
kubectl get ingress it-support-ingress    # espera 2-3 min a que ADDRESS tenga el ALB DNS
```

**D) Conectar API Gateway al ALB (cierre del circuito):**

Cuando el Ingress tenga su ALB (`kubectl get ingress` muestra un DNS), ese ALB es el backend real. Para enrutar API Gateway → ALB vía VPC Link, edita `terraform/modules/api_gateway/main.tf` cambiando la integración `HTTP_PROXY` placeholder por el DNS del ALB, y `terraform apply`. (El placeholder httpbin funciona mientras tanto para probar el flujo CloudFront → API GW.)

El test final end-to-end
Después de verificar todo en la consola, haz el test que confirma que el circuito completo funciona:

# Test 1: Frontend carga
start https://d1l4h0rfcbd0lw.cloudfront.net

# Test 2: API vía CloudFront
curl.exe https://d1l4h0rfcbd0lw.cloudfront.net/api/tickets/health

# Test 3: Crear un ticket
curl.exe -X POST https://d1l4h0rfcbd0lw.cloudfront.net/api/tickets `
  -H "Content-Type: application/json" `
  -d "{\"usuario\":\"Carlos Tapia\",\"asunto\":\"Test Lab 5 AWS\",\"prioridad\":\"Alta\"}"

# Test 4: Ver el ticket creado
curl.exe https://d1l4h0rfcbd0lw.cloudfront.net/api/tickets

# Test 5: Métricas del dashboard
curl.exe https://d1l4h0rfcbd0lw.cloudfront.net/api/metrics


Subir el frontend real

# 1. Ir a la raíz del proyecto
cd ..

# 2. Verificar que el archivo existe
dir app\frontend\index.html

# 3. Subir el frontend real
aws s3 cp app\frontend\index.html s3://lab-it-support-lab-frontend-5e7c0445/index.html --content-type "text/html"

# 4. Invalidar caché de CloudFront
aws cloudfront create-invalidation --distribution-id EN58GTHE7KCTK --paths "/*"

# 5. Esperar y verificar (repite hasta que diga Completed)
aws cloudfront list-invalidations --distribution-id EN58GTHE7KCTK --query "InvalidationList.Items[0].Status" --output text


### Configurar CI/CD (GitHub Actions)
1. En GitHub: Settings → Secrets and variables → Actions → New repository secret:
   - `AWS_ROLE_ARN` = output `github_actions_role_arn`
2. Push a `main` con cambios en `app/**` dispara `apps.yml` (build + Trivy + push + rollout).
3. Push con cambios en `terraform/**` dispara `infra.yml`.

### Verificar la app
```bash
terraform output cloudfront_domain    # abre esa URL en el browser
```

---

## Apagar / Encender / Destruir
```bash
./scripts/pause.sh     # apaga nodos + RDS (ahorra dinero)
./scripts/resume.sh    # reactiva
./scripts/destroy.sh   # destruye todo el lab
```

## Orden de destrucción (importante)
1. `kubectl delete ingress it-support-ingress` (libera el ALB ANTES de destruir la VPC)
2. `terraform destroy` en `terraform/`
3. (opcional) `terraform destroy` en `bootstrap/`

## Fixes ya aplicados en este código
- ❌ `timestamp()` en tags → eliminado (causaba "inconsistent final plan")
- ❌ `for_each = toset()` con ARNs de apply → cambiado a `count` en módulo irsa
- ❌ MOCK integration en HTTP API → cambiado a `HTTP_PROXY` (HTTP API no soporta MOCK)
- ✅ Log group EKS creado por Terraform con `depends_on` (evita conflicto si se crea limpio)
- ✅ Helm repo: documentado `helm repo add eks` antes del apply
