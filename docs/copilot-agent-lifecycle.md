# GitHub Copilot Agent ライフサイクル フローチャート

> GitHub Copilot Agent がユーザーのプロンプトを受け取ってから応答を返すまでの全体フロー

---

## 全体フロー

```mermaid
flowchart TD
    classDef startEnd fill:#6366f1,color:#fff,stroke:#4f46e5,stroke-width:2px,rx:20
    classDef process fill:#3b82f6,color:#fff,stroke:#2563eb,stroke-width:1px
    classDef decision fill:#f59e0b,color:#1f2937,stroke:#d97706,stroke-width:2px
    classDef hook fill:#10b981,color:#fff,stroke:#059669,stroke-width:2px
    classDef error fill:#ef4444,color:#fff,stroke:#dc2626,stroke-width:2px
    classDef data fill:#8b5cf6,color:#fff,stroke:#7c3aed,stroke-width:1px

    Start([🚀 セッション開始]):::startEnd
    SessionHook[/🪝 SessionStart Hook/]:::hook
    Input[📝 ユーザーがプロンプト送信]:::process
    SubmitHook[/🪝 UserPromptSubmit Hook/]:::hook
    Validate{入力検証}:::decision
    Block[🚫 ブロック・中止]:::error
    Analyze[🔍 プロンプト解析]:::process
    SkillMatch{スキル<br>マッチ?}:::decision
    LoadSkill[📦 SKILL.md 読み込み]:::data
    AgentMatch{エージェント<br>マッチ?}:::decision
    LoadAgent[🤖 .agent.md 読み込み]:::data
    Plan[📋 タスク計画生成]:::process
    ToolSelect[🛠️ ツール選択]:::process
    PreToolHook[/🪝 PreToolUse Hook/]:::hook
    Permission{許可判定}:::decision
    Deny[⛔ ツール実行拒否]:::error
    Ask[❓ ユーザー確認]:::process
    Execute[⚡ ツール実行]:::process
    PostToolHook[/🪝 PostToolUse Hook/]:::hook
    ToolResult{結果<br>評価}:::decision
    MoreTools{追加ツール<br>必要?}:::decision
    Compact{コンテキスト<br>圧縮?}:::decision
    PreCompactHook[/🪝 PreCompact Hook/]:::hook
    CompactExec[🗜️ コンテキスト圧縮]:::process
    SubAgent{サブエージェント<br>起動?}:::decision
    SubStartHook[/🪝 SubagentStart Hook/]:::hook
    SubExec[🤖 サブエージェント実行]:::process
    SubStopHook[/🪝 SubagentStop Hook/]:::hook
    Response[💬 応答生成]:::process
    StopHook[/🪝 Stop Hook/]:::hook
    End([✅ 完了]):::startEnd

    Start --> SessionHook
    SessionHook --> Input
    Input --> SubmitHook
    SubmitHook --> Validate
    Validate -->|OK| Analyze
    Validate -->|NG| Block
    Block -.-> Input
    Analyze --> SkillMatch
    SkillMatch -->|Yes| LoadSkill --> Plan
    SkillMatch -->|No| AgentMatch
    AgentMatch -->|Yes| LoadAgent --> Plan
    AgentMatch -->|No| Plan
    Plan --> ToolSelect
    ToolSelect --> PreToolHook
    PreToolHook --> Permission
    Permission -->|allow| Execute
    Permission -->|deny| Deny -.-> ToolSelect
    Permission -->|ask| Ask
    Ask -->|承認| Execute
    Ask -->|拒否| Deny
    Execute --> PostToolHook
    PostToolHook --> ToolResult
    ToolResult -->|成功| MoreTools
    ToolResult -->|失敗| ToolSelect
    MoreTools -->|Yes| Compact
    MoreTools -->|No| Response
    Compact -->|Yes| PreCompactHook --> CompactExec --> ToolSelect
    Compact -->|No| ToolSelect
    MoreTools -->|サブエージェント| SubAgent
    SubAgent -->|Yes| SubStartHook --> SubExec --> SubStopHook --> MoreTools
    SubAgent -->|No| Response
    Response --> StopHook --> End
```

---

## Hooks 発火タイミング

```mermaid
sequenceDiagram
    autonumber
    participant U as 👤 ユーザー
    participant A as 🤖 Agent
    participant H as 🪝 Hooks
    participant T as 🛠️ ツール

    rect rgb(99, 102, 241, 0.1)
        Note over U,T: セッション開始
        U->>A: セッション開始
        A->>H: SessionStart
        H-->>A: systemMessage 注入
    end

    rect rgb(59, 130, 246, 0.1)
        Note over U,T: プロンプト処理
        U->>A: プロンプト送信
        A->>H: UserPromptSubmit
        H-->>A: continue: true/false
    end

    rect rgb(245, 158, 11, 0.1)
        Note over U,T: ツール実行ループ
        A->>H: PreToolUse
        H-->>A: permissionDecision
        A->>T: ツール実行
        T-->>A: 実行結果
        A->>H: PostToolUse
        H-->>A: decision: block?
    end

    rect rgb(16, 185, 129, 0.1)
        Note over U,T: コンテキスト管理
        A->>H: PreCompact
        H-->>A: systemMessage (状態保存)
        A->>A: コンテキスト圧縮実行
    end

    rect rgb(139, 92, 246, 0.1)
        Note over U,T: セッション終了
        A->>H: Stop
        H-->>A: クリーンアップ完了
        A->>U: 応答返却
    end
```

---

## ツール許可判定フロー

```mermaid
flowchart LR
    classDef allow fill:#10b981,color:#fff,stroke:#059669
    classDef deny fill:#ef4444,color:#fff,stroke:#dc2626
    classDef ask fill:#f59e0b,color:#1f2937,stroke:#d97706

    A[PreToolUse Hook<br>実行] --> B{終了コード}
    B -->|0| C{permissionDecision}
    B -->|2| D[🚫 ブロッキングエラー<br>処理中断]:::deny
    B -->|その他| E[⚠️ 非ブロッキング警告<br>続行]

    C -->|allow| F[✅ ツール実行許可]:::allow
    C -->|deny| G[⛔ ツール実行拒否]:::deny
    C -->|ask| H[❓ ユーザーに確認]:::ask

    H -->|承認| F
    H -->|拒否| G

    E --> C
```

---

## 凡例

| 記号 | 意味 |
|:---:|---|
| 🟣 角丸ノード | 開始 / 終了 |
| 🔵 四角ノード | 処理ステップ |
| 🟡 ひし形ノード | 条件分岐 |
| 🟢 平行四辺形 | Hook 発火ポイント |
| 🔴 角丸ノード | エラー / ブロック |
| 💜 四角ノード | データ読み込み |
