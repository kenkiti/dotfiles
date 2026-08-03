# 管理対象ファイル一覧

このリポジトリが chezmoi で `$HOME` に展開するファイルと、意図的に管理しないファイルの一覧です。

`chezmoi managed` を実行すると、その環境で実際に展開されるファイルを確認できます。

---

## 1. 全 OS 共通

| ソース | 展開先 | 種別 | 備考 |
| --- | --- | --- | --- |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | テンプレート | `safe.directory` などマシン固有設定は `~/.gitconfig.local` へ分離 |
| `private_dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | 静的 | Claude Code のグローバル指示 |
| `private_dot_claude/settings.json` | `~/.claude/settings.json` | 静的 | `hooks` を除いた共通設定。下記参照 |
| `private_dot_claude/executable_statusline-command.sh` | `~/.claude/statusline-command.sh` | 静的 | ステータスライン生成スクリプト |
| `private_dot_codex/AGENTS.md` | `~/.codex/AGENTS.md` | 静的 | Codex CLI のグローバル指示 |
| `private_dot_codex/config.toml.tmpl` | `~/.codex/config.toml` | テンプレート | 共有する設定キーのみ。下記参照 |

## 2. Windows のみ

| ソース | 展開先 | 種別 |
| --- | --- | --- |
| `dot_config/powershell/Microsoft.PowerShell_profile.ps1.tmpl` | `~/.config/powershell/Microsoft.PowerShell_profile.ps1` | テンプレート |
| `AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.tmpl` | Windows Terminal `settings.json` | テンプレート |
| `.chezmoiscripts/run_once_before_10-check-dependencies.ps1.tmpl` | （スクリプト） | 依存ツール確認 |
| `.chezmoiscripts/run_onchange_after_20-install-powershell-profile.ps1.tmpl` | （スクリプト） | `$PROFILE` へローダを設置 |

### PowerShell プロファイルが `$PROFILE` 直接管理でない理由

`$PROFILE` は固定パスではありません。`Documents` フォルダは OneDrive にリダイレクトされることがあり、
日本語環境では `ドキュメント` にローカライズされます。実際にこの環境では次の値でした。

```
C:\Users\<user>\OneDrive\ドキュメント\PowerShell\Microsoft.PowerShell_profile.ps1
```

chezmoi の展開先は静的パスなので、この値をリポジトリに書くと他の PC で壊れます。
そのため本体は `~/.config/powershell/` に置き、`run_onchange_after_20-*` スクリプトが
実行時に `$PROFILE` を解決して 1 行のローダを設置します。
既存の `$PROFILE`（旧方式のシンボリックリンクを含む）は
`<$PROFILE>.pre-chezmoi.<timestamp>.bak` へ退避してから置き換えます。

## 3. Linux / WSL のみ

| ソース | 展開先 | 種別 |
| --- | --- | --- |
| `dot_zshrc.tmpl` | `~/.zshrc` | テンプレート |
| `dot_zprofile.tmpl` | `~/.zprofile` | テンプレート |
| `.chezmoiscripts/run_once_before_10-check-dependencies.sh.tmpl` | （スクリプト） | 依存ツール確認 |

---

## 4. Claude Code (`~/.claude`) の管理方針

### 管理する

| ファイル | 理由 |
| --- | --- |
| `CLAUDE.md` | 手書きの静的なグローバル指示。秘密情報なし |
| `settings.json` | 手書き設定。ただし `hooks` は除く（下記） |
| `statusline-command.sh` | 手書きシェルスクリプト。stdin の JSON を整形するだけ |

### `settings.json` から `hooks` を除いている理由

管理しているのは、どの PC でも共通の設定だけです。

`statusLine` / `enabledPlugins` / `extraKnownMarketplaces` /
`autoUpdatesChannel` / `skipDangerousModePermissionPrompt` / `theme` / `model`

`hooks` は**意図的に含めていません**。実環境の `hooks` は
`Notification`、`Stop`、`SessionStart`、`SessionEnd`、`PermissionRequest`、
`PreToolUse` の 6 種が `AgentSupervisor.App.exe` を呼ぶ構成でしたが、
そのコマンドは `C:\Users\<ユーザー名>\OneDrive\デスクトップ\...` という
**ユーザー名を含む絶対パス**で、この PC 固有のものです。
公開リポジトリに入れられず、他の PC では動きません。

> **⚠ 運用上の注意**
>
> Claude Code の `settings.json` には include の仕組みがありません。
> そのため `chezmoi apply` を実行すると、**その PC でローカルに設定した
> `hooks` は削除されます**。
>
> hooks を使っている PC では、apply のあとに設定し直すか、
> apply 前に退避してください。
>
> ```powershell
> Copy-Item "$HOME\.claude\settings.json" "$HOME\.claude\settings.json.bak"
> ```
>
> hooks を PC ごとに自動で復元したい場合は、`settings.json` をテンプレート化し
> `.chezmoidata.yaml` の `hosts:` から注入する構成に変更できます。

`enabledPlugins` は Claude Code 自身も書き換えます。UI からプラグインを
切り替えた場合は `chezmoi re-add ~/.claude/settings.json` で取り込んでください。

この PC の `skipDangerousModePermissionPrompt: true` は権限確認プロンプトを
省略する設定です。新しい PC へ展開する前に意図した値か確認してください。

### 管理しない

| パス | 分類 | 理由 |
| --- | --- | --- |
| `settings.json` の `hooks` | マシン固有 | 上記のとおり |
| `.credentials.json` | 認証情報 | OAuth トークン |
| `history.jsonl` | 履歴 | 会話履歴 |
| `projects/` | 状態 | プロジェクト単位のセッション状態 |
| `sessions/`, `session-env/` | 状態 | 実行中セッション |
| `shell-snapshots/` | 状態 | シェルスナップショット |
| `file-history/` | 状態 | ファイル編集履歴 |
| `backups/` | 生成物 | `.claude.json` の自動バックアップ |
| `cache/`, `paste-cache/`, `stats-cache.json` | キャッシュ | 再生成される |
| `daemon/`, `daemon.log`, `debug/` | ログ | ログと実行状態 |
| `plugins/` | 生成物 | マーケットプレイスから再取得される |
| `jobs/`, `tasks/`, `chrome/`, `downloads/` | 状態 | 実行状態・一時データ |
| `.last-cleanup`, `.last-update-result.json` | 状態 | マシン固有の実行記録 |

これらは `.chezmoiignore` に明示的に列挙してあります。誤ってコミットされても展開されません。

---

## 5. Codex CLI (`~/.codex`) の管理方針

### 管理する

| ファイル | 理由 |
| --- | --- |
| `AGENTS.md` | 手書きの静的なグローバル指示。`~/.claude/CLAUDE.md` と同一内容 |
| `config.toml` | 手書きの設定キーのみ。実行状態のセクションは含めない（下記） |

### `config.toml` で管理しているもの・していないもの

`~/.claude/settings.json` と同じ方針です。**1 つのファイルの中で、
共有したい設定キーだけを管理し、Codex CLI が書き戻す実行状態は持ちません。**

管理するキー:

```toml
model, model_reasoning_effort, service_tier
[features]        js_repl
[windows]         sandbox        # Windows でのみ展開
[profiles.vault]  approval_policy, sandbox_mode
```

含めないセクションと理由:

| セクション | 理由 |
| --- | --- |
| `[projects.'<絶対パス>']` | 信頼済みプロジェクトの一覧。このマシン固有のローカルパスが露出する |
| `[mcp_servers.*]` | インストール先にハッシュを含む絶対パス |
| `notify` | 同じくインストール先の絶対パス |
| `[marketplaces.*]`, `[plugins.*]` | アプリが書き戻す登録状態 |
| `[tui.*]`, `[desktop.*]` | UI の状態とテーマ |
| `[shell_environment_policy]` | ランタイムが差し込む環境変数 |

> **⚠ 運用上の注意**
>
> Codex CLI は `config.toml` に上記セクションを**実行中に追記し続けます**。
> そのため `chezmoi apply` を実行すると、**信頼済みプロジェクトの登録
> (`[projects.*]`) やプラグインの有効状態が削除されます。**
> 信頼は次回そのディレクトリで作業したときに再承認が必要です。
>
> `~/.claude/settings.json` の `hooks` と同じトレードオフですが、
> こちらは発生頻度が高くなります。
>
> apply の前に退避しておくと復元できます。
>
> ```powershell
> Copy-Item "$HOME\.codex\config.toml" "$HOME\.codex\config.toml.bak"
> ```
>
> 信頼済みプロジェクトを消したくない場合は、
> `.chezmoidata.yaml` の `hosts:` にパス一覧を書いてテンプレートから生成する
> 構成に変更できます。ただしローカルのパス一覧が公開リポジトリに載ります。

### 管理しない

| パス | 分類 |
| --- | --- |
| `auth.json` | 認証情報 |
| `config.toml` の `[projects.*]` などの実行状態セクション | マシン固有 + 実行状態（上記） |
| `cap_sid`, `installation_id` | マシン固有 ID |
| `history.jsonl`, `session_index.jsonl`, `transcription-history.jsonl` | 履歴 |
| `*.sqlite`, `*.sqlite-shm`, `*.sqlite-wal` | データベース（`logs_2.sqlite` は 160MB） |
| `*.log`, `sandbox.*.log` | ログ |
| `.codex-global-state.json(.bak)` | 実行状態 |
| `models_cache.json`, `version.json` | キャッシュ |
| `chrome-native-hosts*.json` | マシン固有 |
| `.sandbox/`, `.sandbox-bin/`, `.sandbox-secrets/`, `.tmp/`, `tmp/` | 一時・秘密 |
| `sessions/`, `cache/`, `memories/`, `plugins/`, `rules/`, `skills/`, `browser/`, `attachments/`, `vendor_imports/` | 生成物・実行状態 |

`vault.config.toml` は手書きですが、UNC 共有パスや `C:\GTD` などこのマシン固有のパスを
前提とした内容だったため管理対象外にしています。

---

## 6. リポジトリに残しているが展開しないファイル

`.chezmoiignore` で除外済みです。

| パス | 用途 |
| --- | --- |
| `README.md`, `TODO.md`, `AGENTS.md`, `docs/` | ドキュメント |
| `powershell/Microsoft.PowerShell_profile.ps1` | 旧方式（シンボリックリンク）の実体。移行完了までは残す。[docs/MIGRATION.md](MIGRATION.md) 参照 |
| `windows-terminal/actions.jsonc` | 旧方式の Windows Terminal キーバインド。内容は `settings.json.tmpl` の `keybindings` に反映済み |

---

## 7. Git 管理しないローカル専用ファイル

いずれも chezmoi の管理対象外です。存在しなくても動作します。

| パス | 用途 |
| --- | --- |
| `~/.gitconfig.local` | `safe.directory`、署名鍵、業務用アカウント |
| `~/.zshrc.local` | 秘密情報、ローカル専用エイリアス |
| `~/.zprofile.local` | 秘密情報を含む環境変数 |
| `~/.config/powershell/profile.local.ps1` | Windows のローカル専用設定 |

詳細は [SECRETS.md](SECRETS.md) を参照してください。
