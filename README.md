# dotfiles

Windows 11 と WSL2 Ubuntu の設定ファイルを、1 つのリポジトリで管理します。
管理には [chezmoi](https://www.chezmoi.io/) を使います。

OS・WSL・ホスト名を自動で判定し、その環境に必要な設定だけを展開します。

---

## 目次

1. [まず知っておくこと](#1-まず知っておくこと)
2. [インストール](#2-インストール)
3. [初期化（初回セットアップ）](#3-初期化初回セットアップ)
4. [設定を変更して反映する](#4-設定を変更して反映する) ← **日常はここだけ**
5. [他の PC へ配布する / 受け取る](#5-他の-pc-へ配布する--受け取る)
6. [管理しているファイル](#6-管理しているファイル)
7. [OS 別・ホスト別の設定](#7-os-別ホスト別の設定)
8. [秘密情報の置き場所](#8-秘密情報の置き場所)
9. [困ったとき](#9-困ったとき)
10. [コマンド早見表](#10-コマンド早見表)

---

## 1. まず知っておくこと

### 3 つの用語

chezmoi を使ううえで、この 3 つだけ分かれば十分です。

| 用語 | 意味 | 実際の場所 |
| --- | --- | --- |
| **ソースディレクトリ** | 設定の原本を置く場所。git リポジトリ | `~/.local/share/chezmoi` |
| **展開先** | 実際に使われる設定ファイルの場所 | ホームディレクトリ (`~`) |
| **テンプレート** | PC ごとに中身が変わるファイル。拡張子 `.tmpl` | ソース側にだけ存在 |

chezmoi は「ソースディレクトリ → 展開先」へファイルを書き出す道具です。
この向きが基本で、逆向き（展開先 → ソース）は明示的に指示したときだけ起きます。

### ファイル名の規則

ソース側のファイル名は、展開先の名前を変形したものです。

| ソース側の名前 | 展開先 |
| --- | --- |
| `dot_zshrc` | `~/.zshrc` |
| `dot_gitconfig.tmpl` | `~/.gitconfig`（テンプレートとして評価される） |
| `private_dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md`（パーミッション 0600 相当） |
| `executable_foo.sh` | `~/foo.sh`（実行ビットあり） |

対応関係は `chezmoi source-path <展開先のパス>` でいつでも確認できます。

```powershell
chezmoi source-path ~/.zshrc
# -> .../dot_zshrc.tmpl
```

### 何が起きないか

- 管理していないファイルには一切触りません。
- `chezmoi apply` は、あなたが手で書き換えたファイルを黙って上書きしません（後述の確認プロンプトが出ます）。
- シンボリックリンクは作りません。管理者権限も不要です。

---

## 2. インストール

### Windows

```powershell
winget install --id twpayne.chezmoi -e
```

> **⚠ よくあるつまずき**
> インストール直後の PowerShell では `chezmoi` が見つかりません。
> winget が PATH に追加した内容は、**新しく開いたシェル**から反映されます。
>
> **新しい PowerShell を開いてください。** それが一番簡単です。
>
> 今のシェルのまま続けたい場合は、PATH を読み直します。
>
> ```powershell
> $env:PATH = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
>             [Environment]::GetEnvironmentVariable('Path','User')
> ```

確認します。

```powershell
chezmoi --version
```

### WSL2 Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y git zsh curl

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

chezmoi --version
```

`~/.local/bin` が PATH に無い場合は、`~/.profile` などに上の `export` を追記してください。

---

## 3. 初期化（初回セットアップ）

### 3-1. 先にバックアップを取る

`chezmoi apply` は既存の設定ファイルを置き換えます。**必ず先にバックアップしてください。**

**Windows:**

```powershell
$stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$HOME\dotfiles-backup-$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

Copy-Item $PROFILE          $backup -ErrorAction SilentlyContinue
Copy-Item "$HOME\.gitconfig" $backup -ErrorAction SilentlyContinue
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" $backup -ErrorAction SilentlyContinue

$backup
```

**WSL2 Ubuntu:**

```bash
stamp=$(date +%Y%m%d-%H%M%S)
backup="$HOME/dotfiles-backup-$stamp"
mkdir -p "$backup"
for f in .zshrc .zprofile .profile .gitconfig; do
  [ -f "$HOME/$f" ] && cp "$HOME/$f" "$backup/"
done
ls -la "$backup"
```

### 3-2. リポジトリを取得する

```
chezmoi init kenkiti/dotfiles
```

これで `~/.local/share/chezmoi` にリポジトリが clone され、
`~/.config/chezmoi/chezmoi.toml` が生成されます。
**この時点ではホームディレクトリの設定ファイルは一切変更されません。**

途中で 2 つ質問されます。

```
Git user.name [Tadashi Inoue]?
Git user.email [kenkiti@gmail.com]?
```

そのままでよければ Enter を押します。入力した値は設定ファイルに保存され、次回以降は聞かれません。

> **すでにリポジトリを別の場所に clone している場合**
>
> `chezmoi init --source=<パス>` の `--source` は**その 1 回しか効きません**。
> 後続の `chezmoi diff` などは既定の場所を探しに行って失敗します。
>
> 既存の clone を使い続けたいときは、既定の場所からジャンクションを張ります（管理者権限は不要）。
>
> ```powershell
> New-Item -ItemType Directory -Path "$HOME\.local\share" -Force | Out-Null
> New-Item -ItemType Junction -Path "$HOME\.local\share\chezmoi" -Target "D:\Github\dotfiles"
>
> chezmoi source-path      # D:\Github\dotfiles と出れば成功
> ```
>
> Linux / WSL ならシンボリックリンクです。
>
> ```bash
> mkdir -p ~/.local/share
> ln -s /path/to/dotfiles ~/.local/share/chezmoi
> ```

### 3-3. 差分を確認する

**いきなり適用しないでください。** 何が変わるか必ず読みます。

```
chezmoi status     # 変更されるファイルの一覧（短い）
chezmoi diff       # 変更内容そのもの（長い）
```

`chezmoi status` の記号の意味は次のとおりです。

| 記号 | 意味 |
| --- | --- |
| `A` | 新しく作られる |
| `M` | 内容が変更される |
| `D` | 削除される |
| `R` | スクリプトが実行される |

### 3-4. マシン固有の git 設定を退避する

**すでに git を使っている PC だけの手順です。** まっさらな PC では既存設定が無いので飛ばしてください。

`chezmoi apply` は `~/.gitconfig` を丸ごと置き換えます。このリポジトリの `~/.gitconfig` は
`safe.directory` を持たない（PC ごとに違う値のため）ので、既存のものは
`~/.gitconfig.local` へ移しておきます。

`user.name` と `user.email` は移す必要はありません。`chezmoi init` で入力した値が
`~/.gitconfig` 本体に入ります。

まず、退避すべき設定があるか確認します。

```powershell
git config --global --get-all safe.directory
```

何も出なければこの節は不要です。出た場合は次を実行します。

```powershell
$dirs = git config --global --get-all safe.directory | Sort-Object -Unique

if (Test-Path "$HOME\.gitconfig.local") {
    # 既存ファイルを壊さない。中身を見て手で統合する。
    Write-Warning "~/.gitconfig.local は既に存在します。追記せず中身を確認してください。"
    Get-Content "$HOME\.gitconfig.local"
}
elseif ($dirs) {
    $lines = @('# chezmoi 管理外・Git 管理外。このマシン専用の設定。', '[safe]') +
             ($dirs | ForEach-Object { "`tdirectory = $_" })
    # BOM を付けない。Windows PowerShell 5.1 の -Encoding UTF8 は BOM を付けるため使わない。
    [IO.File]::WriteAllLines("$HOME\.gitconfig.local", $lines)
    Get-Content "$HOME\.gitconfig.local"
}
```

**WSL2 Ubuntu:**

```bash
git config --global --get-all safe.directory        # 空なら不要

if [ ! -f "$HOME/.gitconfig.local" ]; then
  { echo '# chezmoi 管理外・Git 管理外。このマシン専用の設定。'
    echo '[safe]'
    git config --global --get-all safe.directory | sort -u | sed 's/^/\tdirectory = /'
  } > "$HOME/.gitconfig.local"
  cat "$HOME/.gitconfig.local"
fi
```

`~/.gitconfig` の末尾には `[include] path = ~/.gitconfig.local` が入るので、
`chezmoi apply` 後も退避した設定はそのまま有効になります。

> **⚠ 確認方法に注意**
>
> 適用後に `git config --global --get-all safe.directory` で確認すると **空に見えます**。
> `--global` はスコープを `~/.gitconfig` 1 枚に限定するため、`include.path` を展開しません。
>
> スコープを付けずに確認してください。
>
> ```powershell
> git config --get-all safe.directory              # 値が出る
> git config --list --show-origin | Select-String 'safe.directory'
> ```
>
> 由来が `.gitconfig.local` と表示されれば正しく読まれています。

### 3-5. 適用する

```
chezmoi apply --dry-run --verbose    # 予行演習（何も書き換えない）
chezmoi apply                        # 本番
```

### 3-6. 適用後の確認

**Windows:**

```powershell
Get-Content $PROFILE                                          # ローダが 1 個だけある
Get-ChildItem (Split-Path $PROFILE) -Filter '*.pre-chezmoi*'  # 旧プロファイルのバックアップ
git config --get-all safe.directory                           # 退避した設定が有効（--global は付けない）
```

そのあと**新しい PowerShell を開いて**、`cdd` と `gs` が動けば完了です。
Windows Terminal は再起動すると、消えたように見えるプロファイル（WSL、Visual Studio など）が自動で戻ります。

**WSL2 Ubuntu:**

```bash
zsh -n ~/.zshrc     # 文法チェック
exec zsh            # 新しい zsh を起動
```

### 3-7. 慣れたら短縮形

構成を理解したあと、2 台目以降ではこれで済みます。

```
chezmoi init --apply kenkiti/dotfiles
```

**1 台目ではおすすめしません。** 差分を見ずに既存設定が置き換わります。

---

## 4. 設定を変更して反映する

**ここが日常の作業です。**

重要なポイントが 1 つあります。**テンプレートかどうかで手順が変わります。**

### 4-1. どちらか調べる

```
chezmoi source-path ~/.zshrc
```

出力が `.tmpl` で終わればテンプレート、終わらなければ普通のファイルです。

現在の内訳は次のとおりです。

| 展開先 | 種別 |
| --- | --- |
| `~/.zshrc` | **テンプレート** |
| `~/.zprofile` | **テンプレート** |
| `~/.gitconfig` | **テンプレート** |
| `~/.config/powershell/Microsoft.PowerShell_profile.ps1` | **テンプレート** |
| Windows Terminal `settings.json` | **テンプレート** |
| `~/.claude/CLAUDE.md` | 普通のファイル |
| `~/.claude/settings.json` | 普通のファイル |
| `~/.codex/AGENTS.md` | 普通のファイル |
| `~/.codex/config.toml` | **テンプレート** |

### 4-2. テンプレートの場合（`.zshrc` など）

**`~/.zshrc` を直接編集しても反映されません。**

`chezmoi re-add` はテンプレートを**スキップ**します。これはテンプレートが壊れるのを防ぐための仕様です。
安全ではありますが、直接書いた変更は取り込まれず、そのまま消えます。

正しい手順は `chezmoi edit` です。これは**ソース側のテンプレートを開きます**。

```
chezmoi edit ~/.zshrc      # dot_zshrc.tmpl が開く
chezmoi diff               # 結果を確認
chezmoi apply              # 反映
```

編集と同時に適用してよければ 1 コマンドで済みます。

```
chezmoi edit --apply ~/.zshrc
```

エディタは環境変数 `$EDITOR` で決まります。設定しておくと快適です。

```powershell
# PowerShell（~/.config/powershell/profile.local.ps1 に書くとよい）
$env:EDITOR = 'code --wait'
```

```bash
# zsh
export EDITOR='vim'
```

### 4-3. 普通のファイルの場合（`.claude/CLAUDE.md` など）

こちらは直接編集して構いません。あとからソースへ取り込みます。

```powershell
notepad "$HOME\.claude\CLAUDE.md"    # 普通に編集
chezmoi re-add                        # 変更をソースへ取り込む
chezmoi status                        # 差分が消えていることを確認
```

`chezmoi edit ~/.claude/CLAUDE.md` を使っても同じ結果になります。
迷ったら `chezmoi edit` を使えば、どちらの種別でも正しく動きます。

### 4-4. 間違えて直接編集してしまったら

安全装置があります。`chezmoi apply` は黙って上書きしません。

```
.gitconfig has changed since chezmoi last wrote it (diff/overwrite/all-overwrite/skip/quit)?
```

| 入力 | 動作 |
| --- | --- |
| `diff` | 何が違うか表示する（選び直せる） |
| `skip` | このファイルは今回触らない |
| `overwrite` | 手元の変更を捨ててソース側で上書き |
| `all-overwrite` | 以降すべて上書き |
| `quit` | 中止 |

手元の変更を活かしたい場合は、3-way マージができます。

```
chezmoi merge ~/.zshrc
```

既定のマージツールは `vimdiff` です。VS Code を使う場合は
`~/.config/chezmoi/chezmoi.toml` に追記します。

```toml
[merge]
    command = "code"
    args = ["--wait", "--merge", "{{ .Destination }}", "{{ .Source }}", "{{ .Target }}"]
```

### 4-5. 新しいファイルを管理下に入れる

```
chezmoi add ~/.foo                # そのまま管理する
chezmoi add --template ~/.foo     # テンプレートとして管理する
```

### 4-6. 管理をやめる

```
chezmoi forget ~/.foo    # ソースから外す。~/.foo 自体は残る
```

### 4-7. リポジトリへコミットする

ソースディレクトリは普通の git リポジトリです。

```
chezmoi cd        # ソースディレクトリでサブシェルを開く

git status
git add -A
git commit -m "変更内容"
git push

exit              # 元のディレクトリへ戻る
```

`chezmoi cd` を使わず、直接 `cd D:\Github\dotfiles` しても同じです。

---

## 5. 他の PC へ配布する / 受け取る

### 送る側

上記 4-7 で `git push` するだけです。

### 受け取る側

```
chezmoi update
```

これは `git pull` と `chezmoi apply` をまとめて実行します。

差分を先に見たい場合は分けます。**慣れるまではこちらを推奨します。**

```
chezmoi git pull       # 取得のみ
chezmoi diff           # 確認
chezmoi apply          # 反映
```

---

## 6. 管理しているファイル

`chezmoi managed` を実行すると、その環境で実際に展開されるファイルが一覧できます。

### 全 OS 共通

| 展開先 | 内容 |
| --- | --- |
| `~/.gitconfig` | git の共通設定。`~/.gitconfig.local` を include |
| `~/.claude/CLAUDE.md` | Claude Code のグローバル指示 |
| `~/.claude/settings.json` | Claude Code の共通設定（`hooks` は除く。下記の注意を参照） |
| `~/.codex/AGENTS.md` | Codex CLI のグローバル指示 |
| `~/.codex/config.toml` | Codex CLI の共通設定（実行状態セクションは除く。下記の注意を参照） |

### Windows のみ

| 展開先 | 内容 |
| --- | --- |
| `~/.config/powershell/Microsoft.PowerShell_profile.ps1` | PowerShell プロファイル本体 |
| `AppData/.../Windows Terminal settings.json` | Windows Terminal 設定 |

### Linux / WSL のみ

| 展開先 | 内容 |
| --- | --- |
| `~/.zshrc` | zsh の対話設定 |
| `~/.zprofile` | zsh のログイン環境 |

### 管理していない主なもの

| ファイル | 理由 |
| --- | --- |
| `~/.claude/settings.json` の `hooks` | この PC 専用。ユーザー名入りの絶対パスを含むため |
| `~/.codex/config.toml` の `[projects.*]` `[mcp_servers.*]` `notify` など | この PC 専用。ローカルの絶対パスを含むため |
| 認証情報・履歴・キャッシュ・ログ・セッション | 秘密情報またはマシン固有 |

`~/.claude/settings.json` と `~/.codex/config.toml` は、**ファイルとしては管理対象**です。
除外しているのはそのファイルの中の一部のセクションだけです。

判断の根拠と完全な除外リストは [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) にあります。

> **⚠ どちらも include の仕組みを持ちません**
>
> そのため `chezmoi apply` を実行すると、**その PC でローカルに追加された内容は削除されます。**
>
> - `~/.claude/settings.json` → ローカルで設定した `hooks` が消える
> - `~/.codex/config.toml` → 信頼済みプロジェクト `[projects.*]` やプラグイン状態が消える
>   （信頼はそのディレクトリで作業したときに再承認が必要）
>
> apply の前に退避しておくと復元できます。
>
> ```powershell
> Copy-Item "$HOME\.claude\settings.json" "$HOME\.claude\settings.json.bak"
> Copy-Item "$HOME\.codex\config.toml"    "$HOME\.codex\config.toml.bak"
> ```

### PowerShell プロファイルの特殊事情

`$PROFILE` は固定パスではありません。OneDrive リダイレクトや日本語ロケールで
`OneDrive\ドキュメント\PowerShell\...` のように PC ごとに変わります。

そこで本体は `~/.config/powershell/` に置き、`$PROFILE` には
それを読み込むだけの 1 行のローダを設置します。ローダの設置は
`chezmoi apply` 時にスクリプトが自動で行い、既存の `$PROFILE` は
`<$PROFILE>.pre-chezmoi.<日時>.bak` へ退避します。

したがって編集するのは常にこちらです。

```powershell
chezmoi edit ~/.config/powershell/Microsoft.PowerShell_profile.ps1
```

---

## 7. OS 別・ホスト別の設定

判定は初期化時に一度だけ行い、結果を `~/.config/chezmoi/chezmoi.toml` に保存します。
テンプレート側は真偽値を見るだけです。

| 変数 | 内容 |
| --- | --- |
| `.isWindows` | Windows か |
| `.isLinux` | Linux か |
| `.isWSL` | WSL か（`/proc/sys/kernel/osrelease` または `WSL_DISTRO_NAME` で判定） |
| `.isLinuxNative` | WSL でない Linux か |
| `.isCI` | CI 実行中か |

確認方法:

```
chezmoi execute-template "{{ .isWSL }}"
chezmoi execute-template "{{ .chezmoi.hostname }}"
```

PC ごとに違う値は、設定ファイルに直接書かず [`.chezmoidata.yaml`](.chezmoidata.yaml) にまとめます。

```yaml
defaults:
  powershell:
    workDir: "~/Github"

hosts:
  DESKTOP-Corei5-8400:      # chezmoi execute-template "{{ .chezmoi.hostname }}" の値
    powershell:
      workDir: "D:\\Github"
```

新しい PC を追加するときは `hosts:` にブロックを足し、`defaults` と違う値だけ書きます。

どの OS にどのファイルを配るかは [`.chezmoiignore`](.chezmoiignore) が決めています。

---

## 8. 秘密情報の置き場所

**このリポジトリには秘密値を入れません。** 公開リポジトリです。

API キーやトークン、その PC 限定の設定は、次のファイルに書きます。
いずれも **chezmoi 管理外・git 管理外**で、存在しなくても動作します。

| ファイル | 読み込み元 |
| --- | --- |
| `~/.gitconfig.local` | `~/.gitconfig` |
| `~/.zshrc.local` | `~/.zshrc` |
| `~/.zprofile.local` | `~/.zprofile` |
| `~/.config/powershell/profile.local.ps1` | PowerShell プロファイル |

例:

```bash
# ~/.zprofile.local
export SOME_SERVICE_TOKEN="..."
```

```powershell
# ~/.config/powershell/profile.local.ps1
$env:SOME_SERVICE_TOKEN = '...'
```

Claude Code と Codex CLI の認証情報は管理していません。PC ごとに各ツールでログインしてください。

Bitwarden / LastPass 連携は必須にしていません。未導入でもすべて動作します。
詳細は [docs/SECRETS.md](docs/SECRETS.md) を参照してください。

---

## 9. 困ったとき

| 症状 | 対処 |
| --- | --- |
| `chezmoi` コマンドが見つからない | 新しいシェルを開く（インストール直後は PATH が未反映） |
| `GetFileAttributesEx ...\.local\share\chezmoi` エラー | ソースディレクトリが無い。`chezmoi init` を実行するか、[3-2](#3-2-リポジトリを取得する) のジャンクションを張る |
| `~/.zshrc` を編集したのに `chezmoi status` に出ない／反映されない | テンプレートを直接編集した。`chezmoi edit ~/.zshrc` を使う（[4-2](#4-2-テンプレートの場合zshrc-など)） |
| `has changed since chezmoi last wrote it` と聞かれる | 手元で直接編集した。`diff` で確認してから `skip` か `overwrite` を選ぶ |
| `chezmoi diff` に大量の差分が出る | 手元が正なら `chezmoi re-add`、リポジトリが正なら `chezmoi apply` |
| `safe.directory` が消えたように見える | `--global` は `include.path` を展開しない。`git config --get-all safe.directory`（スコープ無し）で確認する |
| テンプレートエラーで落ちる | `chezmoi execute-template < <ソースファイル>` で該当箇所を特定する |
| ホスト固有設定が効かない | `chezmoi execute-template "{{ .chezmoi.hostname }}"` と `.chezmoidata.yaml` の `hosts:` キーが一致しているか確認 |
| PowerShell プロファイルが読み込まれない | `Get-Content $PROFILE` にローダがあるか、`Test-Path ~/.config/powershell/Microsoft.PowerShell_profile.ps1` を確認 |
| Windows Terminal のプロファイルが消えた | 動的プロファイルは再起動で自動再生成される |
| `run_once_` スクリプトを再実行したい | `chezmoi state delete-bucket --bucket=scriptState` してから `chezmoi apply` |
| `$PROFILE` を書き換えたくない | `chezmoi apply --exclude=scripts` |
| 元に戻したい | `chezmoi forget <パス>` で管理から外し、バックアップから復元する |

### 元に戻す

```powershell
# 管理から外す（ファイルは残る）
chezmoi forget ~/.gitconfig

# バックアップから復元
Copy-Item "$HOME\dotfiles-backup-<日時>\.gitconfig" "$HOME\.gitconfig" -Force
```

`$PROFILE` は `<$PROFILE>.pre-chezmoi.<日時>.bak` に自動退避されています。

---

## 10. コマンド早見表

### 日常

```
chezmoi edit <パス>        設定を編集する（テンプレートでも安全）
chezmoi diff               適用前に差分を見る
chezmoi apply              適用する
chezmoi update             git pull + apply（他 PC の変更を取り込む）
```

### 確認

```
chezmoi status             変更されるファイルの一覧
chezmoi managed            管理しているファイルの一覧
chezmoi source-path <パス> 展開先 → ソースの対応
chezmoi doctor             環境の健全性チェック
chezmoi execute-template "{{ .chezmoi.hostname }}"
```

### 管理対象の変更

```
chezmoi add <パス>              管理下に入れる
chezmoi add --template <パス>   テンプレートとして管理下に入れる
chezmoi re-add                  手元の変更をソースへ取り込む（テンプレートは対象外）
chezmoi forget <パス>           管理から外す（ファイルは残る）
```

### リポジトリ操作

```
chezmoi cd                 ソースディレクトリでサブシェルを開く
chezmoi git pull           取得のみ
chezmoi merge <パス>       手元とソースを 3-way マージ
```

---

## 関連ドキュメント

- [docs/MANAGED_FILES.md](docs/MANAGED_FILES.md) — 管理対象・管理対象外の完全な一覧と理由（`settings.json` / `config.toml` で何を除いているかを含む）
- [docs/SECRETS.md](docs/SECRETS.md) — 秘密情報の扱いと将来の Bitwarden / LastPass 連携
- [docs/MIGRATION.md](docs/MIGRATION.md) — 旧シンボリックリンク方式からの移行手順
- [AGENTS.md](AGENTS.md) — このリポジトリを AI エージェントが編集するときの規則

## CI

[`.github/workflows/chezmoi-test.yml`](.github/workflows/chezmoi-test.yml) が
`ubuntu-latest` と `windows-latest` で、一時ディレクトリへの適用・構文検査・
OS 別の出し分け・秘密値の混入チェック・冪等性を検証します。
実ホームディレクトリは使いません。
