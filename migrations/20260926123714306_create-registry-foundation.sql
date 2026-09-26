-- Up Migration

CREATE TABLE ontology_registry_state (
  user_id UUID NOT NULL,
  version BIGINT NOT NULL,
  seed_version BIGINT NOT NULL,
  CONSTRAINT ontology_registry_state_pkey PRIMARY KEY (user_id),
  CONSTRAINT ontology_registry_state_version_nonnegative_check CHECK (version >= 0),
  CONSTRAINT ontology_registry_state_seed_version_nonnegative_check CHECK (seed_version >= 0)
);

CREATE TABLE ontology_object_types (
  user_id UUID NOT NULL,
  stable_key TEXT NOT NULL,
  label TEXT NOT NULL,
  aliases TEXT[] NOT NULL DEFAULT '{}',
  normalized_aliases TEXT[] NOT NULL DEFAULT '{}',
  identity_strategy TEXT NOT NULL,
  identity_config JSONB,
  reconciliation_policy TEXT NOT NULL,
  entity_resolution_policy TEXT NOT NULL,
  CONSTRAINT ontology_object_types_pkey PRIMARY KEY (user_id, stable_key),
  CONSTRAINT ontology_object_types_registry_state_fk FOREIGN KEY (user_id) REFERENCES ontology_registry_state (user_id),
  CONSTRAINT ontology_object_types_stable_key_nonempty_check CHECK (btrim(stable_key) <> ''),
  CONSTRAINT ontology_object_types_label_nonempty_check CHECK (btrim(label) <> ''),
  CONSTRAINT ontology_object_types_alias_cardinality_check CHECK (cardinality(aliases) = cardinality(normalized_aliases)),
  CONSTRAINT ontology_object_types_identity_strategy_check CHECK (identity_strategy IN ('none', 'property_tuple')),
  CONSTRAINT ontology_object_types_reconciliation_policy_check CHECK (reconciliation_policy IN ('deterministic_identity', 'exact_label', 'scoped_exact_label', 'explicit_reference_only')),
  CONSTRAINT ontology_object_types_entity_resolution_nonempty_check CHECK (btrim(entity_resolution_policy) <> '')
);

CREATE TABLE ontology_property_types (
  user_id UUID NOT NULL,
  stable_key TEXT NOT NULL,
  label TEXT NOT NULL,
  aliases TEXT[] NOT NULL DEFAULT '{}',
  normalized_aliases TEXT[] NOT NULL DEFAULT '{}',
  aggregation_policy TEXT NOT NULL,
  allow_user_override BOOLEAN NOT NULL,
  CONSTRAINT ontology_property_types_pkey PRIMARY KEY (user_id, stable_key),
  CONSTRAINT ontology_property_types_registry_state_fk FOREIGN KEY (user_id) REFERENCES ontology_registry_state (user_id),
  CONSTRAINT ontology_property_types_stable_key_nonempty_check CHECK (btrim(stable_key) <> ''),
  CONSTRAINT ontology_property_types_label_nonempty_check CHECK (btrim(label) <> ''),
  CONSTRAINT ontology_property_types_alias_cardinality_check CHECK (cardinality(aliases) = cardinality(normalized_aliases)),
  CONSTRAINT ontology_property_types_aggregation_policy_check CHECK (aggregation_policy IN ('exact_consensus', 'set_union', 'conservative_text', 'status_resolution', 'decision_status'))
);

CREATE TABLE ontology_object_type_properties (
  user_id UUID NOT NULL,
  stable_key TEXT NOT NULL,
  object_type_key TEXT NOT NULL,
  property_type_key TEXT NOT NULL,
  is_identity_component BOOLEAN NOT NULL,
  CONSTRAINT ontology_object_type_properties_pkey PRIMARY KEY (user_id, stable_key),
  CONSTRAINT ontology_object_type_properties_registry_state_fk FOREIGN KEY (user_id) REFERENCES ontology_registry_state (user_id),
  CONSTRAINT ontology_object_type_properties_stable_key_nonempty_check CHECK (btrim(stable_key) <> ''),
  CONSTRAINT ontology_object_type_properties_object_fk FOREIGN KEY (user_id, object_type_key) REFERENCES ontology_object_types (user_id, stable_key),
  CONSTRAINT ontology_object_type_properties_property_fk FOREIGN KEY (user_id, property_type_key) REFERENCES ontology_property_types (user_id, stable_key),
  CONSTRAINT ontology_object_type_properties_pair_unique UNIQUE (user_id, object_type_key, property_type_key)
);

CREATE TABLE ontology_relation_types (
  user_id UUID NOT NULL,
  stable_key TEXT NOT NULL,
  label TEXT NOT NULL,
  aliases TEXT[] NOT NULL DEFAULT '{}',
  normalized_aliases TEXT[] NOT NULL DEFAULT '{}',
  direction TEXT NOT NULL,
  allow_self_reference BOOLEAN NOT NULL,
  is_fallback BOOLEAN NOT NULL,
  cycle_policy TEXT NOT NULL,
  CONSTRAINT ontology_relation_types_pkey PRIMARY KEY (user_id, stable_key),
  CONSTRAINT ontology_relation_types_registry_state_fk FOREIGN KEY (user_id) REFERENCES ontology_registry_state (user_id),
  CONSTRAINT ontology_relation_types_stable_key_nonempty_check CHECK (btrim(stable_key) <> ''),
  CONSTRAINT ontology_relation_types_label_nonempty_check CHECK (btrim(label) <> ''),
  CONSTRAINT ontology_relation_types_alias_cardinality_check CHECK (cardinality(aliases) = cardinality(normalized_aliases)),
  CONSTRAINT ontology_relation_types_direction_check CHECK (direction IN ('directed', 'symmetric')),
  CONSTRAINT ontology_relation_types_cycle_policy_nonempty_check CHECK (btrim(cycle_policy) <> '')
);

CREATE TABLE ontology_relation_type_rules (
  user_id UUID NOT NULL,
  stable_key TEXT NOT NULL,
  relation_type_key TEXT NOT NULL,
  source_object_type_key TEXT NOT NULL,
  target_object_type_key TEXT NOT NULL,
  evidence_policy TEXT NOT NULL,
  extraction_policy TEXT NOT NULL,
  CONSTRAINT ontology_relation_type_rules_pkey PRIMARY KEY (user_id, stable_key),
  CONSTRAINT ontology_relation_type_rules_registry_state_fk FOREIGN KEY (user_id) REFERENCES ontology_registry_state (user_id),
  CONSTRAINT ontology_relation_type_rules_stable_key_nonempty_check CHECK (btrim(stable_key) <> ''),
  CONSTRAINT ontology_relation_type_rules_relation_type_fk FOREIGN KEY (user_id, relation_type_key) REFERENCES ontology_relation_types (user_id, stable_key),
  CONSTRAINT ontology_relation_type_rules_source_object_fk FOREIGN KEY (user_id, source_object_type_key) REFERENCES ontology_object_types (user_id, stable_key),
  CONSTRAINT ontology_relation_type_rules_target_object_fk FOREIGN KEY (user_id, target_object_type_key) REFERENCES ontology_object_types (user_id, stable_key),
  CONSTRAINT ontology_relation_type_rules_evidence_policy_check CHECK (evidence_policy IN ('explicit_only', 'explicit_or_direct_inferred', 'structural_verified')),
  CONSTRAINT ontology_relation_type_rules_extraction_policy_check CHECK (extraction_policy IN ('semantic', 'structured', 'mixed'))
);
