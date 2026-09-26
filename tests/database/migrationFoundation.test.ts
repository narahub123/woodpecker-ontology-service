import { afterAll, describe, expect, it } from "vitest";

import { createPostgresPool } from "../../src/infrastructure/index.js";

const pool = createPostgresPool();

afterAll(async () => {
  await pool.end();
});

describe("PostgreSQL migration foundation", () => {
  it("pgvector extension을 활성화한다", async () => {
    const result = await pool.query<{ extname: string }>(
      "SELECT extname FROM pg_extension WHERE extname = 'vector'",
    );

    expect(result.rows).toEqual([{ extname: "vector" }]);
  });

  it("migration 적용 이력을 기록한다", async () => {
    const result = await pool.query<{ applied: boolean }>(
      `SELECT EXISTS (
       SELECT 1
       FROM pgmigrations
       WHERE name LIKE '%enable-pgvector%'
     ) AS applied`,
    );

    expect(result.rows).toEqual([{ applied: true }]);
  });

  it("foundation 단계에서 ontology domain table을 만들지 않는다", async () => {
    const result = await pool.query<{ tablename: string }>(
      `SELECT tablename
       FROM pg_tables
       WHERE schemaname = 'public'
         AND tablename LIKE 'ontology_%'
       ORDER BY tablename`,
    );

    expect(result.rows).toEqual([]);
  });
});
