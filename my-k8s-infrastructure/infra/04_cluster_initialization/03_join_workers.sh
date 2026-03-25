#!/bin/bash
echo "==============================================="
echo ">>> [STEP 3] 워커 노드들을 클러스터에 조인시킵니다..."
echo "==============================================="

# 앤서블 설정 파일 생성
if [ ! -f "./ansible.cfg" ]; then
    echo "⚙️  앤서블 환경 설정을 생성합니다..."
    cat <<EOF > ./ansible.cfg
[defaults]
host_key_checking = False
display_skipped_hosts = True
EOF
fi

# 1. 조인 플레이북 실행
if [ -f "./hosts.ini" ] && [ -f "./join_cluster.yml" ]; then
    echo "🔑 SSH 및 Sudo 비밀번호 입력을 대기합니다..."
    echo "-----------------------------------------------"
    ansible-playbook -i hosts.ini join_cluster.yml -k -K
    
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "❌ 에러: 앤서블 실행 중 오류가 발생했습니다. (Exit Code: $RESULT)"
        exit 1
    fi
else
    echo "❌ 에러: hosts.ini 또는 join_cluster.yml 파일이 존재하지 않습니다."
    exit 1
fi

# ⚠️ [수정] 대기 시간 연장 (이미지 다운로드 및 CNI 바이너리 복사 시간 확보)
echo ">>> [WAIT] 조인 명령 완료. 이미지 다운로드 및 네트워크 안정화를 위해 대기합니다 (120초)..."
sleep 120

# 2. 노드 상태 확인 및 자동 복구 로직
echo ">>> [CHECK] 모든 노드의 상태를 점검합니다..."

# [수정] EXPECTED_NODES를 hosts.ini에서 자동으로 계산 (현재 5대로 되어있으나 유동적으로 대응)
# 마스터(1) + 워커 수 계산
WORKER_COUNT=$(grep -v '^#' hosts.ini | grep -A 100 '\[workers\]' | grep -E '^[0-9]' | wc -l)
EXPECTED_TOTAL=$((WORKER_COUNT + 1))

MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    READY_NODES=$(kubectl get nodes | grep -w "Ready" | wc -l)
    
    if [ "$READY_NODES" -ge "$EXPECTED_TOTAL" ]; then
        echo "✅ 결과: 모든 노드가 Ready 상태입니다! ($READY_NODES/$EXPECTED_TOTAL)"
        break
    else
        echo "⏳ 아직 준비 중... (현재 $READY_NODES/$EXPECTED_TOTAL) 20초 후 재시도..."
        
        # [수정] 첫 번째 체크에서 바로 Kubelet 재시작 시도 (심폐소생술)
        if [ $RETRY_COUNT -eq 0 ]; then
            echo "⚠️ [FIX] CNI 플러그인 인식을 위해 모든 워커의 Kubelet을 재시작합니다."
            ansible workers -i hosts.ini -m shell -a "sudo systemctl restart kubelet" -k -K
        fi
        
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 20
    fi
done

# 최종 결과 보고
if [ "$READY_NODES" -lt "$EXPECTED_TOTAL" ]; then
    echo "❌ 경고: 일부 노드가 여전히 NotReady 상태입니다. 'kubectl get nodes'로 확인하세요."
    exit 1
else
    echo "==============================================="
    echo ">>> [SUCCESS] 모든 워커 노드가 완벽하게 Ready 상태입니다!"
    echo "==============================================="
fi
