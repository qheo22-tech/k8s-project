#!/bin/bash

# ==============================================================================
# [설정 가이드] Kafka 인프라 자동 배포 스크립트
# ------------------------------------------------------------------------------
# 실행 방법:
#   1) 권한 부여: chmod +x setup_kafka.sh
#   2) 기본 실행: ./setup_kafka.sh
#   3) 명시적 실행: bash setup_kafka.sh
#
# 파라미터(옵션):
#   - ./setup_kafka.sh install  : 카프카 전체 설치 (기본값)
#   - ./setup_kafka.sh delete   : 설치된 카프카 인프라 전체 삭제 (주의!)
#
# 주의사항:
#   - 실행 전 05_storage-class(Longhorn)가 'Ready' 상태여야 함.
#   - 윈도우 VM 노드들은 반드시 시간 동기화(scripts/fix-node.sh)가 선행되어야 함.
# ==============================================================================

# --- 1. 변수 및 파라미터 체크 ---
ACTION=${1:-"install"} # 파라미터가 없으면 기본값은 "install"
STRIMZI_VERSION="0.44.0"
NAMESPACE="kafka"

# --- [삭제 모드] ---
if [ "$ACTION" == "delete" ]; then
    echo "⚠️  카프카 인프라 삭제를 시작합니다..."
    kubectl delete -f 02_kafka_topic.yaml -n $NAMESPACE --ignore-not-found
    kubectl delete -f 01_kafka_cluster.yaml -n $NAMESPACE --ignore-not-found
    kubectl delete -f 00_strimzi_operator.yaml -n $NAMESPACE --ignore-not-found
    echo "✅ 삭제 완료."
    exit 0
fi

# --- [설치 모드] ---
echo "🚀 Kafka 클러스터 배포를 시작합니다. (Mode: $ACTION)"

# 1. 네임스페이스 준비
kubectl get ns $NAMESPACE > /dev/null 2>&1 || kubectl create namespace $NAMESPACE

# 2. 오퍼레이터 다운로드 (파일이 없을 때만)
if [ ! -f "00_strimzi_operator.yaml" ]; then
    echo "📥 Strimzi Operator v${STRIMZI_VERSION} 다운로드 중..."
    URL="https://github.com/strimzi/strimzi-kafka-operator/releases/download/${STRIMZI_VERSION}/strimzi-cluster-operator-${STRIMZI_VERSION}.yaml"
    curl -L $URL -o 00_strimzi_operator.yaml
    # 파일 내 네임스페이스 일괄 변경
    sed -i "s/namespace: .*/namespace: ${NAMESPACE}/g" 00_strimzi_operator.yaml
fi

# 3. 순차적 배포
echo "📦 00. 관리자(Operator) 배포..."
kubectl apply -f 00_strimzi_operator.yaml -n $NAMESPACE

echo "⏳ 관리자가 뜰 때까지 30초 대기..."
sleep 30

echo "📦 01. 카프카 클러스터(Longhorn 연동) 배포..."
kubectl apply -f 01_kafka_cluster.yaml -n $NAMESPACE

echo "📦 02. 기본 토픽 생성..."
kubectl apply -f 02_kafka_topic.yaml -n $NAMESPACE

echo "✨ 모든 작업이 완료되었습니다!"
