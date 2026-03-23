#!/bin/bash
# ==============================================================================
# [install_calico.sh] - Calico CNI(컨테이너 네트워크 플러그인) 설치 스크립트
# 
# 역할: 쿠버네티스 내부의 파드(Pod)들이 서로 통신할 수 있게 '가상 네트워크' 길을 뚫어줍니다.
# 주의: 이 스크립트는 마스터 노드에서 '딱 한 번'만 실행하세요.
# ==============================================================================

# [핵심] 왜 10.244.0.0/16 을 쓰나요?
# 집이나 사무실의 물리 공유기는 보통 192.168.0.x 대역을 씁니다. 
# 만약 쿠버네티스 파드(가상) 대역이 공유기 대역과 겹치면 통신이 엉키는 대참사가 발생합니다!
# 따라서 절대 겹치지 않는 10.244.x.x 대역으로 파드 전용망을 구축하는 것입니다.
# (반드시 master_init.sh에서 설정한 pod-network-cidr과 똑같아야 합니다.)
POD_CIDR="10.244.0.0/16"

echo ">>> [04_cni] Calico 네트워크 배관 공사를 시작합니다. (대상 CIDR: $POD_CIDR)"

# 1. Tigera Operator 설치
# Calico 네트워크를 설치하고 든든하게 관리해 주는 '현장 소장님(Operator)'을 먼저 모셔옵니다.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# 2. 커스텀 리소스(Custom Resource) 정의 파일 다운로드
# Calico의 세부 설정(우리가 쓸 IP 대역 등)이 담긴 기본 설계도(YAML)를 다운로드합니다.
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

# 3. CIDR 대역 자동 수정 (충돌 방지 마법의 명령어 🪄)
# 방금 다운받은 원본 설계도에는 Calico 기본값인 '192.168.0.0/16'이 적혀있습니다.
# 이대로 설치하면 우리집 공유기와 충돌하니까, sed 명령어로 10.244 대역으로 싹 바꿔치기합니다.
# (설명: IP에 슬래시(/)가 들어가 있어서 에러가 안 나도록 골뱅이(@)를 구분자로 썼습니다.)
sed -i "s@cidr: 192.168.0.0/16@cidr: $POD_CIDR@g" custom-resources.yaml

# 4. 수정된 설계도를 적용하여 진짜 네트워크 리소스 생성
kubectl create -f custom-resources.yaml

echo ">>> [04_cni] 설치 요청이 완료되었습니다!"
echo "네트워크 파드들이 완전히 기동될 때까지 약 1~2분 정도 컵라면 끓이는 시간이 필요합니다."
echo "진행 상황 확인 명령어: watch kubectl get pods -n calico-system"
