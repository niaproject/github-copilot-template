---
name: session-context-hooks
description: "PreCompact + Stop + SessionStart でセッション状態を自動保存・復元する hooks を作成するスキル。Use when: コンテキスト圧縮対策、セッション間の状態引き継ぎ、systemMessage 注入、作業状態の自動保存"
---

# セッションコンテキスト hooks スキル

## When to Use
- コンテキスト圧縮時に作業状態を自動で引き継ぎたい
- セッション間で状態を保存・復元したい
- PreCompact / Stop / SessionStart の hooks を構築したい
- systemMessage で圧縮後のエージェントに情報を渡したい

## アーキテクチャ

```
SessionStart              PreCompact                 Stop
    │                         │                       │
    ▼                         ▼                       ▼
前回の状態を読み込み   → 圧縮前に状態を収集     → セッション終了時に保存
systemMessage で注入     systemMessage で注入       .session-state.json に書き出し
```

3つのイベントを組み合わせることで、あらゆるタイミングで状態が引き継がれる。

## Procedure

1. `.github/hooks/` に hooks JSON ファイルを作成する。
2. `.github/hooks/scripts/` にスクリプトを作成する（bash + PowerShell の両対応）。
3. `.gitignore` に `.session-state.json` を追加する。
4. VS Code 設定 `chat.useCustomAgentHooks` を有効にする。

## hooks JSON テンプレート

[hooks 定義テンプレート](./templates/session-hooks.json) を `.github/hooks/` にコピーして使用する。

## スクリプト

| スクリプト | イベント | 役割 |
|---|---|---|
| [collect-context.sh](./scripts/collect-context.sh) / [.ps1](./scripts/collect-context.ps1) | `PreCompact` | 圧縮前に git 状態を収集し systemMessage で注入 |
| [save-session.sh](./scripts/save-session.sh) / [.ps1](./scripts/save-session.ps1) | `Stop` | セッション終了時に状態をファイルに保存 |
| [restore-session.sh](./scripts/restore-session.sh) / [.ps1](./scripts/restore-session.ps1) | `SessionStart` | セッション開始時に前回の状態を復元し systemMessage で注入 |

## systemMessage に含まれる情報

スクリプトは以下の情報を自動収集して systemMessage に含めます:

- **タイムスタンプ**: 状態が記録された日時
- **ブランチ名**: 現在の git ブランチ
- **変更中のファイル**: `git diff` で検出された未コミットの変更
- **ステージ済みファイル**: `git diff --cached` で検出された変更

## 動作の流れ（すべて自動）

```
1. セッション開始 → restore-session が .session-state.json を読み込み systemMessage 注入
2. 作業中にコンテキスト上限に近づく → collect-context が状態を収集し systemMessage 注入
3. セッション終了 → save-session が状態を .session-state.json に保存
4. 次回セッション開始 → 1 に戻る
```

ユーザーは何も意識する必要がない。すべてバックグラウンドで自動実行される。

## 前提条件

- VS Code 設定: `"chat.useCustomAgentHooks": true`
- git リポジトリとして初期化済みであること
- `.session-state.json` を `.gitignore` に追加すること

## PowerShell 5.1 互換性の注意

Windows の PowerShell 5.1 で .ps1 を動作させるには以下が必須:

| 項目 | 理由 | 対処 |
|---|---|---|
| **UTF-8 BOM** | PS 5.1 は BOM なし UTF-8 をシステムロケール (Shift_JIS 等) で読むため日本語がパースエラーになる | `.ps1` ファイルを UTF-8 BOM 付きで保存する |
| **JSON 書き込み** | `Out-File -Encoding utf8` は PS 5.1 で BOM 付き出力し、bash 側で読めない | `[System.IO.File]::WriteAllText()` + `UTF8Encoding($false)` で BOM なし書き込み |
| **JSON 読み込み** | `Get-Content` はエンコーディング未指定だとロケール依存 | `-Encoding UTF8` を明示的に指定する |
| **UTC タイムスタンプ** | `Get-Date -Format "...Z"` はローカル時刻に文字 Z を付けるだけ | `(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")` を使用する |

## Constraints
- スクリプトの実行時間は 15 秒以内に収めること
- `.session-state.json` にシークレットを含めないこと
- bash (Linux/macOS) と PowerShell (Windows) の両方を用意すること
- `.ps1` ファイルは必ず UTF-8 BOM 付きで保存すること
