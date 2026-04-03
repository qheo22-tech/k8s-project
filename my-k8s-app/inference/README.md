# 🧠 AI Inference Service (vLLM)

이 디렉토리는 Llama-3 모델을 vLLM 엔진을 통해 Kubernetes 클러스터에 서빙하기 위한 설정 파일들을 포함합니다.

## 🚀 서비스 개요
- **Model:** `Llama-3-Ko-Final-F16` (Fine-tuned)
- **Serving Engine:** vLLM
- **Inference Server Port:** `8000` (v1/chat/completions)

## 📂 파일 설명
- `ai-inference.yaml`: vLLM 서버 배포 설정 (GPU 할당, Liveness/Readiness Probe 최적화 완료)
- `ai-service.yaml`: 추론 서버를 클러스터 내부에 노출하기 위한 Service (ClusterIP)
- `archive/`: 초기 설정 및 성능 튜닝 과정의 히스토리 파일 보관소

## 🛠️ 주요 설정 포인트
- **Health Check (Probe):** 모델 크기로 인해 로딩 시간이 길어 (`initialDelaySeconds: 300`) 설정이 적용되어 있습니다.
- **Model Path:** 컨테이너 내부의 `/models/Llama-3-Ko-Final-F16` 경로를 참조합니다.
- **GPU Resource:** NVIDIA GPU 자원을 점유하여 추론 성능을 극대화했습니다.

## ⚠️ 주의사항
웹 서버(`web-app`)에서 요청을 보낼 때, 모델 ID를 반드시 `/models/Llama-3-Ko-Final-F16`로 지정해야 404 에러가 발생하지 않습니다.
