# .agent.md 有効なフロントマタープロパティ一覧

## トップレベルプロパティ

| プロパティ | 型 | 必須 | 説明 |
|---|---|---|---|
| `name` | string | - | エージェント名（省略時はファイル名） |
| `description` | string | 必須 | 説明文（エージェント選択とサブエージェント検出に使用） |
| `tools` | list | - | 使用可能ツール（エイリアス、MCP、拡張ツール） |
| `model` | string / list | - | AIモデル（配列でフォールバック指定可） |
| `argument-hint` | string | - | チャット入力フィールドのヒントテキスト |
| `agents` | list | - | サブエージェント制限（`*` = 全許可、`[]` = 禁止） |
| `user-invocable` | boolean | - | ピッカー表示（default: true） |
| `disable-model-invocation` | boolean | - | サブエージェント呼び出し禁止（default: false） |
| `target` | string | - | `vscode` or `github-copilot` |
| `mcp-servers` | object | - | MCP サーバー構成 |
| `handoffs` | list | - | ハンドオフ定義 |
| `hooks` | object | - | フック定義（Preview） |
| `metadata` | object | - | 注釈データ |

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

## `github` オブジェクト

`github` 内では **`permissions` のみ有効**。`repository` や `issue-labels` は無効。

```yaml
github:
  permissions:
    contents: read
    issues: read
    pull-requests: write
```

## `handoffs` オブジェクト

```yaml
handoffs:
  - label: "ボタンラベル"
    agent: target-agent-name
    prompt: "送信するプロンプト"
    send: false          # 自動送信（default: false）
    model: "GPT-5 (copilot)"  # オプション
```

## 参考
- [VS Code 公式ドキュメント: Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
