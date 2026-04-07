---
name: fix-agent-frontmatter
description: ".agent.md ファイルのYAMLフロントマター警告・エラーを診断し修正するスキル。Use when: フロントマターの Unknown property 警告、YAML構文エラー、無効なプロパティの修正"
---

# .agent.md フロントマター修正スキル

## When to Use
- `.agent.md` ファイルでフロントマター警告・エラーが出ている
- `Unknown property` エラーを修正したい
- 無効なプロパティを有効なプロパティに変換したい

## Procedure
1. 対象の `.agent.md` ファイルを読み取り、現在のフロントマターを確認する。
2. エラー・警告の内容を `get_errors` で確認する。
3. [有効なフロントマタープロパティ一覧](./references/valid-properties.md) を参照し、無効なプロパティを特定する。
4. 無効なプロパティを以下のいずれかで修正する:
   - 有効なプロパティに変換する（例: `github.repository` → `github.permissions` に変換）
   - 本文の適切なセクションに移動する
   - ユーザーに確認の上、削除する
5. 修正後に `get_errors` でエラーが解消されたことを確認する。

## 修正パターン例

### `github` オブジェクト内の無効プロパティ
`github` 内では `permissions` のみ有効。`repository` や `issue-labels` は無効。

**修正前:**
```yaml
github:
  repository:
    owner: your-github-username
    name: your-repository-name
  issue-labels:
    - bug
```

**修正後:**
```yaml
github:
  permissions:
    contents: read
    issues: read
```

## Constraints
- ユーザーが削除を望まない場合、無効なプロパティの情報は有効なプロパティか本文に移動する。
- 修正前に必ずファイルの現在の内容を確認する。
- 修正後にエラーが解消されたことを検証する。
