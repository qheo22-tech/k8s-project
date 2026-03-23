#!/bin/bash
echo "==============================================="
echo ">>> [STEP 3] 워커 노드들을 클러스터에 조인시킵니다..."
echo "==============================================="

# 1. 조인 플레이북 실행 및 결과 저장
if [ -f "./hosts.ini" ] && [ -f "./join_cluster.yml" ]; then
    # 앤서블 실행 결과가 실패(exit code != 0)하면 즉시 중단
    if ! ansible-playbook -i hosts.ini join_cluster.yml -k -K; then
        echo "❌ 에러: 앤서블 플레이북 실행 중 오류가 발생했습니다."
        exit 1
    fi
else
    echo "❌ 에러: hosts.ini 또는 join_cluster.yml이 없습니다."
    exit 1
fi

echo ">>> [WAIT] 조인 명령 완료. 네트워크(CNI) 배달 및 노드 안정화 대기 (60초)..."
sleep 60

# 2. 노드 상태 확인 및 자동 복구 로직
echo ">>> [CHECK] 모든 노드의 상태를 점검합니다..."

# 기대하는 총 노드 수 (마스터 1 + 워커 4 = 5)
EXPECTED_NODES=5
MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    READY_NODES=$(kubectl get nodes | grep -w "Ready" | wc -l)
    
    if [ "$READY_NODES" -ge "$EXPECTED_NODES" ]; then
        echo "✅ 결과: 모든 노드가 Ready 상태입니다! ($READY_NODES/$EXPECTED_NODES)"
        break
    else
        echo "⏳ 아직 준비 중... (현재 $READY_NODES/$EXPECTED_NODES) 15초 후 재시도..."
        
        # 2회 이상 실패 시, 멍하니 있는 kubelet들을 강제로 깨워줍니다.
        if [ $RETRY_COUNT -eq 1 ]; then
            echo "⚠️ [FIX] 일부 노드가 NotReady입니다. Kubelet을 재시작하여 네트워크를 강제 인식시킵니다."
            ansible workers -i hosts.ini -m shell -a "sudo systemctl restart kubelet" -k -K
        fi
        
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 15
    fi
done

# 최종 결과 보고
if [ "$READY_NODES" -lt "$EXPECTED_NODES" ]; then
    echo "❌ 경고: 일부 노드가 여전히 NotReady 상태입니다. 'kubectl get nodes'로 확인하세요."
    exit 1
else
    echo "==============================================="
    echo ">>> [SUCCESS] 모든 워커 노드가 완벽하게 Ready 상태입니다!"
    echo "==============================================="
fi
