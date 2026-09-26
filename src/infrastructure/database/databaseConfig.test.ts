import { describe, expect, it } from "vitest";

import { readDatabaseConfig } from "./databaseConfig.js";

describe("readDatabaseConfig", () => {
  it("유효한 PostgreSQL URL을 connection 설정으로 반환한다", () => {
    const config = readDatabaseConfig({
      DATABASE_URL:
        "postgresql://postgres:postgres@localhost:5432/ontology_test",
    });

    expect(config).toEqual({
      connectionString:
        "postgresql://postgres:postgres@localhost:5432/ontology_test",
    });
  });

  it("DATABASE_URL이 없으면 실패한다", () => {
    expect(() => readDatabaseConfig({})).toThrow("DATABASE_URL is required.");
  });

  it("PostgreSQL이 아닌 URL이면 실패한다", () => {
    expect(() =>
      readDatabaseConfig({
        DATABASE_URL: "https://example.com/database",
      }),
    ).toThrow("DATABASE_URL must use postgres: or postgresql:.");
  });
});
