#!/bin/bash
# =========================================================
# [Node OS 초기화 스크립트 - 수정본]
# 용도: 키 등록은 지원하되, 비밀번호 접속을 차단하지 않음 (앤서블/마스터 노드 접속 허용)
# =========================================================

# 1. 호스트네임 설정
NEW_HOSTNAME=$1
if [ -z "$NEW_HOSTNAME" ]; then
    NEW_HOSTNAME=$(hostname)
    echo "ℹ️ 현재 시스템 호스트네임($NEW_HOSTNAME)을 사용합니다."
fi

echo ">>> [1/5] 호스트네임 설정: $NEW_HOSTNAME"
sudo hostnamectl set-hostname $NEW_HOSTNAME
if ! grep -q "$NEW_HOSTNAME" /etc/hosts; then
    echo "127.0.1.1 $NEW_HOSTNAME" | sudo tee -a /etc/hosts
fi

# 2. Swap 비활성화
echo ">>> [2/5] Swap Off 설정"
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

# 3. 커널 모듈 로드
echo ">>> [3/5] 커널 모듈 로드"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# 4. 네트워크 브릿지 설정
echo ">>> [4/5] sysctl 네트워크 설정"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# 5. SSH 설정 (키 등록은 유지, 비밀번호 접속은 허용)
echo ">>> [5/5] SSH 설정: 키 등록 및 접속 허용 유지"

# 맥북 등 관리자용 공개키 (여기에 마스터 노드 키를 추가해도 됩니다)
MY_PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCk/Cl5k7t8GmyNy0/Mp39BT4KPUDTW/tp5GSDl/W1OgiM/7XlmIMsCF9FHlyf/LGRo0L/pVQjiwY3N6KvirY0wdIMt93H1JkQ/KMZYPil4RuV2NdZjP4tMGPeuqvJSZ0NGKaPRgf2aAy+5uDf0UdA2Sbje6c6V+ycYJVb1Y9IGid0c4TUB+BfEs7w7i8yfUStZcDO1LDUOWjtENvv1mM0Sjuon13bfuTjCdnj5cqO1FpuyL1SNFyKDIhd+KchVaXDX1j4DmvsSiy3IulonMZQpJrFpKCijR6H8XD21NN1x8f5dVMCrjRVS7wCH872jFgx5EDcHSH966ojwLd3XfS00gys2Me/Z2gaM2Kb/nV347wx7qf3fNaC+ejr0pDLqU/9wmQh6ioWizS9ZApA9RKGx0Kwu7pg/6etnNz8zGuSgfpgNAvyb1U9e896m748N1To6nLD92XpwpnoRZk1qK5Ri9dI3DR/zzxvPS4FQEJlBVmYhQ9+2I7wuRR7nqzgOhiNkSmEd503BdlXnJ+OCDMQBncC1ALySkU4klZx2opUbggvERKWkRSXtPi/6G203CnS1YG0xurpVnwwAZ8G2nAlbu4RmZBGhc1LjbtFcc7BtTbDyWeldFtm+vSvyAmCpAuImm4dnBFuCVwTDGdhlY8JiwR8YPx0OFik7Kw/aJuOCSw== seowolseong@seowolseong-ui-MacBookPro.local"

if [ ! -z "$MY_PUB_KEY" ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # 키가 이미 있으면 중복 등록 안 함
    if ! grep -q "$MY_PUB_KEY" ~/.ssh/authorized_keys 2>/dev/null; then
        echo "$MY_PUB_KEY" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        echo "결과: SSH 공개키가 등록되었습니다."
    fi

    # 핵심 수정 부분: PasswordAuthentication을 'yes'로 유지하거나 명시적으로 설정함
    # 보안상 no였던 설정을 yes로 돌리고, 루트 로그인은 선택에 따라 허용함
    sudo sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
    
    sudo systemctl restart ssh
    echo "✅ 결과: 키 등록 완료 및 비밀번호 접속 허용 상태 유지"
else
    echo "⚠️ MY_PUB_KEY가 비어 있어 SSH 키 등록을 건너뜁니다."
fi

echo ">>> [DONE] 00_os_init 단계 완료!"

