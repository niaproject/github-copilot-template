# GitHub Copilot Template

GitHub Copilot の Agent と Skill のテンプレートリポジトリです。

## ディレクトリ構造

```
.github/
├── copilot-instructions.md              # ワークスペース共通指示
├── agents/
│   ├── bug-fix.agent.md                 # バグ修正エージェント
│   ├── agent-frontmatter-fixer.agent.md # フロントマター修正エージェント
│   └── skill-creator.agent.md           # SKILL.md 生成エージェント
└── skills/
    ├── fix-agent-frontmatter/           # .agent.md フロントマター修正スキル
    │   ├── SKILL.md
    │   └── references/valid-properties.md
    └── fix-skill-frontmatter/           # SKILL.md フロントマター修正スキル
        ├── SKILL.md
        └── references/valid-properties.md
docs/
├── agent-properties.md                  # .agent.md 属性リファレンス (Markdown)
├── agent-properties.html                # .agent.md 属性リファレンス (HTML)
├── skill-properties.md                  # SKILL.md 属性リファレンス (Markdown)
└── skill-properties.html                # SKILL.md 属性リファレンス (HTML)
```

## Agents

| エージェント | 説明 |
|---|---|
| Bug Fix Agent | バグ修正に特化したエージェント |
| Agent Frontmatter Fixer | `.agent.md` の YAML フロントマター警告・エラーを診断し修正 |
| Skill Creator | SKILL.md ファイルを生成 |

## Skills

| スキル | 説明 |
|---|---|
| `fix-agent-frontmatter` | `.agent.md` のフロントマター警告・YAML構文エラーを修正 |
| `fix-skill-frontmatter` | `SKILL.md` のフロントマター属性を診断し修正 |

## .agent.md 指定可能な属性

| プロパティ | 型 | 必須 | 説明 |
|---|---|---|---|
| `name` | string | - | エージェント名（省略時はファイル名） |
| `description` | string | **必須** | 説明文 |
| `tools` | list | - | 使用可能ツール |
| `model` | string / list | - | AIモデル |
| `argument-hint` | string | - | 入力ヒント |
| `agents` | list | - | サブエージェント制限 |
| `user-invocable` | boolean | - | ピッカー表示 (default: `true`) |
| `disable-model-invocation` | boolean | - | 自動呼び出し禁止 (default: `false`) |
| `target` | string | - | `vscode` or `github-copilot` |
| `mcp-servers` | object | - | MCP サーバー構成 |
| `handoffs` | list | - | ハンドオフ定義 |
| `hooks` | object | - | フック定義（Preview） |
| `metadata` | object | - | 注釈データ |
| `github.permissions` | object | - | GitHub 権限設定 |

## SKILL.md 指定可能な属性

| プロパティ | 型 | 必須 | 説明 |
|---|---|---|---|
| `name` | string | **必須** | スキル名（フォルダ名と一致必須、1〜64文字） |
| `description` | string | **必須** | 用途と使用タイミング（最大1024文字） |
| `argument-hint` | string | - | スラッシュコマンドのヒント |
| `user-invocable` | boolean | - | `/` メニュー表示 (default: `true`) |
| `disable-model-invocation` | boolean | - | 自動ロード無効化 (default: `false`) |
| `license` | string | - | ライセンス情報 |
| `compatibility` | object | - | 互換性情報 |
| `metadata` | object | - | メタデータ |

> **注意**: `model`, `tools`, `agents`, `target`, `handoffs` は `.agent.md` 専用であり、SKILL.md では使用できません。

## 参考

- [VS Code 公式: Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [VS Code 公式: Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Agent Skills 仕様: agentskills.io](https://agentskills.io/)