BEGIN;

DO $$
DECLARE
  actual_tables TEXT[];
  expected_tables CONSTANT TEXT[] := ARRAY[
    'ontology_object_type_properties',
    'ontology_object_types',
    'ontology_property_types',
    'ontology_registry_state',
    'ontology_relation_type_rules',
    'ontology_relation_types'
  ];
BEGIN
  SELECT array_agg(tablename ORDER BY tablename)
    INTO actual_tables
  FROM pg_tables
  WHERE schemaname = 'public'
    AND tablename = ANY(expected_tables);

  IF actual_tables IS DISTINCT FROM expected_tables THEN
    RAISE EXCEPTION 'Registry tables mismatch: %', actual_tables;
  END IF;
END
$$;

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_registry_state (user_id, version, seed_version)
    VALUES ('00000000-0000-4000-8000-000000000001', -1, 0);
    RAISE EXCEPTION 'negative version was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_registry_state (user_id, version, seed_version)
    VALUES ('00000000-0000-4000-8000-000000000001', 0, -1);
    RAISE EXCEPTION 'negative seed_version was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_registry_state (user_id, version, seed_version) VALUES
('00000000-0000-4000-8000-000000000001', 0, 0),
('00000000-0000-4000-8000-000000000002', 0, 0);

INSERT INTO ontology_object_types (
  user_id, stable_key, label, aliases, normalized_aliases,
  identity_strategy, identity_config, reconciliation_policy, entity_resolution_policy
) VALUES
('00000000-0000-4000-8000-000000000001', 'person', 'Person', '{}', '{}', 'none', NULL, 'exact_label', 'explicit'),
('00000000-0000-4000-8000-000000000002', 'person', 'Person', '{}', '{}', 'none', NULL, 'exact_label', 'explicit'),
('00000000-0000-4000-8000-000000000002', 'external-person', 'External Person', '{}', '{}', 'none', NULL, 'exact_label', 'explicit');

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_object_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      identity_strategy, identity_config, reconciliation_policy, entity_resolution_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'person', 'Duplicate',
      '{}', '{}', 'none', NULL, 'exact_label', 'explicit'
    );
    RAISE EXCEPTION 'duplicate user-scoped stable key was accepted';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_object_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      identity_strategy, identity_config, reconciliation_policy, entity_resolution_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-alias', 'Bad Alias',
      ARRAY['Person'], '{}', 'none', NULL, 'exact_label', 'explicit'
    );
    RAISE EXCEPTION 'object alias cardinality mismatch was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_object_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      identity_strategy, identity_config, reconciliation_policy, entity_resolution_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-identity', 'Bad Identity',
      '{}', '{}', 'invalid', NULL, 'exact_label', 'explicit'
    );
    RAISE EXCEPTION 'invalid identity strategy was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_object_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      identity_strategy, identity_config, reconciliation_policy, entity_resolution_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-reconciliation', 'Bad Reconciliation',
      '{}', '{}', 'none', NULL, 'invalid', 'explicit'
    );
    RAISE EXCEPTION 'invalid reconciliation policy was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_property_types (
  user_id, stable_key, label, aliases, normalized_aliases,
  aggregation_policy, allow_user_override
) VALUES
('00000000-0000-4000-8000-000000000001', 'name', 'Name', '{}', '{}', 'exact_consensus', false),
('00000000-0000-4000-8000-000000000002', 'name', 'Name', '{}', '{}', 'exact_consensus', false),
('00000000-0000-4000-8000-000000000002', 'external-name', 'External Name', '{}', '{}', 'exact_consensus', false);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_property_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      aggregation_policy, allow_user_override
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-property-alias', 'Bad',
      ARRAY['Status'], '{}', 'exact_consensus', false
    );
    RAISE EXCEPTION 'property alias cardinality mismatch was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_property_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      aggregation_policy, allow_user_override
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-aggregation', 'Bad',
      '{}', '{}', 'invalid', false
    );
    RAISE EXCEPTION 'invalid aggregation policy was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_object_type_properties (
  user_id, stable_key, object_type_key, property_type_key, is_identity_component
) VALUES (
  '00000000-0000-4000-8000-000000000001', 'person-name', 'person', 'name', true
);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_object_type_properties (
      user_id, stable_key, object_type_key, property_type_key, is_identity_component
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'missing-property', 'person', 'missing', false
    );
    RAISE EXCEPTION 'missing property reference was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_object_type_properties (
      user_id, stable_key, object_type_key, property_type_key, is_identity_component
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'person-name-2', 'person', 'name', false
    );
    RAISE EXCEPTION 'duplicate object/property pair was accepted';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_object_type_properties (
      user_id, stable_key, object_type_key, property_type_key, is_identity_component
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'cross-user-binding', 'external-person', 'external-name', true
    );
    RAISE EXCEPTION 'cross-user object/property binding was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_object_types (
  user_id, stable_key, label, aliases, normalized_aliases,
  identity_strategy, identity_config, reconciliation_policy, entity_resolution_policy
) VALUES
('00000000-0000-4000-8000-000000000001', 'source', 'Source', '{}', '{}', 'none', NULL, 'exact_label', 'explicit'),
('00000000-0000-4000-8000-000000000001', 'target', 'Target', '{}', '{}', 'none', NULL, 'exact_label', 'explicit'),
('00000000-0000-4000-8000-000000000002', 'external-source', 'External Source', '{}', '{}', 'none', NULL, 'exact_label', 'explicit'),
('00000000-0000-4000-8000-000000000002', 'external-target', 'External Target', '{}', '{}', 'none', NULL, 'exact_label', 'explicit');

INSERT INTO ontology_relation_types (
  user_id, stable_key, label, aliases, normalized_aliases,
  direction, allow_self_reference, is_fallback, cycle_policy
) VALUES
('00000000-0000-4000-8000-000000000001', 'depends-on', 'Depends on', '{}', '{}', 'directed', false, false, 'allowed'),
('00000000-0000-4000-8000-000000000002', 'external-relation', 'External Relation', '{}', '{}', 'directed', false, false, 'allowed');

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_relation_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      direction, allow_self_reference, is_fallback, cycle_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-relation-alias', 'Bad',
      ARRAY['Depends on'], '{}', 'directed', false, false, 'allowed'
    );
    RAISE EXCEPTION 'relation alias cardinality mismatch was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_relation_types (
      user_id, stable_key, label, aliases, normalized_aliases,
      direction, allow_self_reference, is_fallback, cycle_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-direction', 'Bad',
      '{}', '{}', 'invalid', false, false, 'allowed'
    );
    RAISE EXCEPTION 'invalid relation direction was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$$;

INSERT INTO ontology_relation_type_rules (
  user_id, stable_key, relation_type_key, source_object_type_key, target_object_type_key,
  evidence_policy, extraction_policy
) VALUES (
  '00000000-0000-4000-8000-000000000001', 'depends-rule', 'depends-on', 'source', 'target',
  'explicit_only', 'semantic'
);

DO $$
BEGIN
  BEGIN
    INSERT INTO ontology_relation_type_rules (
      user_id, stable_key, relation_type_key, source_object_type_key, target_object_type_key,
      evidence_policy, extraction_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-evidence', 'depends-on', 'source', 'target',
      'invalid', 'semantic'
    );
    RAISE EXCEPTION 'invalid evidence policy was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_relation_type_rules (
      user_id, stable_key, relation_type_key, source_object_type_key, target_object_type_key,
      evidence_policy, extraction_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'bad-extraction', 'depends-on', 'source', 'target',
      'explicit_only', 'invalid'
    );
    RAISE EXCEPTION 'invalid extraction policy was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  BEGIN
    INSERT INTO ontology_relation_type_rules (
      user_id, stable_key, relation_type_key, source_object_type_key, target_object_type_key,
      evidence_policy, extraction_policy
    ) VALUES (
      '00000000-0000-4000-8000-000000000001', 'cross-user-rule',
      'external-relation', 'external-source', 'external-target',
      'explicit_only', 'semantic'
    );
    RAISE EXCEPTION 'cross-user relation rule was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;
END
$$;

ROLLBACK;
