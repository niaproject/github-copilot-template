# hooks プロパティ リファレンス

> 情報源: [VS Code 公式ドキュメント](https://code.visualstudio.com/docs/copilot/customization/hooks) + 拡張機能ソースコード

## フックイベント

| イベント | トリガー | 主な用途 |
|---|---|---|
| `SessionStart` | 新しいセッション開始時 | 環境チェック、初期コンテキスト注入 |
| `UserPromptSubmit` | ユーザーがプロンプト送信時 | 入力バリデーション、ログ記録 |
| `PreToolUse` | ツール実行前 | 危険なコマンドのブロック、承認要求 |
| `PostToolUse` | ツール実行後 | lint、フォーマッタ、テスト自動実行 |
| `PreCompact` | コンテキスト圧縮前 | 状態保存、systemMessage 注入 |
| `SubagentStart` | サブエージェント開始時 | ログ記録、コンテキスト注入 |
| `SubagentStop` | サブエージェント終了時 | 結果の記録 |
| `Stop` | セッション終了時 | クリーンアップ、ログ出力 |

## JSON フォーマット

```json
{
  "hooks": {
    "<イベント名>": [
      {
        "type": "command",
        "command": "デフォルトコマンド",
        "windows": "Windows用コマンド",
        "linux": "Linux用コマンド",
        "osx": "macOS用コマンド",
        "cwd": "作業ディレクトリ",
        "env": { "KEY": "VALUE" },
        "timeout": 30
      }
    ]
  }
}
```

## コマンドプロパティ

| プロパティ | 型 | 必須 | 説明 |
|---|---|---|---|
| `type` | string | **必須** | `command` 固定 |
| `command` | string | **必須** | デフォルトで実行するシェルコマンド |
| `windows` | string | - | Windows 用のコマンド上書き |
| `linux` | string | - | Linux 用のコマンド上書き |
| `osx` | string | - | macOS 用のコマンド上書き |
| `cwd` | string | - | コマンド実行時の作業ディレクトリ |
| `env` | object | - | 環境変数（キー・値のペア） |
| `timeout` | number | - | タイムアウト（秒） |

## 出力制御（stdout JSON）

hooks は stdout で JSON を返すことで動作を制御できる。

### 共通出力

| キー | 型 | 効果 |
|---|---|---|
| `continue` | boolean | `false` で処理を中止 |
| `stopReason` | string | 中止理由メッセージ |
| `systemMessage` | string | コンテキストに注入するシステムメッセージ |

### PreToolUse 専用出力

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow | ask | deny",
    "permissionDecisionReason": "理由"
  }
}
```

| `permissionDecision` | 効果 |
|---|---|
| `allow` | ツール実行を許可 |
| `ask` | ユーザーに確認を求める |
| `deny` | ツール実行を拒否 |

### PostToolUse 専用出力

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "decision": "block"
  }
}
```

## 終了コード

| コード | 意味 |
|---|---|
| `0` | 成功 |
| `2` | ブロッキングエラー（処理中断） |
| その他 | 非ブロッキング警告 |

## 配置場所

| パス | スコープ |
|---|---|
| `.github/hooks/*.json` | ワークスペース（チーム共有、全エージェント共通） |
| `.claude/settings.json` | ワークスペース |
| `.claude/settings.local.json` | ワークスペースローカル（コミット対象外） |
| `~/.claude/settings.json` | ユーザーレベル |
| `.agent.md` フロントマター `hooks` | そのエージェントのみ（Preview、要 `chat.useCustomAgentHooks`） |

> `.github/hooks/` の JSON ファイルは全エージェントで共通実行される。特定エージェント専用にしたい場合はフロントマターの `hooks` を使用する。

## 前提条件

- VS Code 設定 `chat.useCustomAgentHooks` を `true` に設定する必要がある
- hooks は Preview 機能

## 参考

- [VS Code 公式ドキュメント: Hooks](https://code.visualstudio.com/docs/copilot/customization/hooks)
