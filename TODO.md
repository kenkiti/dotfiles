# TODO

## chezmoi 移行の残作業

chezmoi 化そのものは完了しています（[docs/MIGRATION.md](docs/MIGRATION.md)）。
残っているのは、実機で確認しないと確定できない項目です。

### Windows（移行を実施する PC で）

- [ ] `chezmoi diff` の差分をすべて読む
- [ ] Windows Terminal `settings.json` の差分を確認する（`profiles.list` から
      Visual Studio / Azure / コマンドプロンプトの静的エントリが消える。再起動で自動再生成される想定）
- [ ] `chezmoi apply` 後、新しい PowerShell で `cdd` / `gs` / `reload` が動くことを確認する
- [ ] `$PROFILE` のバックアップ `<$PROFILE>.pre-chezmoi.*.bak` の内容を確認する
- [ ] `~/.gitconfig` の `safe.directory` を `~/.gitconfig.local` へ移す
- [ ] 動作確認後、旧レイアウト `powershell/` と `windows-terminal/` を削除する

### WSL2 Ubuntu（未検証）

このリポジトリの `dot_zshrc.tmpl` / `dot_zprofile.tmpl` は、Git 履歴に残っていた
旧 `zsh/.zshrc`（macOS 時代）の移植可能な部分を土台にした**新しい baseline** です。
移行作業を行った PC では WSL2 の仮想化が無効で Ubuntu を起動できなかったため、
実機の `~/.zshrc` とは突き合わせていません。

- [ ] WSL2 Ubuntu を用意し、既存の `~/.zshrc` / `~/.zprofile` と `chezmoi diff` で突き合わせる
- [ ] 残したい既存設定を `chezmoi re-add` または `chezmoi merge` で取り込む
- [ ] 自作テーマ・自作プラグインの有無を確認する
- [ ] 自作テーマ／プラグインがある場合、`~/.oh-my-zsh-custom` 配下に置き
      `.chezmoidata.yaml` の `zsh.ohMyZshTheme` / `ohMyZshPlugins` を更新する
      （`.zshrc` は `~/.oh-my-zsh-custom` が存在すれば `ZSH_CUSTOM` に設定する）
- [ ] Oh My Zsh 本体（`plugins/`、`themes/`、`lib/`、`cache/`、`log/`）を管理対象にしないことを確認する
- [ ] `.zsh_history`、キャッシュ、ログ、秘密情報が含まれていないことを確認する
- [ ] 新しい WSL2 セッションで zsh が正常に起動し、補完・履歴・Git 表示が動くことを確認する

### 任意

- [ ] Bitwarden または LastPass 連携（[docs/SECRETS.md](docs/SECRETS.md) 参照）
- [ ] `~/.irbrc` を管理対象に戻すか判断する（旧リポジトリにあったが `wirble` 依存で古い）
