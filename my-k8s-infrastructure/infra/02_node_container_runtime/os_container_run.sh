#!/bin/bash
# =========================================================
# [02_container_install_run.sh]
# 용도: 컨테이너 엔진(containerd) 설치 및 K8s 최적화 설정
# 특징: SystemdCgroup 활성화 및 샌드박스 이미지 최신화
# =========================================================

# 스크립트 위치 기준 절대 경로 설정 (Cloud-init 대응)
cd "$(dirname "$0")"
echo ">>> [02_container_install] 컨테이너 엔진 설치를 시작합니다."

# 1. 패키지 업데이트 및 containerd 설치
# (참고: 실무에선 docker-ce 레포지토리의 최신 containerd.io를 쓰기도 하지만, 
#  안정성을 위해 우분투 기본 패키지를 쓰는 것도 좋은 선택입니다.)
sudo apt-get update
sudo apt-get install -y containerd

# 2. containerd 기본 설정 파일 초기화
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# 3. 핵심 최적화 설정 (sed 마법)
echo ">>> [02_container_install] config.toml 최적화 적용 중..."

# A. SystemdCgroup 설정 활성화 (쿠버네티스 안정성 핵심)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# B. 샌드박스(Pause) 이미지 최신화 (K8s 버전에 맞게 수정)
# registry.k8s.io/pause:3.6 -> 3.9 (더 안정적인 네트워크 스택 제공)
sudo sed -i 's/registry.k8s.io\/pause:3.6/registry.k8s.io\/pause:3.9/g' /etc/containerd/config.toml

# 4. 설정 반영 및 서비스 재시작
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "✅ [02_container_install] 완료!"
sudo systemctl status containerd --no-pager | grep Active
