#!/bin/bash
# label-nodes.sh - 클러스터 노드 역할 재정의 (미니PC 5대 + 외부 GPU PC)

echo ">>> [Labeling] 각 노드에 새로운 역할을 부여합니다..."

# 1. 모니터링 전용 노드 (미니PC 1)
# 그라파나, 프로메테우스 등 관제용
kubectl label node k8s-worker-01 role=monitoring grafana=true prometheus=true --overwrite

# 2. 파이썬 웹/WAS용 노드 (미니PC 2, 3)
# 파이썬으로 만든 ai-was 앱이 뜰 위치
kubectl label node k8s-worker-02 role=py-was app=ai-was --overwrite
kubectl label node k8s-worker-03 role=py-was app=ai-was --overwrite

# 3. 메시지 브로커 전용 노드 (미니PC 4)
kubectl label node k8s-worker-04 role=infra kafka=true --overwrite

# 4. 캐시 전용 노드 (미니PC 5)
kubectl label node k8s-worker-05 role=infra redis=true --overwrite

# 5. 외부 GPU PC (추론 전용)
# 스위칭 허브로 연결된 외장 그래픽 PC
kubectl label node k8s-worker-gpu role=ai-inference gpu=true --overwrite

echo "--------------------------------------------------------------------------------"
echo ">>> 설정된 라벨 현황 확인:"
kubectl get nodes -L role,app,gpu,grafana,kafka,redis
