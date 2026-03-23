#!/bin/bash
echo ">>> [STEP 0] Ansible 및 SSH 관련 패키지 설치를 시작합니다..."

# 1. 패키지 업데이트 및 설치
sudo apt update
sudo apt install -y ansible sshpass

# 2. SSH 호스트 키 체크 비활성화 (환경 변수 설정)
# 현재 세션에 적용
export ANSIBLE_HOST_KEY_CHECKING=False

# 3. 전체 시스템 설정에 반영 (나중을 위해)
if ! grep -q "host_key_checking = False" /etc/ansible/ansible.cfg 2>/dev/null; then
    sudo mkdir -p /etc/ansible
    echo "[defaults]" | sudo tee -a /etc/ansible/ansible.cfg
    echo "host_key_checking = False" | sudo tee -a /etc/ansible/ansible.cfg
fi

echo ">>> [SUCCESS] 앤서블 준비 완료!"
ansible --version
