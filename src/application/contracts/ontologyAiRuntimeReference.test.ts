import { describe, expect, it } from "vitest";

import { parseOntologyAiRuntimeReference } from "./ontologyAiRuntimeReference.js";

describe("parseOntologyAiRuntimeReference", () => {
  it("유효한 chat runtime reference를 허용한다", () => {
    const result = parseOntologyAiRuntimeReference({
      roleKey: "semantic-extraction",
      kind: "chat",
      modelConfigId: "model-config-1",
      promptVersionId: "prompt-version-1",
      temperature: 0.2,
      promptBehaviorHash: "prompt-hash-1",
      modelBehaviorHash: "model-hash-1",
    });

    expect(result).toEqual({
      roleKey: "semantic-extraction",
      kind: "chat",
      modelConfigId: "model-config-1",
      promptVersionId: "prompt-version-1",
      temperature: 0.2,
      promptBehaviorHash: "prompt-hash-1",
      modelBehaviorHash: "model-hash-1",
    });
  });

  it("유효한 embedding runtime reference를 허용한다", () => {
    const result = parseOntologyAiRuntimeReference({
      roleKey: "semantic-retrieval",
      kind: "embedding",
      modelConfigId: "model-config-1",
      promptVersionId: null,
      temperature: null,
      promptBehaviorHash: null,
      modelBehaviorHash: "model-hash-1",
    });

    expect(result).toEqual({
      roleKey: "semantic-retrieval",
      kind: "embedding",
      modelConfigId: "model-config-1",
      promptVersionId: null,
      temperature: null,
      promptBehaviorHash: null,
      modelBehaviorHash: "model-hash-1",
    });
  });

  it("허용되지 않은 role을 거부한다", () => {
    expect(() =>
      parseOntologyAiRuntimeReference({
        roleKey: "unknown-role",
        kind: "chat",
        modelConfigId: "model-config-1",
        promptVersionId: "prompt-version-1",
        temperature: 0.2,
        promptBehaviorHash: "prompt-hash-1",
        modelBehaviorHash: "model-hash-1",
      }),
    ).toThrow(TypeError);
  });

  it("허용되지 않은 kind를 거부한다", () => {
    expect(() =>
      parseOntologyAiRuntimeReference({
        roleKey: "semantic-extraction",
        kind: "unknown-kind",
        modelConfigId: "model-config-1",
        promptVersionId: "prompt-version-1",
        temperature: 0.2,
        promptBehaviorHash: "prompt-hash-1",
        modelBehaviorHash: "model-hash-1",
      }),
    ).toThrow(TypeError);
  });

  it("정의되지 않은 추가 필드를 거부한다", () => {
    expect(() =>
      parseOntologyAiRuntimeReference({
        roleKey: "semantic-extraction",
        kind: "chat",
        modelConfigId: "model-config-1",
        promptVersionId: "prompt-version-1",
        temperature: 0.2,
        promptBehaviorHash: "prompt-hash-1",
        modelBehaviorHash: "model-hash-1",
        unexpected: true,
      }),
    ).toThrow(TypeError);
  });

  it("필수 필드가 누락된 chat reference를 거부한다", () => {
    expect(() =>
      parseOntologyAiRuntimeReference({
        roleKey: "semantic-extraction",
        kind: "chat",
        modelConfigId: "model-config-1",
        promptVersionId: "prompt-version-1",
        temperature: 0.2,
        modelBehaviorHash: "model-hash-1",
      }),
    ).toThrow(TypeError);
  });

  it("prompt runtime 값이 포함된 embedding reference를 거부한다", () => {
    expect(() =>
      parseOntologyAiRuntimeReference({
        roleKey: "semantic-retrieval",
        kind: "embedding",
        modelConfigId: "model-config-1",
        promptVersionId: "prompt-version-1",
        temperature: null,
        promptBehaviorHash: null,
        modelBehaviorHash: "model-hash-1",
      }),
    ).toThrow(TypeError);
  });

  it.each([null, undefined, true, 1, "value", []])(
    "객체가 아닌 입력을 거부한다: %p",
    (value) => {
      expect(() => parseOntologyAiRuntimeReference(value)).toThrow(TypeError);
    },
  );
});
