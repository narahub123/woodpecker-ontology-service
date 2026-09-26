# Git 규칙

## 브랜치와 이슈

- 공개 변경은 이슈와 연결합니다.
- 브랜치 이름은 `<type>/<issue-number>-<kebab-summary>` 형식을 사용합니다.
- 허용 브랜치 type은 `feat`, `fix`, `refactor`, `chore`, `docs`, `test`입니다.
- 작은 범위 보완은 같은 이슈에 포함할 수 있지만 목적이 달라지면 이슈를 분리합니다.

## 커밋

- 커밋 제목은 `<type>: #<issue-number> - <한국어 설명>` 형식으로 작성합니다.
- 허용 type은 `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `build`, `ci`,
  `revert`입니다.
- 한 커밋에는 하나의 설명 가능한 변경 목적만 담습니다.
- Husky의 `commit-msg` 훅과 commitlint 검사를 우회하지 않습니다.

예시:

```text
chore: #1 - 저장소 기본 설정 구성
docs: #2 - 분석 작업 API 계약 정의
feat: #8 - 비동기 분석 작업 등록 구현
```

## PR과 병합

- 작업 브랜치에서 `development`로 PR을 만들고, `development`는 별도 PR로 `main`에
  승격합니다.
- `main`과 `development`에 직접 푸시하지 않습니다.
- PR은 원칙적으로 이슈와 목적 및 범위가 일치해야 합니다.
- PR 본문에 변경 내용, 검증 결과, 편차와 남은 위험을 한국어로 기록합니다.
- Squash Merge를 사용하고 병합한 작업 브랜치는 삭제합니다.
- 다른 팀원의 승인은 요구하지 않으며 필수 승인 수는 0명으로 유지합니다.
- `Quality`, `Test`, `Commit Message`, `Dependency Audit` CI를 모두 통과해야 병합합니다.
- 병합 전에 대상 브랜치의 최신 변경을 반영합니다.
- force push와 보호 브랜치 삭제를 허용하지 않습니다.
- 현재는 merge queue를 사용하지 않습니다.

저장소가 공개되거나 비공개 저장소용 GitHub Code Security를 활성화하면 Dependency Review를
추가 필수 검사로 등록합니다.

내부 전용 문서 변경은 공개 GitHub 이슈와 PR 없이 로컬 작업 ID로 추적할 수 있습니다.
