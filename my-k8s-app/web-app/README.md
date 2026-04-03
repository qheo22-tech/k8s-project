# 🤖 Llama-3-Ko MLOps Web App

이 프로젝트는 Proxmox 및 WSL2 기반 K8s 클러스터 위에서 vLLM을 이용해 Llama-3 모델을 서빙하고, Gradio 웹 인터페이스를 통해 대화형 AI 비서를 제공합니다.

## 🚀 배포 정보
*   **Web App Image:** `qheo22/llama3-gradio-web:v4` (또는 현재 성공한 버전)
*   **Model Service:** vLLM (Llama-3-Ko-Final-F16)
*   **Namespace:** `ai-service`

## 📂 주요 파일 설명
*   `deployment.yaml`: 웹 앱(Gradio)의 배포 설정 (환경변수 및 이미지 버전 포함)
*   `service.yaml`: 웹 앱을 외부로 노출하기 위한 NodePort 설정
*   `ingress.yaml`: 도메인 기반 접근을 위한 인그레스 설정
*   `deployment.yaml_학습완성본`: 최종 성공한 설정 백업 파일

## 🛠️ 실행 방법

1. **추론 서버(Inference)가 먼저 Running 상태여야 합니다.** (포트 8000 확인)

2. **웹 앱 배포:**
   ```bash
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
