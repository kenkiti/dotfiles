# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する、Windows / WSL2 Ubuntu 共通の設定リポジトリです。

1 つのリポジトリから、OS・WSL・ホスト名を判定して、その環境に必要な設定だけを展開します。

## 対応環境

| 環境 | 展開されるもの |
| --- | --- |
| Windows 11 + PowerShell 7 | PowerShell プロファイル、Windows Terminal 設定、`.gitconfig`、Claude Code / Codex CLI のグローバル設定 |
| WSL2 Ubuntu | `.zshrc`、`.zprofile`、`.gitconfig`、Claude Code / Codex CLI のグローバル設定 |
| ネイティブ Linux | WSL 固有設定を除いた上記と同じ |

管理対象の完全な一覧は [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) を参照してください。

---

## 初回セットアップ

初回は `--apply` を付けず、**差分を確認してから適用**してください。
既存の設定を上書きするため、何が変わるかを見ずに適用しないでください。

```
chezmoi init kenkiti/dotfiles
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

構成を理解したあと、2 台目以降では次の短縮形が使えます。

```
chezmoi init --apply kenkiti/dotfiles
```

`chezmoi init` は `user.name` と `user.email` を対話で聞きます。
非対話で走らせたい場合は `--promptDefaults` を付けてください。

### Windows

```powershell
winget install --id twpayne.chezmoi -e

chezmoi init kenkiti/dotfiles
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

適用後、新しい PowerShell を開いて確認します。

```powershell
Get-Content $PROFILE          # chezmoi が入れたローダが 1 つだけあること
cdd                           # 作業ディレクトリへ移動できること
```

管理者権限は不要です。シンボリックリンクも作りません。

### WSL2 Ubuntu

```bash
sudo apt-get update && sudo apt-get install -y git zsh curl

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

chezmoi init kenkiti/dotfiles
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

zsh をログインシェルにする場合は別途 `chsh -s "$(which zsh)"` を実行してください
（このリポジトリは自動では変更しません）。

---

## 日常の使い方

| やりたいこと | コマンド |
| --- | --- |
| 管理対象のファイルを編集する | `chezmoi edit ~/.zshrc` |
| 手元で直接編集した内容を取り込む | `chezmoi re-add ~/.zshrc` |
| 新しいファイルを管理下に入れる | `chezmoi add ~/.foo` |
| 適用前に差分を見る | `chezmoi diff` |
| 適用する | `chezmoi apply` |
| リポジトリを最新にして適用する | `chezmoi update` |
| ソースディレクトリへ移動する | `chezmoi cd` |
| 何が管理されているか見る | `chezmoi managed` |
| 管理から外す（ファイルは残す） | `chezmoi forget ~/.foo` |

ソースディレクトリは既定で `~/.local/share/chezmoi`（Windows は
`%USERPROFILE%\.local\share\chezmoi`）です。リポジトリをどこに clone しても動きます。

---

## OS 別・ホスト別の設定

判定は chezmoi の標準データを使い、結果を `.chezmoi.toml.tmpl` の `[data]` にまとめています。
テンプレート側は `.isWindows` などの真偽値だけを見ます。

| 変数 | 判定方法 |
| --- | --- |
| `.isWindows` | `.chezmoi.os == "windows"` |
| `.isLinux` | `.chezmoi.os == "linux"` |
| `.isWSL` | `.chezmoi.kernel.osrelease` に `microsoft` / `wsl` が含まれる、または `WSL_DISTRO_NAME` が設定されている |
| `.isLinuxNative` | Linux かつ WSL でない |
| `.isCI` | `CI` または `DOTFILES_NONINTERACTIVE` が設定されている |

`.chezmoi.kernel.osrelease` は chezmoi が `/proc/sys/kernel/osrelease` から読む値で、
WSL2 では `...-microsoft-standard-WSL2` になります。外部コマンドを呼ばないため再現性があります。

ホスト固有の値は設定ファイル本体に書かず、[`.chezmoidata.yaml`](.chezmoidata.yaml) に集約しています。

```yaml
defaults:
  powershell:
    workDir: "~/Github"

hosts:
  DESKTOP-Corei5-8400:
    powershell:
      workDir: "D:\\Github"
```

新しい PC を足すときは `hosts:` にホスト名のブロックを追加し、
`defaults` と違う値だけ書きます。ホスト名は次で確認できます。

```
chezmoi execute-template '{{ .chezmoi.hostname }}'
```

OS ごとの出し分けは [`.chezmoiignore`](.chezmoiignore) が担当します。
Windows では `.zshrc` を、Linux では Windows Terminal 設定と
`.config/powershell` を展開しません。

---

## PowerShell

プロファイルの実体は `~/.config/powershell/Microsoft.PowerShell_profile.ps1` です。
`$PROFILE` そのものには 1 行のローダだけを置きます。

`$PROFILE` は固定パスではなく、OneDrive リダイレクトや日本語ロケールで
`OneDrive\ドキュメント\PowerShell\...` のように変わるため、chezmoi の静的な展開先にできません。
`.chezmoiscripts/run_onchange_after_20-install-powershell-profile.ps1.tmpl` が
適用時に `$PROFILE` を解決してローダを設置します。既存の `$PROFILE` は
`<$PROFILE>.pre-chezmoi.<timestamp>.bak` へ退避してから置き換えます。

編集は次で行います。

```powershell
chezmoi edit ~/.config/powershell/Microsoft.PowerShell_profile.ps1
chezmoi apply
reload
```

Windows PowerShell 5.1 にもローダを入れたい場合は、`.chezmoidata.yaml` の
`powershell.installWindowsPowerShell5Shim` を `true` にしてください。

---

## Windows Terminal

`settings.json` 全体を管理します。環境依存の値（既定プロファイル GUID、
開始ディレクトリ、フォント、配色）は `.chezmoidata.yaml` のテンプレート変数です。

`profiles.list` には、どの PC でも同じ値になる 2 つの GUID
（Windows PowerShell と PowerShell 7）だけを書いています。
WSL、Visual Studio、コマンドプロンプトなどの動的プロファイルは
Windows Terminal が起動時に自動生成するため、リポジトリに固定していません。
これにより、PC ごとに違う GUID やローカライズされたプロファイル名が混入しません。

旧方式の [`windows-terminal/actions.jsonc`](windows-terminal/actions.jsonc) は
参照用に残してあります。内容（`Ctrl+Shift+O` / `2` / `3` / `0` と
`Alt`+方向キーの無効化）は `settings.json` の `keybindings` に反映済みです。
`actions.jsonc` は JSONC（コメント付き）、`settings.json` は JSON なので、
コメントは移していません。

---

## zsh

`~/.zshrc` と `~/.zprofile` を管理します。内容は次の層に分かれています。

1. 共通の zsh 設定（補完・履歴・キーバインド）
2. ネイティブ Linux 専用
3. WSL 専用（`explorer.exe`、`clip.exe`、`/mnt` の警告）
4. ホスト固有（`.chezmoidata.yaml` の `hosts.<name>.zsh.extraLines`）
5. `~/.zshrc.local` / `~/.zprofile.local`

最後の層は **chezmoi 管理外・Git 管理外**です。秘密情報やその PC だけの設定はここに書きます。

```zsh
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

Oh My Zsh はインストール済みのときだけ読み込みます。未インストールの PC でも
zsh は正常に起動します。

---

## Claude Code / Codex CLI

静的で再利用可能な設定だけを管理します。認証情報・履歴・キャッシュ・
セッション・ログ・マシン固有 ID は管理しません。

| ツール | 管理するもの | 管理しないもの |
| --- | --- | --- |
| Claude Code | `~/.claude/CLAUDE.md`、`statusline-command.sh` | `settings.json`、`.credentials.json`、`history.jsonl`、`projects/`、`sessions/`、`plugins/`、キャッシュ、ログ |
| Codex CLI | `~/.codex/AGENTS.md` | `auth.json`、`config.toml`、`*.sqlite`、履歴、ログ、`installation_id` |

`~/.claude/settings.json` と `~/.codex/config.toml` は、どちらもツール自身が
書き戻すファイルです。管理すると `chezmoi apply` のたびに、後から追加された
hooks や信頼済みプロジェクトの登録が消えます。加えて両者ともユーザー名を含む
絶対パスを持つため、公開リポジトリに入れられません。
そのため管理対象外にしています。

Codex については、手書き相当の値だけを
[`docs/reference/codex-config.reference.toml`](docs/reference/codex-config.reference.toml)
に記録しています。

判断の根拠と完全な除外リストは [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) にあります。

---

## 秘密情報

このリポジトリに秘密値は入れません。詳細は [docs/SECRETS.md](docs/SECRETS.md) を参照してください。

| ファイル | 用途 | Git 管理 |
| --- | --- | --- |
| `~/.gitconfig.local` | `safe.directory`、署名鍵、credential helper | しない |
| `~/.zshrc.local` | 秘密情報を含むエイリアス | しない |
| `~/.zprofile.local` | API キーなどの環境変数 | しない |
| `~/.config/powershell/profile.local.ps1` | Windows のローカル専用設定 | しない |

Bitwarden / LastPass 連携は今回の移行では必須にしていません。
シークレットマネージャが無くても `chezmoi init --apply` は完走します。

---

## 依存ツールのインストール

`chezmoi apply` の前に `.chezmoiscripts/run_once_before_10-check-dependencies.*` が動き、
不足しているツールを**報告するだけ**です。勝手にインストールも権限昇格もしません。

自動インストールを許可する場合のみ、次のように明示します。

```powershell
$env:DOTFILES_INSTALL_PACKAGES = '1'; chezmoi apply
```

```bash
DOTFILES_INSTALL_PACKAGES=1 chezmoi apply
```

一度実行された `run_once_` スクリプトを再実行したい場合。

```
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

---

## CI

[`.github/workflows/chezmoi-test.yml`](.github/workflows/chezmoi-test.yml) が
`ubuntu-latest` と `windows-latest` で次を検証します。

1. YAML / TOML / JSON / JSONC / シェルの構文
2. chezmoi のインストールとソース状態の検証
3. すべてのテンプレートの評価
4. `chezmoi diff` と `chezmoi apply --dry-run`
5. 一時ディレクトリ（`RUNNER_TEMP` 配下）への適用
6. 期待するファイルの存在確認
7. OS 違いのファイルが展開されていないことの確認
8. 認証ファイルや秘密値パターンが出力に無いことの確認
9. 展開結果の JSON / zsh / PowerShell / gitconfig の構文検査
10. 未評価のテンプレート記法が残っていないことの確認
11. 2 回目の適用が no-op であること

CI は実ホームディレクトリを使いません。Bitwarden / LastPass へのログインもしません。
`CI=true` のとき `.chezmoi.toml.tmpl` は対話を行わず、ダミーの identity
(`ci@example.invalid`) を使います。

---

## 復旧

適用前に自動で作られるバックアップ:

- `$PROFILE` → `<$PROFILE>.pre-chezmoi.<timestamp>.bak`

それ以外は chezmoi が上書きするだけなので、**適用前に自分でバックアップを取ってください**。
手順は [docs/MIGRATION.md](docs/MIGRATION.md) にあります。

管理から外す（ファイルは `$HOME` に残る）:

```
chezmoi forget ~/.zshrc
```

一時的に元へ戻す:

```
cp ~/dotfiles-backup-<timestamp>/.zshrc ~/.zshrc
```

---

## トラブルシューティング

| 症状 | 対処 |
| --- | --- |
| `chezmoi diff` に大量の差分が出る | 手元のファイルが正なら `chezmoi re-add <path>`、リポジトリが正なら `chezmoi apply` |
| `chezmoi apply` がテンプレートエラーで落ちる | `chezmoi execute-template < <source file>` で該当箇所を特定する |
| 新しい PC でホスト固有設定が効かない | `chezmoi execute-template '{{ .chezmoi.hostname }}'` の出力と `.chezmoidata.yaml` の `hosts:` キーが一致しているか確認する |
| WSL 判定が効かない | `chezmoi execute-template '{{ .isWSL }}'` を確認する。`/proc/sys/kernel/osrelease` に `microsoft` が含まれない環境では `WSL_DISTRO_NAME` で判定する |
| PowerShell プロファイルが読み込まれない | `Get-Content $PROFILE` にローダがあるか、`Test-Path ~/.config/powershell/Microsoft.PowerShell_profile.ps1` を確認する |
| `run_once_` スクリプトが動かない | 既に実行済み。`chezmoi state delete-bucket --bucket=scriptState` で再実行できる |
| Windows Terminal のプロファイルが消えた | 動的プロファイルは再起動時に自動生成される。手動で追加したプロファイルは `.chezmoidata.yaml` 経由でテンプレートに足す |
| WSL 側で `.zshrc` の改行が壊れる | `.gitattributes` が `eol=lf` を強制している。`git config core.autocrlf` を確認し、必要なら `git rm --cached -r . && git reset --hard` で再チェックアウトする |
| `chezmoi apply` で `$PROFILE` を壊したくない | `chezmoi apply --exclude=scripts` でスクリプトを除いて適用できる |

---

## 関連ドキュメント

- [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) — 管理対象・管理対象外の完全な一覧と理由
- [docs/SECRETS.md](docs/SECRETS.md) — 秘密情報の扱いと将来の Bitwarden / LastPass 連携
- [docs/MIGRATION.md](docs/MIGRATION.md) — 旧シンボリックリンク方式からの移行手順と復旧
