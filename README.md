# dotfiles

Windows 11、WSL2 Ubuntu、Ubuntu の設定を [chezmoi](https://www.chezmoi.io/) で管理します。
OS・WSL・ホスト名を判定し、その環境に必要な設定だけをホームへ展開します。

> 公開リポジトリです。認証情報、APIキー、トークン、Cookieは入れないでください。

## 日常の作業

普段はこの3ステップです。

```bash
chezmoi edit ~/.zshrc   # 管理している原本を編集
chezmoi diff            # 反映内容を確認
chezmoi apply           # ホームへ反映
```

PowerShellも同じです。

```powershell
chezmoi edit ~/.config/powershell/Microsoft.PowerShell_profile.ps1
chezmoi diff
chezmoi apply
```

### よく編集する設定

迷ったらホーム側のパスを `chezmoi edit` で開いてください。対応するソースをchezmoiが選びます。

| 変更したいもの | コマンド |
| --- | --- |
| zsh | `chezmoi edit ~/.zshrc` |
| Powerlevel10k | `chezmoi edit ~/.p10k.zsh` |
| Git | `chezmoi edit ~/.gitconfig` |
| PowerShell | `chezmoi edit ~/.config/powershell/Microsoft.PowerShell_profile.ps1` |
| Claude Code | `chezmoi edit ~/.claude/CLAUDE.md` |
| Codex | `chezmoi edit ~/.codex/AGENTS.md` |

`.tmpl` で終わるソースはテンプレートです。`~/.zshrc` などを直接編集しても
`chezmoi re-add` では取り込まれないため、必ず `chezmoi edit` を使います。

```bash
chezmoi source-path ~/.zshrc   # 対応するソースを確認
```

### 別PCの変更を受け取る

差分を確認してから反映します。

```bash
chezmoi git pull
chezmoi diff
chezmoi apply
```

取得と反映をまとめる場合は `chezmoi update` を使います。

### 新しいファイルを管理する

```bash
chezmoi add ~/.foo              # 普通のファイル
chezmoi add --template ~/.foo   # OSやホストで内容を変えるファイル
chezmoi forget ~/.foo           # 管理をやめる。ホームのファイルは残る
```

### Gitへ記録する

```bash
chezmoi cd
git status
git diff
git add <変更ファイル>
git commit -m "変更内容"
git push
exit
```

## 初回セットアップ

初回は既存設定をバックアップし、差分を確認してから適用します。

### 1. インストール

Windows:

```powershell
winget install --id twpayne.chezmoi -e
```

直後にコマンドが見つからなければ、新しいPowerShellを開きます。

Ubuntu / WSL2:

```bash
sudo apt-get update
sudo apt-get install -y git zsh curl fzf
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
```

### 2. バックアップ

Windows:

```powershell
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = "$HOME\dotfiles-backup-$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item $PROFILE $backup -ErrorAction SilentlyContinue
Copy-Item "$HOME\.gitconfig" $backup -ErrorAction SilentlyContinue
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" $backup -ErrorAction SilentlyContinue
$backup
```

Ubuntu / WSL2:

```bash
stamp=$(date +%Y%m%d-%H%M%S)
backup="$HOME/dotfiles-backup-$stamp"
mkdir -p "$backup"
for file in .zshrc .zprofile .profile .gitconfig .p10k.zsh; do
  [[ -f "$HOME/$file" ]] && cp "$HOME/$file" "$backup/"
done
printf "backup: %s\n" "$backup"
```

### 3. 初期化

```bash
chezmoi init kenkiti/dotfiles
```

Gitの名前とメールアドレスを聞かれます。この時点ではホームは変更されません。

すでに別の場所へcloneしている場合は、chezmoiの既定ソース位置からリンクします。

```bash
# Linux / WSL
mkdir -p ~/.local/share
ln -s /path/to/dotfiles ~/.local/share/chezmoi
```

```powershell
# Windows
New-Item -ItemType Directory -Path "$HOME\.local\share" -Force | Out-Null
New-Item -ItemType Junction -Path "$HOME\.local\share\chezmoi" -Target "D:\Github\dotfiles"
```

### 4. 差分確認と適用

```bash
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

`status` の記号は、`A` が追加、`M` が変更、`D` が削除、`R` がスクリプト実行です。

適用後の確認:

```bash
zsh -n ~/.zshrc
exec zsh
```

```powershell
Get-Content $PROFILE
git config --get-all safe.directory
```

## 管理対象

そのPCでの実際の一覧は `chezmoi managed` で確認できます。

| 環境 | 主な設定 |
| --- | --- |
| 共通 | Git、Claude Code、Codex |
| Windows | PowerShell、Windows Terminal |
| Ubuntu / WSL2 | zsh、Oh My Zsh、Powerlevel10k |

完全な一覧は [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) にあります。

### Oh My Zsh

次を管理しています。

- テーマ: Powerlevel10k
- プラグイン: `git`、`fzf`、`zsh-autosuggestions`、`zsh-syntax-highlighting`
- Powerlevel10k設定: `~/.p10k.zsh`

テーマと外部プラグインは [`.chezmoiexternal.toml`](.chezmoiexternal.toml) に取得元と
コミットを固定しています。`chezmoi apply` が次へ展開します。

```text
~/.oh-my-zsh/custom/themes/powerlevel10k
~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

Oh My Zsh本体も `.chezmoiexternal.toml` から取得されます。`fzf` はUbuntuのパッケージとして
別途インストールが必要です。テーマやプラグインを更新するときは、
`.chezmoiexternal.toml` のURLに含まれるコミットを変更します。

## PC・OSごとの設定

共通値とホスト固有値は [`.chezmoidata.yaml`](.chezmoidata.yaml) に置きます。
ホスト名や絶対パスを各テンプレートへ直接書きません。

```yaml
defaults:
  powershell:
    workDir: "~/Github"

hosts:
  DESKTOP-Corei5-8400:
    powershell:
      workDir: "D:\\Github"
```

```bash
chezmoi execute-template "{{ .chezmoi.hostname }}"
```

テンプレートの環境判定には `.isWindows`、`.isLinux`、`.isWSL`、
`.isLinuxNative`、`.isCI` を使います。OSごとの展開対象は
[`.chezmoiignore`](.chezmoiignore) で制御します。

## ローカル設定と秘密情報

PCだけで使う値は、chezmoi管理外のファイルへ置きます。

| ファイル | 用途 |
| --- | --- |
| `~/.gitconfig.local` | `safe.directory`、署名鍵、仕事用Git設定 |
| `~/.zshrc.local` | ローカル専用エイリアス |
| `~/.zprofile.local` | 秘密を含む環境変数 |
| `~/.config/powershell/profile.local.ps1` | Windows固有設定 |

Claude CodeとCodexの認証情報も管理しません。詳細は
[docs/SECRETS.md](docs/SECRETS.md) を参照してください。

### Claude Code / Codexの注意

`~/.claude/settings.json` と `~/.codex/config.toml` は、アプリが追記するマシン固有状態を
ソースに含めていません。`chezmoi apply` により、Claude Codeのローカル `hooks` や、
Codexの `[projects.*]`、MCP、プラグイン登録状態が消える場合があります。
必要なら適用前にバックアップしてください。

## PowerShellプロファイル

`$PROFILE` はOneDriveやロケールによって場所が変わるため、本体を次で管理します。

```text
~/.config/powershell/Microsoft.PowerShell_profile.ps1
```

適用スクリプトが実際の `$PROFILE` にローダーを設置し、既存ファイルは
`<$PROFILE>.pre-chezmoi.<日時>.bak` へ退避します。スクリプトを動かしたくない場合は
`chezmoi apply --exclude=scripts` を使います。

## 直接編集してしまった場合

適用時に `has changed since chezmoi last wrote it` と表示されたら、まず `diff` を選びます。

- 手元を残す: `skip` の後に `chezmoi merge <パス>`
- ソースを採用: `overwrite`
- 中止: `quit`

テンプレートでないファイルは `chezmoi re-add <パス>` でも取り込めます。

## トラブルシューティング

| 症状 | 対処 |
| --- | --- |
| `chezmoi` が見つからない | インストール後に新しいシェルを開く |
| `.zshrc` を取り込めない | `chezmoi edit ~/.zshrc` を使う |
| 大量の差分が出る | `chezmoi diff` で方向を確認し、`merge` または `apply` |
| `safe.directory` が見えない | `--global` を外して `git config --get-all safe.directory` |
| ホスト設定が効かない | chezmoiのホスト名と `.chezmoidata.yaml` のキーを比較 |
| PowerShellが読まれない | `Get-Content $PROFILE` と管理本体を確認 |
| `run_once_` を再実行したい | scriptStateを削除してからapply |

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi doctor
```

## 開発時の検証

実ホームに対して `chezmoi apply` を実行してはいけません。一時ディレクトリを使い、
PowerShellスクリプトから実マシンの `$PROFILE` を守るため `--exclude=scripts` を付けます。

```bash
tmp=$(mktemp -d)
mkdir -p "$tmp/dest"
chezmoi --config="$tmp/chezmoi.toml" --source=. --destination="$tmp/dest" init --promptDefaults
chezmoi --config="$tmp/chezmoi.toml" --source=. --destination="$tmp/dest" apply --exclude=scripts
grep -rn "{{\|}}" "$tmp/dest"
```

## 関連ドキュメント

- [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) — 管理対象と除外理由
- [docs/SECRETS.md](docs/SECRETS.md) — 秘密情報の扱い
- [docs/MIGRATION.md](docs/MIGRATION.md) — 旧方式からの移行
- [AGENTS.md](AGENTS.md) — AIエージェント向け作業規則

CIはUbuntuとWindowsの一時ディレクトリへ適用し、構文、OS別出し分け、秘密値混入、
冪等性を検証します。
