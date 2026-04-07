# hooks リファレンス

## フックイベント一覧

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
        "windows": "Windows用コマンド（オプション）",
        "linux": "Linux用コマンド（オプション）",
        "osx": "macOS用コマンド（オプション）",
        "cwd": "作業ディレクトリ（オプション）",
        "env": { "KEY": "VALUE" },
        "timeout": 30
      }
    ]
  }
}
```

## 各プロパティ

| プロパティ | 必須 | 説明 |
|---|---|---|
| `type` | **必須** | `command` 固定 |
| `command` | **必須** | デフォルトで実行するコマンド |
| `windows` | - | Windows 用のコマンド上書き |
| `linux` | - | Linux 用のコマンド上書き |
| `osx` | - | macOS 用のコマンド上書き |
| `cwd` | - | 作業ディレクトリ |
| `env` | - | 環境変数 |
| `timeout` | - | タイムアウト（秒） |

## 出力制御（stdout JSON）

hooks は stdout で JSON を返すと動作を制御できる:

| キー | 効果 |
|---|---|
| `continue` | `false` で処理を中止 |
| `stopReason` | 中止理由メッセージ |
| `systemMessage` | コンテキストに注入するメッセージ |

### PreToolUse 専用出力

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "理由"
  }
}
```

`permissionDecision` の値:
- `allow`: ツール実行を許可
- `ask`: ユーザーに確認を求める
- `deny`: ツール実行を拒否

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
| `.github/hooks/` | ワークスペース（チーム共有） |
| `.claude/settings.json` | ワークスペース |
| `.claude/settings.local.json` | ワークスペースローカル（コミット対象外） |
| `~/.claude/settings.json` | ユーザーレベル |

## サンプル

### PostToolUse で eslint 実行
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "npx eslint --fix ${file}",
        "windows": "npx eslint --fix %file%",
        "timeout": 30
      }
    ]
  }
}
```

### PreToolUse で危険コマンドをブロック
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "./scripts/validate-tool.sh",
        "timeout": 15
      }
    ]
  }
}
```

### PreCompact で状態保存
```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "echo '{\"systemMessage\": \"作業状態を確認してから続行してください\"}'",
        "timeout": 10
      }
    ]
  }
}
```

## 参考
- [VS Code 公式ドキュメント: Hooks](https://code.visualstudio.com/docs/copilot/customization/hooks)
