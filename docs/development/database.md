# Database 개발 규칙

## 기본 구성

- persistence database는 Neon PostgreSQL을 사용하며 vector 기능은 pgvector를 사용한다.
- application에서 PostgreSQL에 접근할 때는 `pg`를 사용한다.
- migration 실행과 적용 이력 관리는 `node-pg-migrate`를 사용한다.

## 환경변수

- PostgreSQL 연결 문자열은 `DATABASE_URL` 환경변수로 제공한다.
- Local 개발 환경에서는 저장소 루트의 `.env` 파일에서 `DATABASE_URL`을 읽는다.
- Local `.env`는 `.env.example`을 복사해 생성하며 Git에 커밋하지 않는다.
- CI에서는 GitHub Actions가 database migration job에 임시 PostgreSQL용 `DATABASE_URL`을 주입한다.
- Development 환경에서는 Northflank가 Development용 Neon PostgreSQL 연결 문자열을 `DATABASE_URL`로 Ontology Service에 주입한다.
- Production 환경에서는 Northflank가 Production용 Neon PostgreSQL 연결 문자열을 `DATABASE_URL`로 Ontology Service에 주입한다.
- Neon 연결 문자열이나 다른 credential을 저장소 파일에 커밋하지 않는다.
- Local database migration과 database integration test는 `.env`의 `DATABASE_URL`을 자동으로 읽어야 하며, 매 PowerShell 세션마다 환경변수를 수동 주입하는 방식을 요구하지 않는다.

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
