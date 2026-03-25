#!/bin/bash
# 스크립트 파일이 있는 실제 경로를 변수에 담기
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ">>> [MetalLB] 네이티브 매니페스트 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

echo ">>> [MetalLB] 컨트롤러가 준비될 때까지 잠시 대기 (30초)..."
sleep 30

echo ">>> [MetalLB] IPAddressPool 및 L2Advertisement 설정 적용..."
# 변수를 사용하여 같은 폴더의 yaml 파일을 지칭
kubectl apply -f "${DIR}/metallb-config.yaml"

echo "--------------------------------------------------------------------------------"
echo ">>> MetalLB 상태 확인:"
kubectl get pods -n metallb-system
