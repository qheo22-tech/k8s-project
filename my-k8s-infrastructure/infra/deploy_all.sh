#!/bin/bash
# 7840HS K8s Node 통합 배포 스크립트
# 사용법: sudo ./deploy_all.sh [hostname]

HOSTNAME=$1
if [[ -z "$HOSTNAME" ]]; then
    echo "❌ 에러: 호스트네임을 입력해주세요. (예: worker5)"
    exit 1
fi

echo ">>> 🚀 [START] $HOSTNAME 노드 셋업 시작"

# 1. OS 초기화 (Hostname, Swap, Modules)
echo ">>> [STEP 00] OS Init"
sh ./00_os_init/os_init_run.sh $HOSTNAME

# 2. OS 커널 튜닝 (Worker 전용)
echo ">>> [STEP 01] OS Tuning"
# 폴더명을 01_os_tuning으로 고쳤다고 가정합니다.
sh ./01_os_tuning/os_tuning_run.sh

# 3. 컨테이너 엔진 설치 (containerd)
echo ">>> [STEP 02] Container Install"
sh ./02_container_install/os_container_run.sh

# 4. 쿠버네티스 패키지 설치 (kubeadm, kubelet)
echo ">>> [STEP 03] K8s Install"
sh ./03_k8s_install/os_k8s_run.sh

echo ">>> 🎉 [FINISH] $HOSTNAME 노드 설정 완료!"
echo ">>> 이제 마스터에서 join 명령어를 복사해오세요."
