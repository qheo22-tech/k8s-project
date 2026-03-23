#!/bin/bash
# =========================================================
# [03_k8s_install_run.sh]
# 용도: 쿠버네티스(v1.31) 바이너리 설치 및 패키지 고정
# 특징: APT 락 대기 로직 및 중복 저장소 등록 방지 포함
# =========================================================

echo ">>> [03_k8s_install] 쿠버네티스 패키지 설치를 시작합니다."

# [보완] APT 락(Lock) 대기 로직 - 자동화 설치 시 필수
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Wait for other apt instance to finish..."
    sleep 2
done

# 1. 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg conntrack socat

# 2. GPG 키 및 저장소 등록 (v1.31)
sudo mkdir -p -m 755 /etc/apt/keyrings
# 중복 다운로드 방지
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

# 저장소 리스트 생성 (중복 방지)
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 3. K8s 컴포넌트 설치
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# 4. 버전 업데이트 방지 (패키지 고정)
sudo apt-mark hold kubelet kubeadm kubectl

# 5. 서비스 활성화 및 자동 시작 설정
sudo systemctl enable --now kubelet

echo "✅ [03_k8s_install] 완료!"
echo "=========================================================="
echo "✅ [SUCCESS] 기초 인프라 설치가 완료되었습니다!"
echo "🚀 다음 단계: 마스터 노드에서 아래 경로의 README를 확인하세요."
echo "👉 path: ~/k8s-project/my-k8s-infrastructure/infra/04_cluster_network_cni/README.md"
echo "=========================================================="
kubeadm version
