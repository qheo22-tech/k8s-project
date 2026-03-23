#!/bin/bash
echo "==============================================="
echo ">>> [STEP 3] 워커 노드들을 클러스터에 조인시킵니다..."
echo "==============================================="

# hosts.ini와 플레이북 존재 확인 후 실행
if [ -f "./hosts.ini" ] && [ -f "./join_cluster.yml" ]; then
    # -k: SSH 접속 암호 묻기, -K: sudo 권한 암호 묻기
    ansible-playbook -i hosts.ini join_cluster.yml -k -K
else
    echo "❌ 에러: hosts.ini 또는 join_cluster.yml이 없습니다."
    exit 1
fi

echo "==============================================="
echo ">>> [SUCCESS] 모든 워커 노드가 조인되었습니다!"
echo "==============================================="
