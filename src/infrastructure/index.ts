/**
 * Ontology Service의 infrastructure 계층에서 외부에 공개하는 진입점이다.
 * PostgreSQL 연결과 같은 기술 세부사항은 이 계층에 한정하고
 * Domain/Application 계층이 infrastructure 구현에 의존하지 않도록 경계를 유지한다.
 */
export {
  type DatabaseConfig,
  readDatabaseConfig,
} from "./database/databaseConfig.js";
export { createPostgresPool } from "./database/postgresPool.js";
