#!/bin/bash
# Stop: セッション終了時に作業状態を保存する
SESSION_FILE=".github/hooks/scripts/.session-state.json"

# git の変更状態を収集
CHANGED_FILES=$(git diff --name-only 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
BRANCH=$(git branch --show-current 2>/dev/null)

# 状態をファイルに保存
cat > "$SESSION_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "branch": "${BRANCH:-unknown}",
  "changedFiles": "${CHANGED_FILES:-なし}",
  "stagedFiles": "${STAGED_FILES:-なし}"
}
EOF
