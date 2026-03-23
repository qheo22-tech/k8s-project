#!/bin/bash

# 1. 배포할 노드 정의 (ID: 이름)
declare -A NODES=(
    ["100"]="k8s-master"
#    ["101"]="k8s-worker-01"
#    ["102"]="k8s-worker-02"
#    ["103"]="k8s-worker-03"
#    ["104"]="k8s-worker-04"
)

TEMPLATE_ID=9000
SNIPPET_PATH="local:snippets"

echo "🚀 [START] K8s 노드 자동 배포 (CPU: 2, RAM: 4G, DISK: 50G)"

for VM_ID in "${!NODES[@]}"; do
    VM_NAME=${NODES[$VM_ID]}
    
    echo "------------------------------------------------"
    echo ">>> [VM $VM_ID] $VM_NAME 생성 시작"

    # 기존 VM 삭제 (재설치 대비)
    echo ">>> [CLEAN] 기존 VM $VM_ID 정리 중..."
    qm stop $VM_ID 2>/dev/null
    qm destroy $VM_ID 2>/dev/null

    # 1. 템플릿 복제
    echo ">>> [CLONE] 템플릿 $TEMPLATE_ID로부터 복제 중..."
    qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full

    # [WAIT] 복제 완료 및 디스크 인식을 위해 대기
    echo ">>> [WAIT] 장치 인식 대기 중..."
    until qm config $VM_ID | grep -q "scsi0"; do sleep 1; done
    sleep 2

    # 2. [하드웨어 설정] 심장(CPU)과 근육(RAM) 키우기
    # K8s 마스터 노드 필수 조건: CPU 2코어 이상
    echo ">>> [HW] CPU 2코어, 메모리 4GB(4096MB) 설정 주입"
    qm set $VM_ID --cores 2 --memory 4096

    # 3. [디스크 확장] 땅(Disk) 넓히기
    echo ">>> [DISK] 물리 디스크를 50G로 확장합니다."
    qm resize $VM_ID scsi0 50G

    # 4. Cloud-init 설정 (정신 교육: 설계도 연결)
    echo ">>> [CONF] Cloud-init 설계도 주입 중..."
    qm set $VM_ID --cicustom "user=$SNIPPET_PATH/$VM_NAME-user.yaml,network=$SNIPPET_PATH/$VM_NAME-net.yaml"

    # 5. 부팅!
    echo ">>> [START] VM 전원 켜는 중..."
    qm start $VM_ID
    
    echo ">>> [SUCCESS] $VM_NAME ($VM_ID) 배포 완료!"
done

echo "------------------------------------------------"
echo "✅ 모든 노드가 최적의 사양(2코어/4G/50G)으로 배포되었습니다."
