# .agent.md フロントマタープロパティ リファレンス

> 情報源: [VS Code 公式ドキュメント](https://code.visualstudio.com/docs/copilot/customization/custom-agents) + 拡張機能ソースコード

## フロントマタープロパティ

| プロパティ | 型 | 必須 | デフォルト | 説明 |
|---|---|---|---|---|
| `name` | string | - | ファイル名 | エージェント名 |
| `description` | string | **必須** | - | 説明文（エージェント選択・サブエージェント検出に使用） |
| `tools` | list | - | デフォルトツール | 使用可能ツール（エイリアス、MCP `<server>/*`、拡張ツール） |
| `model` | string / list | - | ピッカー選択値 | AIモデル（配列でフォールバック指定可） |
| `argument-hint` | string | - | - | チャット入力フィールドのヒントテキスト |
| `agents` | list | - | 全許可 | サブエージェント制限（`*` = 全許可、`[]` = 禁止） |
| `user-invocable` | boolean | - | `true` | エージェントピッカーに表示するか |
| `disable-model-invocation` | boolean | - | `false` | サブエージェントとしての自動呼び出しを禁止 |
| `target` | string | - | - | `vscode` or `github-copilot` |
| `mcp-servers` | object | - | - | MCP サーバー構成 |
| `handoffs` | list | - | - | ハンドオフ定義 |
| `hooks` | object | - | - | フック定義（Preview） |
| `metadata` | object | - | - | 注釈データ |

## `github` オブジェクト

`github` 内では **`permissions` のみ有効**。

```yaml
github:
  permissions:
    contents: read
    issues: read
    pull-requests: write
```

## ツールエイリアス

| エイリアス | 用途 |
|---|---|
| `execute` | シェルコマンド実行 |
| `read` | ファイル読み取り |
| `edit` | ファイル編集 |
| `search` | ファイル・テキスト検索 |
| `agent` | サブエージェント呼び出し |
| `web` | URL取得・Web検索 |
| `todo` | タスクリスト管理 |

## ツール指定パターン

```yaml
tools: [read, search]             # 読み取り専用
tools: [myserver/*]               # MCP サーバーのみ
tools: [read, edit, search]       # ターミナルなし
tools: []                         # 会話のみ（ツールなし）
```

## `handoffs` オブジェクト

| キー | 型 | 必須 | 説明 |
|---|---|---|---|
| `label` | string | **必須** | ボタン表示テキスト |
| `agent` | string | **必須** | 遷移先エージェント名 |
| `prompt` | string | **必須** | 送信するプロンプト |
| `send` | boolean | - | 自動送信（default: `false`） |
| `model` | string | - | 遷移先で使用するモデル |

```yaml
handoffs:
  - label: "実装を開始"
    agent: implementation
    prompt: "上記のプランに基づいて実装してください"
    send: false
    model: "GPT-5 (copilot)"
```

## 呼び出し制御マトリクス

| 設定 | ピッカー表示 | サブエージェント呼び出し |
|---|---|---|
| 両方省略（デフォルト） | 表示 | 許可 |
| `user-invocable: false` | 非表示 | 許可 |
| `disable-model-invocation: true` | 表示 | 禁止 |
| 両方設定 | 非表示 | 禁止 |

## 配置場所

| パス | スコープ |
|---|---|
| `.github/agents/` | ワークスペース |
| `.claude/agents/` | ワークスペース（Claude形式） |
| `~/.copilot/agents/` | ユーザー（個人） |

## YAML 記述例

```yaml
---
name: Bug Fix Agent
description: "バグ修正に特化したエージェント。Use when: バグ修正、Issue対応、デバッグ"
tools: [read, edit, search, todo]
model: "Claude Sonnet 4"
argument-hint: "修正対象のIssue番号や概要"
user-invocable: true
github:
  permissions:
    contents: read
    issues: read
handoffs:
  - label: "コードレビューへ"
    agent: code-review
    prompt: "上記の修正をレビューしてください"
---
```

## 参考

- [VS Code 公式ドキュメント: Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
