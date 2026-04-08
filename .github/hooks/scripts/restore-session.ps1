# SessionStart: 新しいセッション開始時に前回の作業状態を復元する
$ErrorActionPreference = "SilentlyContinue"
$sessionFile = ".github\hooks\scripts\.session-state.json"

# 状態ファイルが存在しない場合はスキップ
if (-not (Test-Path $sessionFile)) {
    exit 0
}

# 前回の状態を読み込む
$state = Get-Content $sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json

$timestamp = $state.timestamp
$branch = $state.branch
$changed = $state.changedFiles
$staged = $state.stagedFiles

# systemMessage を構築
$msg = "前回セッションの作業状態（${timestamp}）:"
$msg += " ブランチ: $branch。"
if ($changed -ne "なし") { $msg += " 変更中のファイル: $changed。" }
if ($staged -ne "なし") { $msg += " ステージ済み: $staged。" }
$msg += " 前回の作業を確認して続行してください。"

Write-Output "{`"systemMessage`": `"$msg`"}"
