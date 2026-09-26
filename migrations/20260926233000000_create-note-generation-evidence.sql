CREATE TABLE ontology_note_states (
  user_id UUID NOT NULL,
  note_id UUID NOT NULL,
  source_hash TEXT NOT NULL,
  source_updated_at TIMESTAMPTZ NOT NULL,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  active_generation_id UUID,
  retired_generation_id UUID,

  CONSTRAINT ontology_note_states_pkey
    PRIMARY KEY (user_id, note_id),

  CONSTRAINT ontology_note_states_source_hash_nonempty_check
    CHECK (btrim(source_hash) <> ''),

  CONSTRAINT ontology_note_states_generation_pointers_distinct_check
    CHECK (
      active_generation_id IS NULL
      OR retired_generation_id IS NULL
      OR active_generation_id <> retired_generation_id
    )
);

CREATE TABLE ontology_generations (
  id UUID NOT NULL,
  user_id UUID NOT NULL,
  note_id UUID NOT NULL,
  source_hash TEXT NOT NULL,
  source_updated_at TIMESTAMPTZ NOT NULL,
  analysis_registry_version BIGINT NOT NULL,
  parser_version TEXT NOT NULL,
  extractor_version TEXT NOT NULL,

  CONSTRAINT ontology_generations_pkey
    PRIMARY KEY (id),

  CONSTRAINT ontology_generations_note_state_fk
    FOREIGN KEY (user_id, note_id)
    REFERENCES ontology_note_states (user_id, note_id),

  CONSTRAINT ontology_generations_user_note_id_unique
    UNIQUE (user_id, note_id, id),

  CONSTRAINT ontology_generations_source_hash_nonempty_check
    CHECK (btrim(source_hash) <> ''),

  CONSTRAINT ontology_generations_registry_version_nonnegative_check
    CHECK (analysis_registry_version >= 0),

  CONSTRAINT ontology_generations_parser_version_nonempty_check
    CHECK (btrim(parser_version) <> ''),

  CONSTRAINT ontology_generations_extractor_version_nonempty_check
    CHECK (btrim(extractor_version) <> '')
);

ALTER TABLE ontology_note_states
  ADD CONSTRAINT ontology_note_states_active_generation_fk
  FOREIGN KEY (user_id, note_id, active_generation_id)
  REFERENCES ontology_generations (user_id, note_id, id);

ALTER TABLE ontology_note_states
  ADD CONSTRAINT ontology_note_states_retired_generation_fk
  FOREIGN KEY (user_id, note_id, retired_generation_id)
  REFERENCES ontology_generations (user_id, note_id, id);

CREATE TABLE ontology_text_units (
  generation_id UUID NOT NULL,
  unit_key TEXT NOT NULL,
  block_ids TEXT[] NOT NULL,
  section_path TEXT[] NOT NULL DEFAULT '{}',
  line INTEGER NOT NULL,
  column INTEGER NOT NULL,
  start_offset INTEGER NOT NULL,
  end_offset INTEGER NOT NULL,
  analysis_text TEXT NOT NULL,

  CONSTRAINT ontology_text_units_pkey
    PRIMARY KEY (generation_id, unit_key),

  CONSTRAINT ontology_text_units_generation_fk
    FOREIGN KEY (generation_id)
    REFERENCES ontology_generations (id)
    ON DELETE CASCADE,

  CONSTRAINT ontology_text_units_unit_key_nonempty_check
    CHECK (btrim(unit_key) <> ''),

  CONSTRAINT ontology_text_units_block_ids_nonempty_check
    CHECK (cardinality(block_ids) > 0),

  CONSTRAINT ontology_text_units_line_check
    CHECK (line >= 1),

  CONSTRAINT ontology_text_units_column_check
    CHECK (column >= 1),

  CONSTRAINT ontology_text_units_offset_check
    CHECK (
      start_offset >= 0
      AND end_offset >= start_offset
    )
);

CREATE TABLE ontology_evidence_anchors (
  generation_id UUID NOT NULL,
  evidence_key TEXT NOT NULL,
  source_kind TEXT NOT NULL,
  text_unit_key TEXT,
  line INTEGER,
  column INTEGER,
  start_offset INTEGER,
  end_offset INTEGER,
  raw_excerpt TEXT NOT NULL,
  excerpt_hash TEXT NOT NULL,

  CONSTRAINT ontology_evidence_anchors_pkey
    PRIMARY KEY (generation_id, evidence_key),

  CONSTRAINT ontology_evidence_anchors_generation_fk
    FOREIGN KEY (generation_id)
    REFERENCES ontology_generations (id)
    ON DELETE CASCADE,

  CONSTRAINT ontology_evidence_anchors_text_unit_fk
    FOREIGN KEY (generation_id, text_unit_key)
    REFERENCES ontology_text_units (generation_id, unit_key)
    ON DELETE CASCADE,

  CONSTRAINT ontology_evidence_anchors_evidence_key_nonempty_check
    CHECK (btrim(evidence_key) <> ''),

  CONSTRAINT ontology_evidence_anchors_source_kind_nonempty_check
    CHECK (btrim(source_kind) <> ''),

  CONSTRAINT ontology_evidence_anchors_excerpt_hash_nonempty_check
    CHECK (btrim(excerpt_hash) <> ''),

  CONSTRAINT ontology_evidence_anchors_position_check
    CHECK (
      (
        line IS NULL
        AND column IS NULL
      )
      OR (
        line >= 1
        AND column >= 1
      )
    )
    AND (
      (
        start_offset IS NULL
        AND end_offset IS NULL
      )
      OR (
        start_offset >= 0
        AND end_offset >= start_offset
      )
    )
);

CREATE TABLE ontology_generation_ai_runtime_references (
  generation_id UUID NOT NULL,
  role_key TEXT NOT NULL,
  kind TEXT NOT NULL,
  model_config_id UUID NOT NULL,
  prompt_version_id UUID,
  temperature NUMERIC,
  prompt_behavior_hash TEXT,
  model_behavior_hash TEXT NOT NULL,

  CONSTRAINT ontology_generation_ai_runtime_references_pkey
    PRIMARY KEY (generation_id, role_key),

  CONSTRAINT ontology_generation_ai_runtime_references_generation_fk
    FOREIGN KEY (generation_id)
    REFERENCES ontology_generations (id)
    ON DELETE CASCADE,

  CONSTRAINT ontology_generation_ai_runtime_references_role_check
    CHECK (
      role_key IN (
        'semantic-extraction',
        'code-block-classification',
        'schema-semantic-comparison',
        'entity-semantic-comparison',
        'semantic-retrieval'
      )
    ),

  CONSTRAINT ontology_generation_ai_runtime_references_kind_check
    CHECK (kind IN ('chat', 'embedding')),

  CONSTRAINT ontology_generation_ai_runtime_references_model_behavior_hash_nonempty_check
    CHECK (btrim(model_behavior_hash) <> ''),

  CONSTRAINT ontology_generation_ai_runtime_references_consistency_check
    CHECK (
      (
        kind = 'chat'
        AND prompt_version_id IS NOT NULL
        AND temperature IS NOT NULL
        AND prompt_behavior_hash IS NOT NULL
        AND btrim(prompt_behavior_hash) <> ''
      )
      OR
      (
        kind = 'embedding'
        AND prompt_version_id IS NULL
        AND temperature IS NULL
        AND prompt_behavior_hash IS NULL
      )
    )
);
