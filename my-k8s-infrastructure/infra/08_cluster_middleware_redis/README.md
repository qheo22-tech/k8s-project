# Redis Cluster Infrastructure

## 1. 설치 및 관리 방식 (Install Method)
- 기존의 수동 YAML(00_operator, 01_cluster, 02_service) 방식은 API 버전 파편화(v1beta1/v1beta2) 및 필드 불일치 문제가 잦아 관리 효율성이 떨어짐.
- 따라서 **카프카(Kafka) 인프라와 동일하게** Helm을 사용하여 전체 설치 및 관리를 통합함.

## 2. 실제 설정 파일 경로 (Values.yaml Path)
- 이 폴더의 개별 YAML 파일은 더 이상 사용하지 않음.
- 모든 상세 설정(메모리, 롱혼 스토리지, 복제본 수 등)은 아래 경로의 Helm 전용 설정 파일에서 관리함.

> **실제 설정 파일 위치:** > `/사용자/지정/경로/to/helm/values.yaml` (예: ~/helm-charts/redis-operator/values.yaml)

## 3. 관리 명령어 (Reference Command)
- 설정 변경 시 아래 명령어를 통해 클러스터에 반영함:
  ```bash
  helm upgrade --install my-redis [HELM_CHART_PATH] \
    --namespace redis --create-namespace \
    -f [위_경로의_values.yaml]

---

### 💡 이렇게 했을 때의 장점 (사용자님의 의도 적중!)

1.  **관리 일원화:** 설정값이 여기저기 흩어져 있지 않고, 헬름이 관리하는 **'진짜 원본 파일'** 하나만 보면 됩니다.
2.  **버전 충돌 방지:** 아까 겪으셨던 `v1beta1`이니 `v1beta2`니 하는 고민을 헬름이 알아서 해결해 주므로, 사용자님은 오직 `values.yaml`의 **비즈니스 로직(메모리 용량 등)**에만 집중할 수 있습니다.
3.  **히스토리 파악:** 나중에 이 폴더에 들어온 사람은 "아, 여기 파일이 왜 없지?"라고 당황하는 대신, README를 보고 "아, 헬름으로 통합 관리 중이구나" 하고 바로 이해하게 됩니다.

---

### 🚀 다음은 무엇을 도와드릴까요?

이제 레디스 폴더는 README 하나로 깔끔하게 정리되었네요!

**혹시 카프카 폴더도 이와 동일한 양식으로 README 내용을 정리해 드릴까요?** 아니면 헬름으로 설치된 레디스가 롱혼 볼륨을 제대로 물고 올라오는지 같이 확인해 볼까요? (확인 명령어: `kubectl get pvc -n redis`)
