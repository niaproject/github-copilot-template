# SKILL.md 有効なフロントマタープロパティ一覧

情報源: VS Code 公式ドキュメント + 拡張機能ソースコード (Zod スキーマ / `Uc` 列挙体)

## フロントマタープロパティ

| プロパティ | 型 | 必須 | デフォルト | 説明 |
|---|---|---|---|---|
| `name` | string | **必須** | - | スキル名。1〜64文字、小文字英数字+ハイフン。**親ディレクトリ名と一致必須** |
| `description` | string | **必須** | - | スキルの用途と使用タイミング。最大1024文字。トリガーワードを含めること |
| `argument-hint` | string | - | `undefined` | スラッシュコマンド呼び出し時に表示されるヒントテキスト |
| `user-invocable` | boolean | - | `true` | `/` メニュー（スラッシュコマンド）に表示するか |
| `disable-model-invocation` | boolean | - | `false` | モデルによる自動読み込みを無効化するか |
| `model` | string / list | - | `undefined` | 使用するAIモデル（配列でフォールバック指定可） |
| `tools` | list | - | `[]` | 使用可能ツール |
| `agents` | list | - | `undefined` | 使用可能サブエージェント |
| `target` | string | - | `undefined` | 実行ターゲット (`vscode`, `github-copilot`) |
| `handoffs` | list | - | `undefined` | ハンドオフ定義 |

## `user-invocable` と `disable-model-invocation` の動作マトリクス

| 設定 | `/` スラッシュコマンド | モデル自動ロード | ユースケース |
|---|---|---|---|
| 両方省略（デフォルト） | 表示される | 有効 | 汎用スキル |
| `user-invocable: false` | 非表示 | 有効 | バックグラウンド知識スキル |
| `disable-model-invocation: true` | 表示される | 無効 | オンデマンド専用スキル |
| 両方設定 | 非表示 | 無効 | 無効化されたスキル |

## `name` のルール
- 小文字英数字とハイフン (`-`) のみ使用可能
- 1〜64 文字
- **親ディレクトリ名と完全一致**しなければならない
- 例: `.github/skills/my-skill/SKILL.md` → `name: my-skill`

## `description` のベストプラクティス
- 最大 1024 文字
- "Use when:" パターンでトリガーワードを含める
- 具体的なキーワードを入れる（エージェントが検出に使用するため）
- 曖昧な表現（"便利なスキル"）は避ける

## プログレッシブローディング
1. **Discovery** (~100トークン): `name` と `description` のみ読み取り
2. **Instructions** (<5000トークン): 関連時に SKILL.md 本文をロード
3. **Resources**: 参照されたファイルのみ追加ロード

## フォルダ構造

```
.github/skills/<skill-name>/
├── SKILL.md           # 必須
├── scripts/           # 実行可能スクリプト
├── references/        # 参照ドキュメント
└── assets/            # テンプレート、ボイラープレート
```

## 配置場所

| パス | スコープ |
|---|---|
| `.github/skills/<name>/` | プロジェクト |
| `.agents/skills/<name>/` | プロジェクト |
| `.claude/skills/<name>/` | プロジェクト |
| `~/.copilot/skills/<name>/` | ユーザー（個人） |
| `~/.agents/skills/<name>/` | ユーザー（個人） |
| `~/.claude/skills/<name>/` | ユーザー（個人） |

## 参考
- [VS Code 公式ドキュメント: Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Agent Skills 仕様: agentskills.io](https://agentskills.io/)
