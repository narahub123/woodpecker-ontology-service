# 기여 가이드

이 저장소는 작업 명세, 이슈, 커밋, PR을 연결하여 변경 이유와 검증 결과를 추적합니다.
일반 작업에서는 이 문서 전체를 매번 읽지 않고 작업 명세의 `context.policies`에 지정된
작은 개발 규칙만 읽습니다.

## 시작하기

1. Node.js 24.14와 npm 11.18을 준비합니다.
2. `npm ci`로 잠금 파일과 동일한 의존성을 설치합니다.
3. 변경 전에 `.harness/tasks/current.yaml`이 가리키는 작업 명세를 확인합니다.
4. `allowed_paths` 안에서만 변경하고 완료 전에 명세의 검증 명령을 실행합니다.

## 공통 명령

| 명령                   | 용도                          |
| ---------------------- | ----------------------------- |
| `npm run format`       | 지원 파일을 Prettier로 정리   |
| `npm run format:check` | 포맷 변경 필요 여부 검사      |
| `npm run lint`         | ESLint 정적 검사              |
| `npm run type-check`   | TypeScript 타입 검사          |
| `npm test`             | Vitest 테스트 실행            |
| `npm run check`        | 포맷, 린트, 타입, 테스트 실행 |

## 개발 규칙 인덱스

| 정책 ID       | 문서                                              | 읽는 경우                         |
| ------------- | ------------------------------------------------- | --------------------------------- |
| `git`         | [Git 규칙](docs/development/git.md)               | 브랜치, 커밋, PR을 다루는 작업    |
| `typescript`  | [TypeScript 규칙](docs/development/typescript.md) | TypeScript 코드 또는 설정 작업    |
| `testing`     | [테스트 규칙](docs/development/testing.md)        | 테스트를 추가하거나 변경하는 작업 |
| `api`         | [API 규칙](docs/development/api.md)               | API 또는 계약 작업                |
| `database`    | [데이터베이스 규칙](docs/development/database.md) | Neon 스키마와 마이그레이션 작업   |
| `ai-boundary` | [AI 경계 규칙](docs/development/ai-boundary.md)   | AI 호출 또는 분석 작업            |
| `nextjs`      | [Next.js 규칙](docs/development/nextjs.md)        | 별도 UI 도입이 승인된 경우에만    |

## 언어와 공개 범위

- 코드 식별자, 명령, 경로, 기계 판독 키와 표준 고유명사는 영어로 작성합니다.
- 사람이 읽는 문서, 설명, 커밋 제목과 PR 설명은 기본적으로 한국어로 작성합니다.
- 영어 문서가 필요하면 작업 명세 또는 사용자의 명시적 결정을 먼저 기록합니다.
- `.harness`, 내부 아키텍처 문서, 로컬 환경 파일과 비밀정보는 공개 커밋에 포함하지 않습니다.

Git 흐름과 커밋 형식은 [Git 규칙](docs/development/git.md)을 따릅니다.

## CI

`development` 또는 `main` 대상 PR에서는 다음 검사를 실행합니다.

| Job                | 검사                         |
| ------------------ | ---------------------------- |
| `Quality`          | ESLint, Prettier, TypeScript |
| `Test`             | Vitest                       |
| `Commit Message`   | PR 범위의 커밋 메시지        |
| `Dependency Audit` | high 이상 npm 취약점         |

CI를 통과하지 못한 PR은 병합하지 않습니다. 서비스 실행 골격이 생기면 Build를, Stage 3
하네스가 생기면 `npm run harness`를 필수 검사에 추가합니다.
