#!/bin/bash

# ==============================================================================
# [NODES] 모든 노드 정의 (100번 마스터 ~ 107번 워커 전체 리스트)
# ==============================================================================
declare -A NODES=(
    ["100"]="k8s-master"
    ["101"]="k8s-worker-01"
    ["102"]="k8s-worker-02"
    ["103"]="k8s-worker-03"
    ["104"]="k8s-worker-04"
)

TEMPLATE_ID=9000
SNIPPET_PATH="local:snippets"

echo "🚀 [START] K8s 노드 자동 배포 프로세스 시작"
echo ">>> 사양 구성: 마스터(8GB RAM), 워커(4GB RAM), 공통(2Core, 50G Disk)"

for VM_ID in "${!NODES[@]}"; do
    VM_NAME=${NODES[$VM_ID]}
    
    echo "------------------------------------------------"
    echo ">>> [NODE: $VM_NAME (ID: $VM_ID)] 배포를 시작합니다."

    # [0] 기존 VM 정리 (재설치 시 충돌 방지)
    echo ">>> [01/05] 기존 VM $VM_ID 정지 및 삭제 중..."
    qm stop $VM_ID 2>/dev/null
    qm destroy $VM_ID 2>/dev/null

    # [1] 템플릿 복제
    echo ">>> [02/05] 템플릿($TEMPLATE_ID)으로부터 $VM_NAME 복제 중..."
    qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full

    # [WAIT] 디스크 인식을 위해 잠깐 대기
    echo ">>> [WAIT] 장치 인식 대기 중..."
    until qm config $VM_ID | grep -q "scsi0"; do sleep 1; done
    sleep 2

    # [2] 하드웨어 설정 (마스터 노드만 8GB로 벌크업! 💪)
    if [ "$VM_ID" -eq 100 ]; then
        VM_MEM=8192
        echo ">>> [03/05] HW 설정: 마스터 노드 특수 사양 (8GB RAM) 주입"
    else
        VM_MEM=4096
        echo ">>> [03/05] HW 설정: 워커 노드 표준 사양 (4GB RAM) 주입"
    fi
    qm set $VM_ID --cores 2 --memory $VM_MEM

    # [3] 디스크 용량 확장
    echo ">>> [04/05] DISK 확장: 물리 용량 50G로 변경"
    qm resize $VM_ID scsi0 50G

    # [4] Cloud-init 설정 (중요: 경로 빼먹으면 안 됨!)
    # 여기서 각 노드에 맞는 user-data와 network-config 설계도를 입힙니다.
    echo ">>> [05/05] CONF: Cloud-init 설계도 주입 중..."
    echo "    (User: $VM_NAME-user.yaml / Net: $VM_NAME-net.yaml)"
    qm set $VM_ID --cicustom "user=$SNIPPET_PATH/$VM_NAME-user.yaml,network=$SNIPPET_PATH/$VM_NAME-net.yaml"

    # [5] 전원 On
    echo ">>> [START] VM 전원을 켭니다."
    qm start $VM_ID
    
    echo "✅ [SUCCESS] $VM_NAME ($VM_ID) 배포가 완료되었습니다!"
done

echo "------------------------------------------------"
echo "🏁 [FINISH] 모든 노드(Master 1, Worker 7)가 정상적으로 배포되었습니다."
