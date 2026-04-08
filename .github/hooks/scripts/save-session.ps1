# Stop: セッション終了時に作業状態を保存する
$ErrorActionPreference = "SilentlyContinue"
$sessionFile = ".github\hooks\scripts\.session-state.json"

# git の変更状態を収集
$changedFiles = (git diff --name-only 2>$null) -join ', '
$stagedFiles = (git diff --cached --name-only 2>$null) -join ', '
$branch = git branch --show-current 2>$null

if (-not $changedFiles) { $changedFiles = "なし" }
if (-not $stagedFiles) { $stagedFiles = "なし" }
if (-not $branch) { $branch = "unknown" }

# 状態をファイルに保存
$state = @{
    timestamp    = ((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    branch       = $branch
    changedFiles = $changedFiles
    stagedFiles  = $stagedFiles
} | ConvertTo-Json -Compress
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$fullPath = Join-Path (Get-Location) $sessionFile
[System.IO.File]::WriteAllText($fullPath, $state, $utf8NoBom)
