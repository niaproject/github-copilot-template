---
name: fix-skill-frontmatter
description: "SKILL.md ファイルのYAMLフロントマター属性を診断し修正するスキル。Use when: SKILL.md のフロントマター警告、無効プロパティ、name とフォルダ名の不一致、description の不足"
---

# SKILL.md フロントマター修正スキル

## When to Use
- SKILL.md でフロントマター警告・エラーが出ている
- フロントマターに何を指定できるか知りたい
- `name` とフォルダ名の不一致を修正したい
- `description` が不十分で自動検出されない

## Procedure
1. 対象の SKILL.md を読み取り、現在のフロントマターを確認する。
2. エラー・警告の内容を `get_errors` で確認する。
3. [有効な SKILL.md フロントマタープロパティ一覧](./references/valid-properties.md) を参照し、問題を特定する。
4. 修正を適用する。
5. 修正後に `get_errors` でエラーが解消されたことを確認する。

## 修正パターン例

### name とフォルダ名の不一致
`name` フィールドは親ディレクトリ名と一致する必要がある。

**NG:**
```
.github/skills/my-skill/SKILL.md
---
name: myskill  # フォルダ名は "my-skill" だが name が異なる
---
```

**OK:**
```
.github/skills/my-skill/SKILL.md
---
name: my-skill
---
```

### description が不十分
"Use when:" パターンでトリガーワードを含めること。

**NG:**
```yaml
description: "便利なスキル"
```

**OK:**
```yaml
description: "Web アプリを Playwright でテストするスキル。Use when: フロントエンド検証、UI デバッグ、スクリーンショット取得"
```

## Constraints
- 修正前に必ずファイルの現在の内容を確認する。
- 修正後にエラーが解消されたことを検証する。
- `name` は 1〜64 文字、小文字英数字+ハイフンのみ。
- `description` は最大 1024 文字。
