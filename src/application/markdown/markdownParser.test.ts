import { describe, expect, it } from "vitest";

import { parseMarkdownBlocks } from "./markdownParser.js";

describe("parseMarkdownBlocks", () => {
  it("빈 Markdown을 빈 block 목록으로 변환한다", () => {
    expect(parseMarkdownBlocks("")).toEqual([]);
  });

  it("지원하는 root-level Markdown 구조를 exact block kind로 분류한다", () => {
    const markdown = [
      "# 제목",
      "",
      "문단",
      "",
      "~~~ts",
      "const value = 1;",
      "~~~",
      "",
      "- 항목",
      "",
      "> 인용",
      "",
      "| A | B |",
      "| - | - |",
      "| 1 | 2 |",
      "",
      "---",
      "",
      "<div>raw</div>",
    ].join("\n");

    const blocks = parseMarkdownBlocks(markdown);

    expect(blocks.map(({ kind }) => kind)).toEqual([
      "heading",
      "paragraph",
      "code",
      "list",
      "blockquote",
      "table",
      "thematic_break",
      "unknown",
    ]);
  });

  it("heading 이전 block은 빈 sectionPath를 유지한다", () => {
    const markdown = [
      "제목 이전 문단",
      "",
      "# 제목",
      "",
      "제목 이후 문단",
    ].join("\n");

    expect(
      parseMarkdownBlocks(markdown).map(({ sectionPath }) => sectionPath),
    ).toEqual([[], ["제목"], ["제목"]]);
  });

  it("heading 자신부터 현재 hierarchy를 sectionPath에 반영한다", () => {
    const markdown = [
      "# 루트",
      "루트 내용",
      "",
      "## 하위",
      "하위 내용",
      "",
      "### 세부",
      "세부 내용",
    ].join("\n");

    const blocks = parseMarkdownBlocks(markdown);

    expect(blocks.map(({ sectionPath }) => sectionPath)).toEqual([
      ["루트"],
      ["루트"],
      ["루트", "하위"],
      ["루트", "하위"],
      ["루트", "하위", "세부"],
      ["루트", "하위", "세부"],
    ]);
  });

  it("heading depth를 건너뛰거나 상위 depth로 이동해도 실제 hierarchy만 유지한다", () => {
    const markdown = [
      "### 세부",
      "세부 내용",
      "",
      "## 중간",
      "중간 내용",
      "",
      "#### 깊은 항목",
      "깊은 내용",
      "",
      "# 루트",
      "루트 내용",
    ].join("\n");

    const blocks = parseMarkdownBlocks(markdown);

    expect(blocks.map(({ sectionPath }) => sectionPath)).toEqual([
      ["세부"],
      ["세부"],
      ["중간"],
      ["중간"],
      ["중간", "깊은 항목"],
      ["중간", "깊은 항목"],
      ["루트"],
      ["루트"],
    ]);
  });

  it("heading의 inline 표현에서 sectionPath에 사용할 제목 텍스트를 추출한다", () => {
    const blocks = parseMarkdownBlocks("# **강조**와 `코드`");

    expect(blocks).toMatchObject([
      {
        kind: "heading",
        sectionPath: ["강조와 코드"],
      },
    ]);
  });

  it("rawMarkdown을 원문 source slice 그대로 보존하고 analysisText에도 동일하게 사용한다", () => {
    const markdown = "문단 **강조**와 `코드`";

    expect(parseMarkdownBlocks(markdown)).toMatchObject([
      {
        rawMarkdown: markdown,
        analysisText: markdown,
      },
    ]);
  });

  it("line과 column은 1-based, offset은 UTF-16 code unit 기준 0-based로 보존한다", () => {
    const markdown = "😀 문단\n\n다음";

    expect(parseMarkdownBlocks(markdown)).toMatchObject([
      {
        line: 1,
        column: 1,
        startOffset: 0,
        endOffset: 5,
        rawMarkdown: "😀 문단",
      },
      {
        line: 3,
        column: 1,
        startOffset: 7,
        endOffset: 9,
        rawMarkdown: "다음",
      },
    ]);
  });

  it("root block 순서대로 Generation-local blockId를 생성한다", () => {
    const markdown = ["# 제목", "", "문단", "", "---"].join("\n");

    expect(parseMarkdownBlocks(markdown).map(({ blockId }) => blockId)).toEqual(
      ["block-1", "block-2", "block-3"],
    );
  });

  it("같은 Markdown 입력에는 같은 parsing 결과를 반환한다", () => {
    const markdown = [
      "# 제목",
      "",
      "문단",
      "",
      "| A | B |",
      "| - | - |",
      "| 1 | 2 |",
    ].join("\n");

    expect(parseMarkdownBlocks(markdown)).toEqual(
      parseMarkdownBlocks(markdown),
    );
  });
});
