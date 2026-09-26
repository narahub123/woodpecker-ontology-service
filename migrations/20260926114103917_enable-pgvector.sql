-- Up Migration

-- Ontology persistence에서 vector 타입을 사용하기 위한 공통 prerequisite이다.
-- 이후 schema가 이 extension에 의존하므로 이 migration은 rollback 대상으로 취급하지 않는다.
CREATE EXTENSION IF NOT EXISTS vector;