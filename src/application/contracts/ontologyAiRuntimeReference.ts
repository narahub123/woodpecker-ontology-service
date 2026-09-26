import type {
  AiModelConfigId,
  AiPromptVersionId,
  ModelBehaviorHash,
  PromptBehaviorHash,
} from "./commonTypes.js";

const ONTOLOGY_AI_RUNTIME_KINDS = ["chat", "embedding"] as const;

const ONTOLOGY_AI_RUNTIME_ROLES = [
  "semantic-extraction",
  "code-block-classification",
  "schema-semantic-comparison",
  "entity-semantic-comparison",
  "semantic-retrieval",
] as const;

const ONTOLOGY_AI_RUNTIME_REFERENCE_KEYS = new Set<string>([
  "roleKey",
  "kind",
  "modelConfigId",
  "promptVersionId",
  "temperature",
  "promptBehaviorHash",
  "modelBehaviorHash",
]);

/**
 * Ontology AI runtime의 실행 종류입니다.
 */
export type OntologyAiRuntimeKind = (typeof ONTOLOGY_AI_RUNTIME_KINDS)[number];

/**
 * Ontology 파이프라인에서 AI runtime을 사용하는 역할입니다.
 */
export type OntologyAiRuntimeRole = (typeof ONTOLOGY_AI_RUNTIME_ROLES)[number];

/**
 * 특정 Ontology AI 실행이 어떤 runtime 설정을 사용했는지 식별하는 참조입니다.
 *
 * chat과 embedding은 필요한 prompt/runtime metadata가 다르며,
 * 외부 입력은 parseOntologyAiRuntimeReference에서 경계 검증을 거쳐야 합니다.
 */
export type OntologyAiRuntimeReference = {
  readonly roleKey: OntologyAiRuntimeRole;
  readonly kind: OntologyAiRuntimeKind;
  readonly modelConfigId: AiModelConfigId;
  readonly promptVersionId: AiPromptVersionId | null;
  readonly temperature: number | null;
  readonly promptBehaviorHash: PromptBehaviorHash | null;
  readonly modelBehaviorHash: ModelBehaviorHash;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function hasExactRuntimeReferenceKeys(value: Record<string, unknown>): boolean {
  const keys = Object.keys(value);

  return (
    keys.length === ONTOLOGY_AI_RUNTIME_REFERENCE_KEYS.size &&
    keys.every((key) => ONTOLOGY_AI_RUNTIME_REFERENCE_KEYS.has(key))
  );
}

function isOntologyAiRuntimeKind(
  value: unknown,
): value is OntologyAiRuntimeKind {
  return (
    typeof value === "string" &&
    (ONTOLOGY_AI_RUNTIME_KINDS as readonly string[]).includes(value)
  );
}

function isOntologyAiRuntimeRole(
  value: unknown,
): value is OntologyAiRuntimeRole {
  return (
    typeof value === "string" &&
    (ONTOLOGY_AI_RUNTIME_ROLES as readonly string[]).includes(value)
  );
}

/**
 * 신뢰하지 않는 외부 입력을 Ontology AI runtime reference로 검증합니다.
 *
 * Unknown field를 허용하지 않으며 chat/embedding별 runtime 계약을
 * 만족하지 않는 입력은 보정하지 않고 즉시 거부합니다.
 *
 * @throws {TypeError} 입력 shape 또는 runtime 계약이 유효하지 않은 경우
 */
export function parseOntologyAiRuntimeReference(
  value: unknown,
): OntologyAiRuntimeReference {
  // 입력 경계에서는 plain object와 exact key 집합만 허용한다.
  if (!isRecord(value) || !hasExactRuntimeReferenceKeys(value)) {
    throw new TypeError("Invalid OntologyAiRuntimeReference shape");
  }

  const {
    roleKey,
    kind,
    modelConfigId,
    promptVersionId,
    temperature,
    promptBehaviorHash,
    modelBehaviorHash,
  } = value;

  // 공통 vocabulary와 모든 runtime kind가 공유하는 값을 먼저 검증한다.
  if (!isOntologyAiRuntimeRole(roleKey)) {
    throw new TypeError("Invalid Ontology AI runtime role");
  }

  if (!isOntologyAiRuntimeKind(kind)) {
    throw new TypeError("Invalid Ontology AI runtime kind");
  }

  if (typeof modelConfigId !== "string") {
    throw new TypeError("modelConfigId must be a string");
  }

  if (typeof modelBehaviorHash !== "string") {
    throw new TypeError("modelBehaviorHash must be a string");
  }

  // chat은 prompt 실행을 재현하는 데 필요한 metadata를 모두 요구한다.
  if (kind === "chat") {
    if (typeof promptVersionId !== "string") {
      throw new TypeError("chat promptVersionId must be a string");
    }

    if (typeof temperature !== "number") {
      throw new TypeError("chat temperature must be a number");
    }

    if (typeof promptBehaviorHash !== "string") {
      throw new TypeError("chat promptBehaviorHash must be a string");
    }

    return {
      roleKey,
      kind,
      modelConfigId: modelConfigId as AiModelConfigId,
      promptVersionId: promptVersionId as AiPromptVersionId,
      temperature,
      promptBehaviorHash: promptBehaviorHash as PromptBehaviorHash,
      modelBehaviorHash: modelBehaviorHash as ModelBehaviorHash,
    };
  }

  // embedding은 prompt 실행 정보가 없어야 하므로 관련 필드를 null로 고정한다.
  if (
    promptVersionId !== null ||
    temperature !== null ||
    promptBehaviorHash !== null
  ) {
    throw new TypeError(
      "embedding promptVersionId, temperature, and promptBehaviorHash must be null",
    );
  }

  return {
    roleKey,
    kind,
    modelConfigId: modelConfigId as AiModelConfigId,
    promptVersionId: null,
    temperature: null,
    promptBehaviorHash: null,
    modelBehaviorHash: modelBehaviorHash as ModelBehaviorHash,
  };
}
