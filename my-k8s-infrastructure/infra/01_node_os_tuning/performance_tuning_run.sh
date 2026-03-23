#!/bin/bash
# =========================================================
# [01_os_tuning_run.sh]
# 용도: 노드 전용 커널 및 리밋 최적화
# 특징: Cloud-init 실행 시 상대 경로 문제를 해결하기 위해 절대 경로 로직 포함
# =========================================================

# [중요] 스크립트가 위치한 실제 디렉토리로 이동 (상대 경로 에러 방지)
cd "$(dirname "$0")"
SCRIPT_DIR=$(pwd)

echo ">>> [01_os_tuning] 시스템 맷집 강화를 시작합니다. (작업 디렉토리: $SCRIPT_DIR)"

# 1. 공통 리밋 설정 (File Descriptor 확장)
if [ -f "$SCRIPT_DIR/common/99-limits.conf" ]; then
    sudo cp "$SCRIPT_DIR/common/99-limits.conf" /etc/security/limits.d/
    echo "[1/3] 공통 limits 설정 완료"
else
    echo "ℹ️ 정보: common/99-limits.conf가 없습니다. (필요 시 추후 추가 가능)"
fi

# 2. 성능 최적화 커널 파라미터 적용 (sysctl) 
# [수정됨] 경로를 실제 파일 위치인 performance/99-performance.conf로 변경
if [ -f "$SCRIPT_DIR/performance/99-performance.conf" ]; then
    sudo cp "$SCRIPT_DIR/performance/99-performance.conf" /etc/sysctl.d/
    echo "[2/3] 성능 최적화 커널 설정(99-performance.conf) 복사 완료"
else
    echo "❌ 에러: $SCRIPT_DIR/performance/99-performance.conf 파일을 찾을 수 없습니다."
    exit 1
fi

# 3. 설정 즉시 반영
sudo sysctl --system
echo "[3/3] 커널 파라미터 즉시 반영 완료"

echo "✅ [01_os_tuning] 모든 튜닝이 완료되었습니다!"
