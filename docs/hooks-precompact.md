# hooks.PreCompact リファレンス

## 概要

`PreCompact` はコンテキストウィンドウが上限に近づき、**コンテキスト圧縮（compaction）が実行される直前**に発火するフックイベントです。圧縮で失われる情報を保存したり、圧縮後のコンテキストに重要な情報を注入するために使用します。

## トリガー条件

チャットの会話が長くなり、トークン数がモデルのコンテキストウィンドウ上限に近づくと、VS Code は自動的にコンテキスト圧縮を開始します。`PreCompact` はその圧縮処理の**直前**に実行されます。

## ユースケース

| ユースケース | 説明 |
|---|---|
| 作業状態の保存 | 圧縮前に現在のタスク進捗・編集中ファイル・変数をファイルに書き出す |
| systemMessage の注入 | 圧縮後に引き継ぎたい情報をエージェントに渡す |
| スナップショット記録 | 作業ログや状態のスナップショットを記録する |
| 通知・ログ | 圧縮が発生したことをログに記録する |

## 出力で制御できること

stdout で JSON を返すと、以下を制御できます:

| キー | 型 | 効果 |
|---|---|---|
| `continue` | boolean | `false` にすると圧縮を中止する |
| `stopReason` | string | 中止する場合の理由メッセージ |
| `systemMessage` | string | **圧縮後のコンテキストに注入するメッセージ** |

`systemMessage` が最も実用的なキーです。圧縮で通常失われる情報（タスクの進捗、作業中のファイル一覧、重要な決定事項など）をエージェントに引き継げます。

## なぜ systemMessage が必要か

コンテキスト圧縮が発生すると、**会話の初期部分が要約・削除されます**。これにより以下の情報が失われます:

| 失われる情報 | 具体例 |
|---|---|
| タスクの目的 | 「セキュリティ脆弱性を修正する」という最初の依頼 |
| 作業の進捗 | 5ステップ中3ステップ完了している事実 |
| 重要な決定事項 | 「方式Aではなく方式Bで実装する」と決めた経緯 |
| 編集中のファイル | どのファイルを変更したか |
| 制約条件 | ユーザーが途中で追加した条件 |

圧縮後のエージェントは、**要約された短いコンテキスト + 直近の数ターン**しか見えません。`systemMessage` を返すと、圧縮後のコンテキストにその内容が**強制的に残ります**。

```
圧縮前: [依頼] [調査] [議論] [決定] [実装1] [実装2] [実装3]
                ↓ 圧縮
圧縮後: [systemMessage: 進捗と決定事項] [実装2] [実装3]
```

`systemMessage` がなければ、圧縮後にエージェントが同じ質問を繰り返したり、別のアプローチに切り替えてしまうリスクがあります。

## 圧縮の流れ（すべて自動）

```
1. コンテキストが上限に近づく
2. PreCompact フックが自動実行 → systemMessage を生成
3. VS Code が古い会話を自動圧縮
4. systemMessage がコンテキストに自動注入
5. エージェントがそのまま作業を継続
```

### ユーザーは何も意識する必要がない

- `systemMessage` は **AI（エージェント）だけが読む内部情報** であり、チャット画面にはユーザーに表示されない
- 圧縮もフック実行も **すべてバックグラウンドで自動実行** される
- ユーザーから見ると、会話が途切れることなくそのまま続く
- フックを一度設定しておけば、以降の全セッションで自動的に動作する
- ユーザーが「圧縮が起きた」と気づくことすらない場合もある

### systemMessage に書かれる具体的な内容

`systemMessage` の内容はフックのコマンドが出力する JSON で決まります。スクリプトで動的に生成する場合、以下のような情報が含まれます:

```
圧縮前の状態:
- タスク: bug-fix.agent.md のフロントマター修正
- 進捗: 5ステップ中3ステップ完了（分析→調査→修正適用済み、検証・報告が残り）
- 変更済みファイル: .github/agents/bug-fix.agent.md, docs/agent-properties.md
- 決定事項: github.repository は削除せず github.permissions に変換する
- 未完了: README.md の更新、エラー解消の最終確認
```

これにより圧縮後のエージェントは「何のタスクを」「どこまで進めて」「何が残っているか」を正確に把握できます。

静的な固定メッセージの場合は、設定時に書いた文字列がそのまま注入されます:

```json
{"systemMessage": "作業中のタスクとファイルの状態を確認してから続行してください"}
```

## サンプル

### 基本: 圧縮発生をログに記録

```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "echo \"[$(date)] Context compaction triggered\" >> .github/hooks/compact.log",
        "windows": "echo [%date% %time%] Context compaction triggered >> .github\\hooks\\compact.log",
        "timeout": 10
      }
    ]
  }
}
```

### systemMessage を注入して作業状態を引き継ぐ

```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "echo '{\"systemMessage\": \"コンテキストが圧縮されました。作業中のファイルと進捗状況を確認してから続行してください。\"}'",
        "windows": "echo {\"systemMessage\": \"コンテキストが圧縮されました。作業中のファイルと進捗状況を確認してから続行してください。\"}",
        "timeout": 10
      }
    ]
  }
}
```

### スクリプトで動的に状態を収集して注入

```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "./scripts/collect-context.sh",
        "windows": "powershell -File .\\scripts\\collect-context.ps1",
        "timeout": 15
      }
    ]
  }
}
```

`collect-context.sh` の例:

```bash
#!/bin/bash
# git の変更状態を収集して systemMessage として返す
CHANGED_FILES=$(git diff --name-only 2>/dev/null | tr '\n' ', ')
echo "{\"systemMessage\": \"圧縮前の状態 - 変更中のファイル: ${CHANGED_FILES:-なし}\"}"
```

`collect-context.ps1` の例:

```powershell
# git の変更状態を収集して systemMessage として返す
$changedFiles = (git diff --name-only 2>$null) -join ', '
if (-not $changedFiles) { $changedFiles = "なし" }
Write-Output "{`"systemMessage`": `"圧縮前の状態 - 変更中のファイル: $changedFiles`"}"
```

### 圧縮を条件付きで中止する

```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "./scripts/check-compact.sh",
        "timeout": 10
      }
    ]
  }
}
```

`check-compact.sh` の例:

```bash
#!/bin/bash
# 重要な処理中なら圧縮を中止する
if [ -f ".compact-lock" ]; then
  echo '{"continue": false, "stopReason": "重要な処理中のため圧縮を中止しました"}'
else
  echo '{"systemMessage": "コンテキストが圧縮されます。作業状態を確認してください。"}'
fi
```

## 注意事項

- `PreCompact` は自動的に発火するため、ユーザーが意図的にトリガーすることはできない
- `timeout` は短めに設定する（推奨: 10〜15秒）。長い hooks は圧縮を遅延させる
- `continue: false` で圧縮を中止すると、コンテキストが溢れてエラーになる可能性がある
- ファイルへの書き出しは非同期的な問題を避けるため、単純なコマンドに留める

## 参考

- [VS Code 公式ドキュメント: Hooks](https://code.visualstudio.com/docs/copilot/customization/hooks)
- [hooks プロパティ リファレンス](./hooks-properties.md)
