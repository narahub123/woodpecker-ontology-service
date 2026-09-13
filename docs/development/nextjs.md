# Next.js 규칙

이 정책은 기본 적용 대상이 아닙니다. 별도 관리자 페이지 또는 Woodpecker 통합 UI를
Next.js로 구현하기로 사용자가 승인하고 작업 명세의 `context.policies`에 `nextjs`가 포함된
경우에만 적용합니다.

- App Router, 클라이언트 경계, 캐시와 렌더링 전략은 승인된 UI 요구사항에 맞춰 별도로
  정합니다.
- Woodpecker 버튼, 결과 패널, 편집 UI, Service Worker, Web Push와 알림 Cron은 현재 MVP
  범위에 포함하지 않습니다.
- Next.js 또는 Vercel 규칙을 백엔드 API와 Worker에 관성적으로 적용하지 않습니다.
- 백엔드 API와 Worker의 독립 배포 경계를 유지합니다.
