/**
 * Application 계층 전반에서 공유하는 식별자와 계약용 scalar type이다.
 * 서로 다른 의미의 문자열 식별자가 구조적으로 섞이지 않도록 branded type 경계를 유지한다.
 */
export type {
  AiModelConfigId,
  AiPromptVersionId,
  CanonicalPropertyScalar,
  EntityIdentityKey,
  EvidenceKey,
  ExcerptHash,
  ExtractorVersion,
  GenerationId,
  InstanceFingerprint,
  MarkdownBlockId,
  MaterializerVersion,
  ModelBehaviorHash,
  NoteId,
  ObjectId,
  ObjectTypeId,
  ParserVersion,
  PromptBehaviorHash,
  PropertyTypeId,
  ReconciliationGroupKey,
  RegistryVersion,
  RelationTypeId,
  SchemaCandidateFingerprint,
  SchemaCandidateId,
  SchemaGapKey,
  SchemaObservationKey,
  SemanticUnitKey,
  SourceCandidateKey,
  SourceContributionKey,
  SourceHash,
  StructuredFactKey,
} from "./contracts/commonTypes.js";

/**
 * AI runtime 설정을 Application boundary에서 검증하고 전달하기 위한 공개 계약이다.
 * provider별 세부 구현을 노출하지 않고 runtime 종류·역할·검증 진입점만 외부에 제공한다.
 */
export {
  type OntologyAiRuntimeKind,
  type OntologyAiRuntimeReference,
  type OntologyAiRuntimeRole,
  parseOntologyAiRuntimeReference,
} from "./contracts/ontologyAiRuntimeReference.js";

/**
 * Markdown 원문을 Application 계층에서 구조화된 block으로 사용할 수 있도록 공개하는 Parser 계약이다.
 * Parser 내부의 AST 처리 helper는 노출하지 않고 block 분류·출력 DTO·진입점만 public API로 유지한다.
 */
export {
  type MarkdownBlockKind,
  type ParsedMarkdownBlock,
  parseMarkdownBlocks,
} from "./markdown/markdownParser.js";
