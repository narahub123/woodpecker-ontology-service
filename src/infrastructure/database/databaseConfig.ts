export type DatabaseConfig = {
  readonly connectionString: string;
};

/**
 * PostgreSQL adapter가 사용할 database connection 설정을 runtime environment에서 읽는다.
 * credential source를 infrastructure boundary에 제한해 Domain/Application이 환경변수에 의존하지 않게 한다.
 */
export function readDatabaseConfig(
  environment: NodeJS.ProcessEnv = process.env,
): DatabaseConfig {
  const connectionString = environment.DATABASE_URL?.trim();

  if (connectionString === undefined || connectionString.length === 0) {
    throw new Error("DATABASE_URL is required.");
  }

  let databaseUrl: URL;

  try {
    databaseUrl = new URL(connectionString);
  } catch {
    throw new Error("DATABASE_URL must be a valid PostgreSQL URL.");
  }

  if (
    databaseUrl.protocol !== "postgres:" &&
    databaseUrl.protocol !== "postgresql:"
  ) {
    throw new Error("DATABASE_URL must use postgres: or postgresql:.");
  }

  return { connectionString };
}
