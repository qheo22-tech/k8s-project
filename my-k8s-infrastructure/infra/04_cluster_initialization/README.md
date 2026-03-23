# 04. 쿠버네티스 클러스터 자동화 배포 (Master & Worker)

이 폴더의 스크립트들은 환경 설정부터 마스터 초기화, 워커 노드 연결까지의 전 과정을 자동화합니다.

## 📂 파일 구조 및 역할
0.  **`00_prepare_ansible.sh`**: **(필수)** Ansible 및 SSH 통신을 위한 기본 패키지 설치 및 설정
1.  **`01_master_init.sh`**: 마스터 노드 초기화 (`kubeadm init`)
2.  **`02_install_calico.sh`**: 네트워크(CNI) 설치 (Pod 간 통신 설정)
3.  **`03_join_workers.sh`**: 앤서블을 이용한 워커 노드 자동 조인 (**비밀번호 입력 필요**)
4.  **`setup_master.sh`**: 위 1~3번을 순서대로 실행하는 통합 실행 파일

## 📌 사전 준비 사항
1.  **`00_prepare_ansible.sh` 실행**: 가장 먼저 실행하여 관리 환경을 조성해야 합니다.
2.  **`hosts.ini` 확인**: `[workers]` 섹션에 워커 노드 7대의 IP가 정확히 적혀 있어야 합니다.
3.  **권한 부여**: 실행 전 모든 `.sh` 파일에 실행 권한이 있어야 합니다. (`chmod +x *.sh`)

## 🚀 설치 순서 (Step-by-Step)

### Step 0: 관리 환경 준비 (Ansible 설치)
```bash
./00_prepare_ansible.sh
