# Database 개발 규칙

## 기본 구성

- persistence database는 Neon PostgreSQL을 사용하며 vector 기능은 pgvector를 사용한다.
- application에서 PostgreSQL에 접근할 때는 `pg`를 사용한다.
- migration 실행과 적용 이력 관리는 `node-pg-migrate`를 사용한다.

## Migration 작성

- migration artifact의 기본 작성 형식은 plain SQL이다.
- 새 migration은 다음 명령으로 생성한다.

```bash
npm run db:migrate:create -- <name>
```

- migration의 적용 순서를 보존한다.
- 이미 적용된 migration은 임의로 수정하지 않는 것을 원칙으로 한다.
- Issue #18의 최초 pgvector migration TypeScript → SQL 전환은 migration foundation의 작성 형식을 바로잡기 위한 의도된 예외다.
- SQL 문법 자체를 그대로 번역하는 주석은 작성하지 않는다.
- migration의 목적, 선행 조건, rollback 정책 등 코드만으로 충분히 드러나지 않는 계약상 이유는 필요한 경우 주석으로 설명한다.

## Database 검증

- schema와 constraint의 정확성은 TypeScript type-check만으로 판단하지 않는다.
- 실제 PostgreSQL에 migration을 적용하고 database integration test를 실행해 검증한다.
- migration 변경 시 적용 결과와 migration history가 의도한 계약을 유지하는지 함께 확인한다.
