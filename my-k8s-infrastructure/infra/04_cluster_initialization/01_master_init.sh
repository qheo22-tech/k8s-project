#!/bin/bash
# 이 스크립트는 마스터 노드에서 '딱 한 번'만 실행합니다.

MASTER_IP=$(hostname -I | awk '{print $1}')
POD_CIDR="10.244.0.0/16" # Calico 권장 대역 집대역이랑 안겹치게 해야함
#쿠버네티스 네트워크 담당( pod통신 + 정책)

echo ">>> 클러스터 초기화를 시작합니다 (Master IP: $MASTER_IP)"

sudo kubeadm init \
  --pod-network-cidr=$POD_CIDR \
  --apiserver-advertise-address=$MASTER_IP

# kubectl 사용을 위한 권한 설정
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "✅ 마스터 초기화 완료! 이제 './install_calico.sh'를 실행해서 네트워크를 구성하세요."
