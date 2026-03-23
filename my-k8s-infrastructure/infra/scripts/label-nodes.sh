#!/bin/bash
# label-nodes.sh - 클러스터 노드 역할 및 위치 지정 스크립트

echo ">>> [Labeling] 각 노드에 고유한 역할을 부여합니다..."

# 1. 마스터 노드 (관제 및 모니터링 전용)
kubectl label node k8s-master role=master loc=main grafana=true --overwrite

# 2. 메인 구역 (Main Zone: 01~04)
kubectl label node k8s-worker-01 redis=true  loc=main --overwrite
kubectl label node k8s-worker-02 kafka=true  db-master=true loc=main --overwrite
kubectl label node k8s-worker-03 was=true    loc=main --overwrite
kubectl label node k8s-worker-04 redis=true  loc=main --overwrite

# 3. 서브 구역 (Sub Zone: 05~07 - 가용성 확보용)
kubectl label node k8s-worker-05 redis=true  kafka=true db-slave=true loc=sub --overwrite
kubectl label node k8s-worker-06 redis=true  was=true   loc=sub --overwrite
kubectl label node k8s-worker-07 redis=true  kafka=true loc=sub --overwrite

echo "--------------------------------------------------------------------------------"
echo ">>> 설정된 라벨 현황 확인:"
kubectl get nodes -L loc,grafana,redis,kafka,was,db-master,db-slave
