DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_extension
    WHERE extname = 'vector'
  ) THEN
    RAISE EXCEPTION 'pgvector extension is not enabled';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pgmigrations
    WHERE name LIKE '%enable-pgvector%'
  ) THEN
    RAISE EXCEPTION 'enable-pgvector migration history is missing';
  END IF;
END
$$;
