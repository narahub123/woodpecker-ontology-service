# TypeScript 규칙

- strict 모드를 유지하고 `any` 대신 검증된 구체 타입 또는 `unknown`을 사용합니다.
- 객체 형태는 `interface` 대신 `type`으로 선언합니다.
- `enum` 대신 `as const` 객체와 union 타입을 사용합니다.
- 외부 입력은 신뢰하지 않으며 경계에서 검증한 뒤 도메인 타입으로 변환합니다.
- 선택 필드와 `undefined`를 구분하고, 배열 및 맵 조회 결과가 없을 수 있음을 처리합니다.
- ESM과 NodeNext 모듈 규칙을 사용합니다.
- 파일과 심볼 이름은 역할을 드러내게 작성하고 공개 API의 타입은 명시합니다.
- 포맷은 Prettier, 정적 검사는 ESLint, 타입 검사는 TypeScript가 담당합니다.
- 검사 규칙을 비활성화할 때는 가장 좁은 범위에 이유를 남깁니다.

## 코드 주석 및 API 문서화

- 외부에서 사용되는 public type, function, class, interface에는
  의미와 계약이 코드만으로 충분히 드러나지 않는 경우 JSDoc을 작성한다.
- validator, parser, orchestration처럼 여러 단계의 검증이나 변환이 있는 로직은
  주요 단계 경계에 짧은 주석을 사용할 수 있다.
- 주석은 "무엇을 하는가"를 반복하기보다
  "왜 이 검증/분기가 필요한가" 또는 계약상 중요한 제약을 설명한다.
- 모든 타입 alias나 단순 함수에 기계적으로 JSDoc을 붙이지 않는다.
- `step1`, `step19.1`, 작업 번호, 임시 TODO 등
  내부 작업 진행용 주석은 production 코드에 남기지 않는다.
- 코드 변경 시 기존 JSDoc이나 주석이 실제 동작과 어긋나지 않는지 함께 수정한다.
