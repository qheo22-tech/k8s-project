#!/bin/bash

# ==============================================================================
# [generate_configs.sh] - 인프라 설정 제너레이터 (초간단 생성 전용)
# ==============================================================================

# 1. 설정 및 경로 정의
USER_TEMPLATE="template.yaml"
NET_TEMPLATE="network-template.yaml"
OUTPUT_DIR="nodes"
SNIPPET_DIR="/var/lib/vz/snippets"

mkdir -p "$OUTPUT_DIR"

# --- [물리 PC 1번: Main] ---
declare -A PC1_NODES=(
    ["k8s-master"]="192.168.0.10"
    ["k8s-worker-01"]="192.168.0.11"
    ["k8s-worker-02"]="192.168.0.12"
    ["k8s-worker-03"]="192.168.0.13"
    ["k8s-worker-04"]="192.168.0.14"
)

# --- [물리 PC 2번: Sub] ---
declare -A PC2_NODES=(
    ["k8s-worker-05"]="192.168.0.15"
    ["k8s-worker-06"]="192.168.0.16"
    ["k8s-worker-07"]="192.168.0.17"
)

# 설정 파일 생성 함수
generate() {
    local -n nodes=$1
    
    for name in "${!nodes[@]}"; do
        ip=${nodes[$name]}
        echo ">>> [GENERATE] ${name} (${ip}) 설정 생성 중..."
        
        # 1. Hostname과 IP 기본 치환 (sed 사용)
        sed "s/{{HOSTNAME}}/${name}/g" "$USER_TEMPLATE" > "$OUTPUT_DIR/${name}-user.yaml"
        sed "s/{{IP}}/${ip}/g" "$NET_TEMPLATE" > "$OUTPUT_DIR/${name}-net.yaml"
    done
}

echo "🚀 설정 파일 생성을 시작합니다."
generate PC1_NODES
generate PC2_NODES

# Proxmox 스니펫 폴더로 복사
echo "------------------------------------------------"
echo ">>> [COPY] 파일을 ${SNIPPET_DIR}로 이동합니다..."
cp "$OUTPUT_DIR"/*.yaml "$SNIPPET_DIR"/
chmod 644 "$SNIPPET_DIR"/*.yaml

echo "------------------------------------------------"
echo "🎉 템플릿 생성이 완료되었습니다!"
