declare const applicationContractBrand: unique symbol;

/**
 * Application contract에서 의미가 다른 문자열 식별자를 서로 대입하지 못하게
 * 구분하기 위한 내부 branded-string 표현입니다.
 */
type BrandedString<TBrand extends string> = string & {
  readonly [applicationContractBrand]: TBrand;
};

// Persistence가 소유하는 database identity를 일반 string과 구분한다.
export type NoteId = BrandedString<"NoteId">;
export type GenerationId = BrandedString<"GenerationId">;
export type ObjectTypeId = BrandedString<"ObjectTypeId">;
export type PropertyTypeId = BrandedString<"PropertyTypeId">;
export type RelationTypeId = BrandedString<"RelationTypeId">;
export type ObjectId = BrandedString<"ObjectId">;
export type SchemaCandidateId = BrandedString<"SchemaCandidateId">;
export type AiModelConfigId = BrandedString<"AiModelConfigId">;
export type AiPromptVersionId = BrandedString<"AiPromptVersionId">;

// Application 내부에서 사용하는 local key를 database identity와 구분한다.
export type MarkdownBlockId = BrandedString<"MarkdownBlockId">;
export type SemanticUnitKey = BrandedString<"SemanticUnitKey">;
export type SourceCandidateKey = BrandedString<"SourceCandidateKey">;
export type SourceContributionKey = BrandedString<"SourceContributionKey">;
export type SchemaGapKey = BrandedString<"SchemaGapKey">;
export type ReconciliationGroupKey = BrandedString<"ReconciliationGroupKey">;
export type EvidenceKey = BrandedString<"EvidenceKey">;
export type StructuredFactKey = BrandedString<"StructuredFactKey">;
export type SchemaObservationKey = BrandedString<"SchemaObservationKey">;

// Hash, fingerprint, version 문자열도 서로 다른 계약 값으로 취급한다.
export type SourceHash = BrandedString<"SourceHash">;
export type ExcerptHash = BrandedString<"ExcerptHash">;
export type EntityIdentityKey = BrandedString<"EntityIdentityKey">;
export type SchemaCandidateFingerprint =
  BrandedString<"SchemaCandidateFingerprint">;
export type InstanceFingerprint = BrandedString<"InstanceFingerprint">;
export type PromptBehaviorHash = BrandedString<"PromptBehaviorHash">;
export type ModelBehaviorHash = BrandedString<"ModelBehaviorHash">;
export type ParserVersion = BrandedString<"ParserVersion">;
export type ExtractorVersion = BrandedString<"ExtractorVersion">;
export type MaterializerVersion = BrandedString<"MaterializerVersion">;
export type RegistryVersion = BrandedString<"RegistryVersion">;

/**
 * Canonical property에 저장할 수 있는 scalar 값입니다.
 * Object, array, null은 canonical property value로 허용하지 않습니다.
 */
export type CanonicalPropertyScalar = string | number | boolean;
