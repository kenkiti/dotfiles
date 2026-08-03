# 秘密情報の取り扱い

## 原則

1. **このリポジトリに秘密値を入れない。** 公開リポジトリであり、Git 履歴からは消せないものとして扱う。
2. **秘密値を含む既存ファイルをそのままコピーしない。** `~/.claude/.credentials.json` や
   `~/.codex/auth.json` は `chezmoi add` してはいけない。`.chezmoiignore` で二重に防いでいる。
3. **秘密情報はローカル専用ファイルか環境変数から読む。** 下記の `*.local` ファイルは
   chezmoi の管理対象外・Git 管理対象外。
4. **CI ではダミー値のみを使う。** GitHub Actions から Bitwarden / LastPass へログインしない。

## ローカル専用ファイル

chezmoi はこれらを作成も削除もしません。必要な PC で手で作ります。

| ファイル | 読み込み元 | 例 |
| --- | --- | --- |
| `~/.gitconfig.local` | `~/.gitconfig` の `[include]` | `safe.directory`、`user.signingkey`、credential helper |
| `~/.zshrc.local` | `~/.zshrc` 末尾 | 秘密を含むエイリアス、業務用設定 |
| `~/.zprofile.local` | `~/.zprofile` 末尾 | `export SOME_API_KEY=...` |
| `~/.config/powershell/profile.local.ps1` | PowerShell プロファイル末尾 | `$env:SOME_API_KEY = '...'` |

いずれも「存在すれば読む」形式なので、新しい PC でファイルが無くてもエラーになりません。

### 例: `~/.zprofile.local`

```sh
# このファイルは Git 管理外・chezmoi 管理外
export SOME_SERVICE_TOKEN="..."
```

### 例: `~/.gitconfig.local`

```ini
[safe]
	directory = D:/ubuntu_home/tadashi
	directory = D:/ObsidianVaults/AI_Knowledge
```

（移行前の `~/.gitconfig` に入っていた `safe.directory` はここへ移してください。
値そのものはマシン固有のパスであり、秘密ではありませんが再現性がないため分離しています。）

## 認証情報を持つツール

| ツール | 認証情報の場所 | 方針 |
| --- | --- | --- |
| Claude Code | `~/.claude/.credentials.json` | 管理しない。各 PC で `claude` にログインする |
| Codex CLI | `~/.codex/auth.json` | 管理しない。各 PC で `codex` にログインする |
| Git (GitHub) | OS の資格情報ストア | 管理しない。Git Credential Manager 等に任せる |

## 将来の Bitwarden / LastPass 連携

今回の移行では **実接続を必須にしていません**。`chezmoi init --apply` は
シークレットマネージャが無くても完走します。

将来つなぐときの想定は次のとおりです。テンプレートは chezmoi 組み込みの関数を使います。

```
# Bitwarden
{{ (bitwardenFields "item" "my-item").token.value }}

# LastPass
{{ (lastpass "my-item").note.token }}
```

導入時に守ること。

- CI では絶対に呼ばない。`.isCI` で分岐し、CI 側はダミー値にする。
  そうしないと `chezmoi apply` が CI でシークレットマネージャのログインを待って停止する。
- `bw` / `lpass` が未インストールの PC でも `chezmoi apply` が失敗しないよう、
  `lookPath` で存在確認してから呼ぶ。
- 秘密値を含むファイルは必ずテンプレート（`.tmpl`）として生成し、
  生成結果をリポジトリへ `chezmoi re-add` しない。

依存ツール確認スクリプト（`.chezmoiscripts/run_once_before_10-check-dependencies.*`）は
`bw` / `lpass` が存在すれば報告するだけで、インストールもログインもしません。

## リポジトリの秘密情報チェック

移行時に全 Git 履歴（4 コミット、全 blob）を秘密値パターンで検査しました。
検出されたのは Emacs 設定内の `eshell-watch-for-password-prompt` /
`mew-use-cached-passwd` といった変数名のみで、秘密値はありません。

再検査するには次を実行します（値は表示せず、位置だけ出します）。

```powershell
$revs = git rev-list --all
git grep -I -n -i -E "(BEGIN [A-Z ]*PRIVATE KEY|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_|AKIA[0-9A-Z]{16}|xox[baprs]-|api_key|apikey|password|passwd|secret|token)" $revs |
  ForEach-Object { ($_ -split ':')[0..2] -join ':' } | Sort-Object -Unique
```

CI (`.github/workflows/chezmoi-test.yml`) でも毎回、
展開結果に認証ファイルや秘密値パターンが含まれていないことを検査しています。
