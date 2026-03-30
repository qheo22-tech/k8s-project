#!/bin/bash

echo "🚀 NVIDIA Device Plugin 헬름(Helm) 저장소 추가 중..."
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update

echo "📦 NVIDIA Device Plugin 설치 중..."
helm upgrade --install nvidia-device-plugin nvdp/nvidia-device-plugin \
  --namespace kube-system \
  --create-namespace \
  --version 0.17.0 \
  -f gpu-values.yaml  # <--- 설정 파일을 불러오도록 수정!

echo "✅ 설치 완료! 파드 상태를 확인하세요."
kubectl get pods -n kube-system | grep nvidia
