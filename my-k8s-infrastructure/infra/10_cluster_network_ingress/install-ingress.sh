#!/bin/bash
# 1. 에러 발생 시 즉시 중단 (안정성 확보)
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ">>> [Ingress] Nginx Ingress Controller 설치 시작..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml

# [오점 보완 1] Webhook 삭제 타이밍
# 컨트롤러가 뜨기 전에 미리 지워두는 게 정신 건강에 이롭습니다. 
# 나중에 지우면 그 사이에 규칙 적용(apply) 명령이 거절당할 수 있거든요.
echo ">>> [Ingress] Webhook 검증 제거 (홈랩 최적화)..."
sleep 5
kubectl delete validatingwebhookconfigurations ingress-nginx-admission --ignore-not-found || true

echo ">>> [Ingress] 컨트롤러 배포(Deployment) 완료 대기..."
# Pod 단위가 아니라 Deployment 단위로 기다리는 게 더 정확합니다.
kubectl wait --namespace ingress-nginx \
  --for=condition=available deployment/ingress-nginx-controller \
  --timeout=120s

# [오점 보완 2] External-IP 할당 대기
# MetalLB가 IP를 줄 때까지 기다리지 않고 다음 명령을 치면 
# 나중에 get svc 했을 때 <pending>만 보고 당황할 수 있습니다.
echo ">>> [Ingress] MetalLB로부터 External IP 할당 대기 중..."
until kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' > /dev/null 2>&1; do
  echo "Waiting for External IP..."
  sleep 5
done

echo ">>> [Ingress] AI 서비스 연결 규칙 적용..."
kubectl apply -f "${DIR}/ai-service-ingress.yaml"

echo "--------------------------------------------------------------------------------"
echo ">>> [성공] 모든 설정이 완료되었습니다!"
echo ">>> 접속 주소: http://$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
