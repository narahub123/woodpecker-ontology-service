import type { Heading, RootContent } from "mdast";
import remarkGfm from "remark-gfm";
import remarkParse from "remark-parse";
import { unified } from "unified";

import type { MarkdownBlockId } from "../contracts/commonTypes.js";

/**
 * Parser가 root-level Markdown node를 분류할 때 사용하는 exact block kind다.
 * 지원 대상이 아닌 top-level node는 삭제하지 않고 `unknown`으로 보존한다.
 */
export type MarkdownBlockKind =
  | "heading"
  | "paragraph"
  | "code"
  | "list"
  | "blockquote"
  | "table"
  | "thematic_break"
  | "unknown";

/**
 * Markdown 원문의 root-level block 하나를 후속 Application 단계에 전달하는 DTO다.
 * source 위치와 exact Markdown을 함께 보존해 Evidence/Provenance가 원문을 다시 가리킬 수 있게 한다.
 */
export type ParsedMarkdownBlock = {
  blockId: MarkdownBlockId;
  kind: MarkdownBlockKind;
  sectionPath: readonly string[];
  line: number;
  column: number;
  startOffset: number;
  endOffset: number;
  rawMarkdown: string;
  analysisText: string;
};

/**
 * heading의 section 이름을 만들 때 필요한 mdast inline node의 최소 구조다.
 * Markdown 전체 AST를 별도 도메인 타입으로 복제하지 않고 text/alt/children만 읽기 위한 내부 타입이다.
 */
type TextBearingNode = {
  readonly type: string;
  readonly value?: unknown;
  readonly alt?: unknown;
  readonly children?: readonly TextBearingNode[];
};

/**
 * 현재 활성화된 section heading 하나를 표현한다.
 * heading depth를 제목과 함께 보존해 건너뛴 depth가 있어도 실제 hierarchy를 정확히 계산한다.
 */
type SectionHeading = {
  readonly depth: Heading["depth"];
  readonly title: string;
};

/**
 * block 원문을 다시 가리키기 위해 필요한 검증 완료 source 좌표다.
 * offset은 JavaScript UTF-16 code unit 기준 0-based이고 line/column은 1-based다.
 */
type BlockSourcePosition = {
  readonly line: number;
  readonly column: number;
  readonly startOffset: number;
  readonly endOffset: number;
};

// CommonMark 구조와 Woodpecker가 사용하는 GFM 확장을 함께 해석하는 재사용 가능한 parser다.
const markdownParser = unified().use(remarkParse).use(remarkGfm);

/**
 * mdast의 root-level node type을 Application parser contract의 block kind로 변환한다.
 * 계약에 직접 대응하지 않는 node는 `unknown`으로 남겨 source block 자체가 사라지지 않게 한다.
 */
function toMarkdownBlockKind(nodeType: string): MarkdownBlockKind {
  switch (nodeType) {
    case "heading":
      return "heading";
    case "paragraph":
      return "paragraph";
    case "code":
      return "code";
    case "list":
      return "list";
    case "blockquote":
      return "blockquote";
    case "table":
      return "table";
    case "thematicBreak":
      return "thematic_break";
    default:
      return "unknown";
  }
}

/**
 * heading 내부 inline node에서 sectionPath에 사용할 사람이 읽는 텍스트만 재귀적으로 추출한다.
 * semantic normalization은 하지 않고 text, inline code, image alt와 자식 node의 텍스트만 보존한다.
 */
function readText(node: TextBearingNode): string {
  if (
    (node.type === "text" || node.type === "inlineCode") &&
    typeof node.value === "string"
  ) {
    return node.value;
  }

  if (
    (node.type === "image" || node.type === "imageReference") &&
    typeof node.alt === "string"
  ) {
    return node.alt;
  }

  if (node.type === "break") {
    return "\n";
  }

  if (node.children === undefined) {
    return "";
  }

  return node.children.map(readText).join("");
}

/**
 * heading의 inline children을 합쳐 sectionPath 한 단계에 들어갈 제목 문자열을 만든다.
 */
function getHeadingText(heading: Heading): string {
  return heading.children
    .map((child) => readText(child as TextBearingNode))
    .join("");
}

/**
 * 새 heading의 실제 depth를 기준으로 현재 section hierarchy를 갱신한다.
 * 새 heading보다 낮은 depth의 부모만 유지하므로 같은 depth·상위 depth 이동과 건너뛴 depth를 모두 동일하게 처리한다.
 */
function updateSectionHeadings(
  currentSectionHeadings: readonly SectionHeading[],
  heading: Heading,
): readonly SectionHeading[] {
  const parentHeadings = currentSectionHeadings.filter(
    ({ depth }) => depth < heading.depth,
  );

  return [
    ...parentHeadings,
    { depth: heading.depth, title: getHeadingText(heading) },
  ];
}

/**
 * root block 순서를 Generation-local MarkdownBlockId로 변환한다.
 * branded type cast는 외부 입력 검증이 아니라 parser가 직접 만드는 결정적 내부 식별자 생성 지점에만 둔다.
 */
function createMarkdownBlockId(index: number): MarkdownBlockId {
  return `block-${index + 1}` as MarkdownBlockId;
}

/**
 * mdast node가 exact source를 다시 가리킬 수 있는 완전한 위치 정보를 갖는지 검증한다.
 * 검증된 line/column과 UTF-16 offset만 반환하며 누락된 위치를 임의로 복원하지 않는다.
 */
function requireSourcePosition(node: RootContent): BlockSourcePosition {
  const position = node.position;
  const startOffset = position?.start.offset;
  const endOffset = position?.end.offset;

  if (
    position === undefined ||
    startOffset === undefined ||
    endOffset === undefined
  ) {
    // Source provenance를 추측해서 만들지 않는다.
    // mdast가 완전한 source position을 제공하지 않으면 parsing을 실패시킨다.
    throw new TypeError(
      `Markdown block "${node.type}" is missing a complete source position.`,
    );
  }

  return {
    line: position.start.line,
    column: position.start.column,
    startOffset,
    endOffset,
  };
}

/**
 * Markdown 원문을 root-level 구조 단위로 파싱해 source 위치가 보존된 block 목록으로 변환한다.
 * 이 함수는 구조 파싱만 담당하며 semantic extraction이나 persistence는 수행하지 않는다.
 *
 * blockId는 이 파싱 결과 안에서만 유효한 Generation-local reference이며,
 * 서로 다른 Generation 사이의 안정적인 식별자를 의미하지 않는다.
 */
export function parseMarkdownBlocks(markdown: string): ParsedMarkdownBlock[] {
  const root = markdownParser.parse(markdown);

  let sectionHeadings: readonly SectionHeading[] = [];

  return root.children.map((node, index) => {
    if (node.type === "heading") {
      sectionHeadings = updateSectionHeadings(sectionHeadings, node);
    }

    const sectionPath = sectionHeadings.map(({ title }) => title);
    const { line, column, startOffset, endOffset } =
      requireSourcePosition(node);

    // exact source 보존을 위해 AST를 재직렬화하지 않고
    // UTF-16 source offset으로 원문을 직접 자른다.
    const rawMarkdown = markdown.slice(startOffset, endOffset);

    return {
      blockId: createMarkdownBlockId(index),
      kind: toMarkdownBlockKind(node.type),
      sectionPath: [...sectionPath],
      line,
      column,
      startOffset,
      endOffset,
      rawMarkdown,
      analysisText: rawMarkdown,
    };
  });
}
