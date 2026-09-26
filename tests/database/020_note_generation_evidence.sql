BEGIN;

DO $$
DECLARE
  actual_tables TEXT[];
  expected_tables CONSTANT TEXT[] := ARRAY[
    'ontology_evidence_anchors',
    'ontology_generation_ai_runtime_references',
    'ontology_generations',
    'ontology_note_states',
    'ontology_text_units'
  ];
BEGIN
  SELECT array_agg(tablename ORDER BY tablename)
    INTO actual_tables
  FROM pg_tables
  WHERE schemaname = 'public'
    AND tablename = ANY(expected_tables);

  IF actual_tables IS DISTINCT FROM expected_tables THEN
    RAISE EXCEPTION 'Note Generation / Evidence tables mismatch: %', actual_tables;
  END IF;
END
$$;

INSERT INTO ontology_note_states (
  user_id,
  note_id,
  source_hash,
  source_updated_at
) VALUES
(
  '00000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  'source-hash-a',
  '2026-09-26T00:00:00Z'
),
(
  '00000000-0000-4000-8000-000000000002',
  '10000000-0000-4000-8000-000000000001',
  'source-hash-b',
  '2026-09-26T00:00:00Z'
);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_note_states (
      user_id,
      note_id,
      source_hash,
      source_updated_at
    ) VALUES (
      '00000000-0000-4000-8000-000000000003',
      '10000000-0000-4000-8000-000000000003',
      '',
      '2026-09-26T00:00:00Z'
    );
    RAISE EXCEPTION 'empty source hash was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_generations (
  id,
  user_id,
  note_id,
  source_hash,
  source_updated_at,
  analysis_registry_version,
  parser_version,
  extractor_version
) VALUES
(
  '20000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  'source-hash-a',
  '2026-09-26T00:00:00Z',
  1,
  'parser-v1',
  'extractor-v1'
),
(
  '20000000-0000-4000-8000-000000000002',
  '00000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  'source-hash-a',
  '2026-09-26T00:00:00Z',
  1,
  'parser-v1',
  'extractor-v1'
),
(
  '20000000-0000-4000-8000-000000000003',
  '00000000-0000-4000-8000-000000000002',
  '10000000-0000-4000-8000-000000000001',
  'source-hash-b',
  '2026-09-26T00:00:00Z',
  1,
  'parser-v1',
  'extractor-v1'
);

UPDATE ontology_note_states
SET
  active_generation_id = '20000000-0000-4000-8000-000000000001',
  retired_generation_id = '20000000-0000-4000-8000-000000000002'
WHERE user_id = '00000000-0000-4000-8000-000000000001'
  AND note_id = '10000000-0000-4000-8000-000000000001';

DO $$
BEGIN
  BEGIN
    UPDATE ontology_note_states
    SET retired_generation_id = active_generation_id
    WHERE user_id = '00000000-0000-4000-8000-000000000001'
      AND note_id = '10000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'same active and retired generation was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    UPDATE ontology_note_states
    SET active_generation_id = '20000000-0000-4000-8000-000000000003'
    WHERE user_id = '00000000-0000-4000-8000-000000000001'
      AND note_id = '10000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'cross-user generation pointer was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_generations (
      id,
      user_id,
      note_id,
      source_hash,
      source_updated_at,
      analysis_registry_version,
      parser_version,
      extractor_version
    ) VALUES (
      '20000000-0000-4000-8000-000000000004',
      '00000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000001',
      'source-hash-a',
      '2026-09-26T00:00:00Z',
      -1,
      'parser-v1',
      'extractor-v1'
    );
    RAISE EXCEPTION 'negative registry version was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_generations (
      id,
      user_id,
      note_id,
      source_hash,
      source_updated_at,
      analysis_registry_version,
      parser_version,
      extractor_version
    ) VALUES (
      '20000000-0000-4000-8000-000000000004',
      '00000000-0000-4000-8000-000000000009',
      '10000000-0000-4000-8000-000000000009',
      'source-hash',
      '2026-09-26T00:00:00Z',
      1,
      'parser-v1',
      'extractor-v1'
    );
    RAISE EXCEPTION 'generation without owned note state was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_text_units (
  generation_id,
  unit_key,
  block_ids,
  section_path,
  line,
  column,
  start_offset,
  end_offset,
  analysis_text
) VALUES (
  '20000000-0000-4000-8000-000000000001',
  'unit-1',
  ARRAY['block-1', 'block-2'],
  ARRAY['Heading'],
  1,
  1,
  0,
  20,
  '# Heading\nParagraph'
);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_text_units (
      generation_id,
      unit_key,
      block_ids,
      section_path,
      line,
      column,
      start_offset,
      end_offset,
      analysis_text
    ) VALUES (
      '20000000-0000-4000-8000-000000000001',
      'unit-empty-blocks',
      '{}',
      '{}',
      1,
      1,
      0,
      0,
      ''
    );
    RAISE EXCEPTION 'empty block_ids were accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_text_units (
      generation_id,
      unit_key,
      block_ids,
      section_path,
      line,
      column,
      start_offset,
      end_offset,
      analysis_text
    ) VALUES (
      '20000000-0000-4000-8000-000000000001',
      'unit-invalid-offset',
      ARRAY['block-1'],
      '{}',
      1,
      1,
      10,
      5,
      'text'
    );
    RAISE EXCEPTION 'invalid text-unit offsets were accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_evidence_anchors (
  generation_id,
  evidence_key,
  source_kind,
  text_unit_key,
  line,
  column,
  start_offset,
  end_offset,
  raw_excerpt,
  excerpt_hash
) VALUES (
  '20000000-0000-4000-8000-000000000001',
  'evidence-1',
  'note_markdown',
  'unit-1',
  2,
  1,
  10,
  20,
  'Paragraph',
  'excerpt-hash-1'
);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_evidence_anchors (
      generation_id,
      evidence_key,
      source_kind,
      text_unit_key,
      line,
      column,
      start_offset,
      end_offset,
      raw_excerpt,
      excerpt_hash
    ) VALUES (
      '20000000-0000-4000-8000-000000000001',
      'missing-unit',
      'note_markdown',
      'unit-missing',
      1,
      1,
      0,
      1,
      'x',
      'hash'
    );
    RAISE EXCEPTION 'missing text unit reference was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_evidence_anchors (
      generation_id,
      evidence_key,
      source_kind,
      text_unit_key,
      line,
      column,
      start_offset,
      end_offset,
      raw_excerpt,
      excerpt_hash
    ) VALUES (
      '20000000-0000-4000-8000-000000000001',
      'bad-position',
      'note_markdown',
      NULL,
      0,
      1,
      5,
      3,
      'x',
      'hash'
    );
    RAISE EXCEPTION 'invalid evidence position was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_evidence_anchors (
      generation_id,
      evidence_key,
      source_kind,
      text_unit_key,
      line,
      column,
      start_offset,
      end_offset,
      raw_excerpt,
      excerpt_hash
    ) VALUES (
      '20000000-0000-4000-8000-000000000001',
      'partial-position',
      'user_input',
      NULL,
      1,
      NULL,
      NULL,
      NULL,
      'x',
      'hash'
    );
    RAISE EXCEPTION 'partial line/column position was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_generation_ai_runtime_references (
  generation_id,
  role_key,
  kind,
  model_config_id,
  prompt_version_id,
  temperature,
  prompt_behavior_hash,
  model_behavior_hash
) VALUES
(
  '20000000-0000-4000-8000-000000000001',
  'semantic-extraction',
  'chat',
  '30000000-0000-4000-8000-000000000001',
  '40000000-0000-4000-8000-000000000001',
  0.2,
  'prompt-hash',
  'model-hash'
),
(
  '20000000-0000-4000-8000-000000000001',
  'semantic-retrieval',
  'embedding',
  '30000000-0000-4000-8000-000000000002',
  NULL,
  NULL,
  NULL,
  'embedding-model-hash'
);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_generation_ai_runtime_references (
      generation_id,
      role_key,
      kind,
      model_config_id,
      prompt_version_id,
      temperature,
      prompt_behavior_hash,
      model_behavior_hash
    ) VALUES (
      '20000000-0000-4000-8000-000000000001',
      'unknown-role',
      'chat',
      '30000000-0000-4000-8000-000000000001',
      '40000000-0000-4000-8000-000000000001',
      0.2,
      'prompt-hash',
      'model-hash'
    );
    RAISE EXCEPTION 'unknown runtime role was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_generation_ai_runtime_references (
      generation_id,
      role_key,
      kind,
      model_config_id,
      prompt_version_id,
      temperature,
      prompt_behavior_hash,
      model_behavior_hash
    ) VALUES (
      '20000000-0000-4000-8000-000000000002',
      'semantic-extraction',
      'chat',
      '30000000-0000-4000-8000-000000000001',
      NULL,
      0.2,
      'prompt-hash',
      'model-hash'
    );
    RAISE EXCEPTION 'chat runtime without prompt version was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_generation_ai_runtime_references (
      generation_id,
      role_key,
      kind,
      model_config_id,
      prompt_version_id,
      temperature,
      prompt_behavior_hash,
      model_behavior_hash
    ) VALUES (
      '20000000-0000-4000-8000-000000000002',
      'semantic-retrieval',
      'embedding',
      '30000000-0000-4000-8000-000000000002',
      '40000000-0000-4000-8000-000000000001',
      NULL,
      NULL,
      'model-hash'
    );
    RAISE EXCEPTION 'embedding runtime with prompt version was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_generations (
  id,
  user_id,
  note_id,
  source_hash,
  source_updated_at,
  analysis_registry_version,
  parser_version,
  extractor_version
) VALUES (
  '20000000-0000-4000-8000-000000000005',
  '00000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  'source-hash-a',
  '2026-09-26T00:00:00Z',
  1,
  'parser-v1',
  'extractor-v1'
);

INSERT INTO ontology_text_units (
  generation_id,
  unit_key,
  block_ids,
  section_path,
  line,
  column,
  start_offset,
  end_offset,
  analysis_text
) VALUES (
  '20000000-0000-4000-8000-000000000005',
  'cascade-unit',
  ARRAY['block-1'],
  '{}',
  1,
  1,
  0,
  1,
  'x'
);

INSERT INTO ontology_evidence_anchors (
  generation_id,
  evidence_key,
  source_kind,
  text_unit_key,
  line,
  column,
  start_offset,
  end_offset,
  raw_excerpt,
  excerpt_hash
) VALUES (
  '20000000-0000-4000-8000-000000000005',
  'cascade-evidence',
  'note_markdown',
  'cascade-unit',
  1,
  1,
  0,
  1,
  'x',
  'cascade-hash'
);

INSERT INTO ontology_generation_ai_runtime_references (
  generation_id,
  role_key,
  kind,
  model_config_id,
  prompt_version_id,
  temperature,
  prompt_behavior_hash,
  model_behavior_hash
) VALUES (
  '20000000-0000-4000-8000-000000000005',
  'semantic-retrieval',
  'embedding',
  '30000000-0000-4000-8000-000000000002',
  NULL,
  NULL,
  NULL,
  'cascade-model-hash'
);

DELETE FROM ontology_generations
WHERE id = '20000000-0000-4000-8000-000000000005';

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM ontology_text_units
    WHERE generation_id = '20000000-0000-4000-8000-000000000005'
  ) THEN
    RAISE EXCEPTION 'text-unit cascade failed';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM ontology_evidence_anchors
    WHERE generation_id = '20000000-0000-4000-8000-000000000005'
  ) THEN
    RAISE EXCEPTION 'evidence cascade failed';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM ontology_generation_ai_runtime_references
    WHERE generation_id = '20000000-0000-4000-8000-000000000005'
  ) THEN
    RAISE EXCEPTION 'runtime-reference cascade failed';
  END IF;
END
$$;

ROLLBACK;
