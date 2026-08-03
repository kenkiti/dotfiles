# 旧方式（手動シンボリックリンク）からの移行

## 何が変わったか

| | 旧 | 新 |
| --- | --- | --- |
| 配置方法 | 手動で `New-Item -ItemType SymbolicLink` / `ln -s` | `chezmoi apply` |
| リポジトリの置き場所 | `$HOME\Github\dotfiles` に固定（README に直書き） | どこでもよい。chezmoi が `~/.local/share/chezmoi` で管理 |
| PowerShell プロファイル | `powershell/Microsoft.PowerShell_profile.ps1` へのシンボリックリンク | `~/.config/powershell/` に実体、`$PROFILE` にローダ |
| Windows Terminal | `windows-terminal/actions.jsonc` を手で `settings.json` に貼り付け | `settings.json` 全体をテンプレートで管理 |
| OS 別の出し分け | 手作業 | `.chezmoiignore` とテンプレートで自動 |
| 管理者権限 | シンボリックリンク作成で必要になることがあった | 不要 |

## 移行手順（Windows）

移行前に **今の設定をバックアップ**してください。chezmoi 側も自動でバックアップしますが、
自分で取っておくほうが確実です。

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$HOME\dotfiles-backup-$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

Copy-Item $PROFILE "$backup\Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
Copy-Item "$HOME\.gitconfig" $backup -ErrorAction SilentlyContinue
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" $backup -ErrorAction SilentlyContinue
Copy-Item "$HOME\.claude\settings.json" $backup -ErrorAction SilentlyContinue
$backup
```

そのうえで:

```powershell
winget install --id twpayne.chezmoi -e

chezmoi init kenkiti/dotfiles
chezmoi diff                      # 差分をすべて読む
chezmoi apply --dry-run --verbose
chezmoi apply
```

### `$PROFILE` の扱い

`chezmoi apply` の最後に `run_onchange_after_20-install-powershell-profile.ps1` が動き、
`$PROFILE` に 1 行のローダを設置します。

- 既存の `$PROFILE` が**このリポジトリへのシンボリックリンク**だった場合
  → リンク先と内容を `<$PROFILE>.pre-chezmoi.<timestamp>.bak` に記録してからリンクを外し、ローダを書きます。
- 既存の `$PROFILE` が**通常ファイル**だった場合
  → `<$PROFILE>.pre-chezmoi.<timestamp>.bak` にコピーしてからローダを書きます。

適用後、確認します。

```powershell
Get-Item $PROFILE | Format-List FullName, LinkType, Length
Get-Content $PROFILE
pwsh -NoProfile -Command 'exit 0'   # 別プロセスで健全性確認
```

新しいシェルを開いて `cdd` や `gs` が動けば移行完了です。

### 旧ディレクトリの削除（任意・最後にやる）

`powershell/` と `windows-terminal/` は、**移行が完了して新しいシェルが正常に動くことを確認するまで
リポジトリに残してあります**。`$PROFILE` がまだ `powershell/Microsoft.PowerShell_profile.ps1` を指している
状態でこれらを消すと、その場でプロファイルが壊れます。

確認が済んだら削除してください。

```powershell
git rm -r powershell windows-terminal
git commit -m "chore: remove pre-chezmoi layout"
```

## 移行手順（WSL2 Ubuntu）

```bash
stamp=$(date +%Y%m%d-%H%M%S)
backup="$HOME/dotfiles-backup-$stamp"
mkdir -p "$backup"
for f in .zshrc .zprofile .profile .gitconfig; do
  [ -f "$HOME/$f" ] && cp "$HOME/$f" "$backup/"
done
ls -la "$backup"
```

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

chezmoi init kenkiti/dotfiles
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

### 既存の `~/.zshrc` からの差分取り込み

このリポジトリの `dot_zshrc.tmpl` は、Git 履歴に残っていた旧 `zsh/.zshrc`
（コミット `639aeed` で追加、`0bec0c1` で削除）の**移植可能な部分**を土台にしています。

意図的に引き継がなかったもの:

- macOS 専用の設定（MacPorts の `PATH`、`open -a`、MacVim、`LSCOLORS`）
- 当時の `~/.zshrc.mine`（同じく macOS 専用）
- `export CC=/usr/bin/gcc-4.2`

引き継いだもの: 補完・履歴・`setopt` 群・Emacs キーバインド・`^P`/`^N` 履歴検索・
`WORDCHARS`・ターミナルタイトル・`chpwd` での自動 `ll`。

**移行を実施する PC に実際の `~/.zshrc` がある場合は、そちらが正です。**
`chezmoi diff` で差分を確認し、残したい行を反映してください。

```bash
chezmoi diff ~/.zshrc

# 手元の内容をそのまま採用したい場合
chezmoi merge ~/.zshrc

# 完全に手元優先で取り込み直す場合
chezmoi re-add ~/.zshrc
```

秘密情報やこの PC 限定の設定は `~/.zshrc` に直接書かず、`~/.zshrc.local` に置いてください
（[SECRETS.md](SECRETS.md) 参照）。

## 移行後にやること

- `~/.gitconfig` の `safe.directory` を `~/.gitconfig.local` へ移す。
- Codex CLI の設定は `~/.codex/config.toml` を手で編集する
  （管理対象外の理由は [MANAGED_FILES.md](MANAGED_FILES.md) 参照）。
  雛形: [`reference/codex-config.reference.toml`](reference/codex-config.reference.toml)
- Windows Terminal を再起動し、動的プロファイル（WSL、Visual Studio など）が
  自動で再生成されることを確認する。

## 元に戻したい場合

```powershell
# 1. chezmoi の管理から外す
chezmoi forget ~/.gitconfig     # 必要なファイルごとに

# 2. バックアップから戻す
Copy-Item "$backup\Microsoft.PowerShell_profile.ps1" $PROFILE -Force
Copy-Item "$backup\.gitconfig" "$HOME\.gitconfig" -Force
```

`$PROFILE` だけを旧方式に戻す場合は、`<$PROFILE>.pre-chezmoi.*.bak` の内容を確認して
書き戻すか、旧 README の手順でシンボリックリンクを作り直してください。
