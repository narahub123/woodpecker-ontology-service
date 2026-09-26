import { Pool } from "pg";

import { type DatabaseConfig, readDatabaseConfig } from "./databaseConfig.js";

/**
 * Ontology Service의 PostgreSQL storage adapter가 공유할 connection pool을 생성한다.
 * Pool 생성과 실제 query 책임만 infrastructure 계층에 두고 상위 계층에는 pg 타입을 노출하지 않는다.
 */
export function createPostgresPool(
  config: DatabaseConfig = readDatabaseConfig(),
): Pool {
  return new Pool({
    connectionString: config.connectionString,
  });
}
