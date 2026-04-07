---
name: create-hooks
description: "hooks JSON ファイルを作成・修正するスキル。Use when: hooks の新規作成、フックイベントの追加、hooks テンプレート生成、ライフサイクル自動化の構築"
---

# hooks 作成スキル

## When to Use
- `.github/hooks/` に新しい hooks JSON を作成したい
- 既存の hooks にイベントを追加したい
- hooks のテンプレートが必要
- PreToolUse でコマンドをブロックしたい
- PostToolUse で lint やテストを自動実行したい

## Procedure
1. ユーザーの要件（どのイベントで何を実行するか）を確認する。
2. [hooks リファレンス](./references/hooks-reference.md) を参照し、適切なイベントとフォーマットを選定する。
3. `.github/hooks/` に JSON ファイルを作成する。
4. JSON 構文を検証する。

## 基本テンプレート

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "実行コマンド",
        "timeout": 10
      }
    ]
  }
}
```

## Constraints
- JSON 構文が正しいことを確認すること。
- シークレットをコマンドにハードコードしないこと。
- `timeout` を適切に設定すること（推奨: 10〜30秒）。
