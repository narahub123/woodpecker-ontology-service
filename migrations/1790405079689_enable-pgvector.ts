import type { MigrationBuilder } from "node-pg-migrate";

/**
 * Ontology persistence가 vector 타입을 사용할 수 있도록 pgvector extension을 활성화한다.
 * 이 migration은 이후 schema의 공통 prerequisite이므로 rollback 대상으로 취급하지 않는다.
 */
export async function up(pgm: MigrationBuilder): Promise<void> {
  pgm.createExtension("vector", {
    ifNotExists: true,
  });
}

export const down = false;
