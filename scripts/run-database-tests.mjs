import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

import pg from "pg";

const { Client } = pg;

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is required to run database tests.");
}

const databaseTestsDirectory = fileURLToPath(
  new URL("../tests/database/", import.meta.url),
);

const entries = await readdir(databaseTestsDirectory, { withFileTypes: true });
const sqlTestFiles = entries
  .filter((entry) => entry.isFile() && entry.name.endsWith(".sql"))
  .map((entry) => entry.name)
  .sort();

if (sqlTestFiles.length === 0) {
  throw new Error("No SQL database tests found.");
}

const client = new Client({ connectionString });

await client.connect();

try {
  for (const filename of sqlTestFiles) {
    const sql = await readFile(join(databaseTestsDirectory, filename), "utf8");

    process.stdout.write(`[database-test] ${filename}\n`);

    try {
      await client.query(sql);
    } catch (error) {
      throw new Error(`Database test failed: ${filename}`, { cause: error });
    }
  }
} finally {
  await client.end();
}
