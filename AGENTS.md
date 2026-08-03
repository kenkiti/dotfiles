# AGENTS.md

このリポジトリは [chezmoi](https://www.chezmoi.io/) のソースディレクトリです。
リポジトリのルートがそのまま chezmoi のソースディレクトリになります。

## 絶対に守ること

- **実ホームディレクトリに対して `chezmoi apply` を実行しない。**
  検証は必ず一時ディレクトリを出力先にする。

  ```
  chezmoi --config=<tmp>/chezmoi.toml --source=. --destination=<tmp>/dest init --promptDefaults
  chezmoi --config=<tmp>/chezmoi.toml --source=. --destination=<tmp>/dest apply --exclude=scripts
  ```

  `--exclude=scripts` を付けること。`run_onchange_after_20-install-powershell-profile.ps1`
  は `$PROFILE` を解決して書き換えるため、一時ディレクトリを出力先にしても
  実マシンの `$PROFILE` に触れる。

- **秘密情報をコミットしない。** 認証情報、API キー、トークン、Cookie、セッション。
  `~/.claude/.credentials.json` と `~/.codex/auth.json` は絶対に `chezmoi add` しない。
- **`.claude` / `.codex` ディレクトリを丸ごとコピーしない。** 静的設定だけを選ぶ。
  判断基準は `docs/MANAGED_FILES.md`。
- **`git push` しない。** **main / master へ直接コミットしない。**
- 既存のユーザー設定ファイルを削除・上書きしない。

## ファイル配置の規則

| プレフィックス | 意味 |
| --- | --- |
| `dot_` | 展開先で `.` になる（`dot_zshrc` → `~/.zshrc`） |
| `private_` | パーミッション 0600 相当（Windows では無視される） |
| `executable_` | 実行ビットを立てる（Windows では無視される） |
| `.tmpl` | Go テンプレートとして評価する |
| `.chezmoiscripts/` | 展開されず、スクリプトとして実行される |

先頭が `.` のソースエントリ（`.github`、`.gitattributes`）は chezmoi が自動で無視します。
`README.md` などの通常ファイルは自動では無視されないため、`.chezmoiignore` に明示しています。

## 環境判定

テンプレートでは `.chezmoi.os` を直接見ず、`.chezmoi.toml.tmpl` が用意する真偽値を使ってください。

`.isWindows` / `.isLinux` / `.isWSL` / `.isLinuxNative` / `.isCI`

ホスト固有の値は設定ファイルに直書きせず、`.chezmoidata.yaml` の `hosts:` に追加します。
テンプレート側は次の 2 行で `defaults` と重ねます。

```
{{- $host := default (dict) (get .hosts .chezmoi.hostname) -}}
{{- $cfg := mergeOverwrite (deepCopy .defaults) $host -}}
```

## スクリプトの規則

- OS が違うときは、テンプレート全体を条件で囲んで**空文字列を出力**する。
  chezmoi は空のスクリプトをスキップするので、Windows で `.sh` の
  インタプリタを探しに行くことがない。
- CI (`.isCI`) では実インストールを行わない。
- パッケージの自動インストールは `DOTFILES_INSTALL_PACKAGES=1` のときだけ。
- エラーを握りつぶさない（`set -eu` / `$ErrorActionPreference = 'Stop'`）。

## 変更後に実行すること

```
# 構文
python3 -c "import yaml;yaml.safe_load(open('.chezmoidata.yaml'))"

# 一時ディレクトリでの適用
chezmoi --config=<tmp>/chezmoi.toml --source=. --destination=<tmp>/dest init --promptDefaults
chezmoi --config=<tmp>/chezmoi.toml --source=. --destination=<tmp>/dest apply --exclude=scripts

# 未評価のテンプレート記法が残っていないこと
grep -rn '{{\|}}' <tmp>/dest
```

CI (`.github/workflows/chezmoi-test.yml`) が ubuntu-latest と windows-latest で
同等の検証を行います。
