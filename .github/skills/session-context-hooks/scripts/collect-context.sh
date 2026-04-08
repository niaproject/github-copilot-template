#!/bin/bash
# PreCompact: コンテキスト圧縮前に作業状態を収集し systemMessage として注入する
SESSION_FILE=".github/hooks/scripts/.session-state.json"

# git の変更状態を収集
CHANGED_FILES=$(git diff --name-only 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
BRANCH=$(git branch --show-current 2>/dev/null)

# 状態をファイルに保存（save-session でも使える）
cat > "$SESSION_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "branch": "${BRANCH:-unknown}",
  "changedFiles": "${CHANGED_FILES:-なし}",
  "stagedFiles": "${STAGED_FILES:-なし}"
}
EOF

# systemMessage を stdout に出力
MSG="コンテキストが圧縮されます。"
MSG="${MSG} ブランチ: ${BRANCH:-unknown}。"
[ -n "$CHANGED_FILES" ] && MSG="${MSG} 変更中のファイル: ${CHANGED_FILES}。"
[ -n "$STAGED_FILES" ] && MSG="${MSG} ステージ済み: ${STAGED_FILES}。"
MSG="${MSG} 作業中のタスクと進捗を確認してから続行してください。"

echo "{\"systemMessage\": \"${MSG}\"}"
