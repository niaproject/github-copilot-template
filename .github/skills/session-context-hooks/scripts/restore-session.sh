#!/bin/bash
# SessionStart: 新しいセッション開始時に前回の作業状態を復元する
SESSION_FILE=".github/hooks/scripts/.session-state.json"

# 状態ファイルが存在しない場合はスキップ
if [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

# 前回の状態を読み込む
TIMESTAMP=$(cat "$SESSION_FILE" | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
BRANCH=$(cat "$SESSION_FILE" | grep -o '"branch":"[^"]*"' | cut -d'"' -f4)
CHANGED=$(cat "$SESSION_FILE" | grep -o '"changedFiles":"[^"]*"' | cut -d'"' -f4)
STAGED=$(cat "$SESSION_FILE" | grep -o '"stagedFiles":"[^"]*"' | cut -d'"' -f4)

# systemMessage を構築
MSG="前回セッションの作業状態（${TIMESTAMP}）:"
MSG="${MSG} ブランチ: ${BRANCH}。"
[ "$CHANGED" != "なし" ] && MSG="${MSG} 変更中のファイル: ${CHANGED}。"
[ "$STAGED" != "なし" ] && MSG="${MSG} ステージ済み: ${STAGED}。"
MSG="${MSG} 前回の作業を確認して続行してください。"

echo "{\"systemMessage\": \"${MSG}\"}"
