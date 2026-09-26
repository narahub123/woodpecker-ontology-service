import conventional from "@commitlint/config-conventional";

const allowedTypes = [
  "build",
  "chore",
  "ci",
  "docs",
  "feat",
  "fix",
  "perf",
  "refactor",
  "revert",
  "style",
  "test",
];

const headerPattern = new RegExp(
  `^(${allowedTypes.join("|")}): #[1-9]\\d* - (?=.*[가-힣]).+$`,
);

export default {
  extends: ["@commitlint/config-conventional"],
  plugins: [
    {
      rules: {
        "woodpecker-header-format": ({ header }) => [
          headerPattern.test(header ?? ""),
          "커밋 메시지는 <type>: #<issue-number> - <한국어 설명> 형식이어야 합니다.",
        ],
      },
    },
  ],
  rules: {
    ...conventional.rules,
    "header-max-length": [2, "always", 100],
    "type-enum": [2, "always", allowedTypes],
    "woodpecker-header-format": [2, "always"],
  },
};
