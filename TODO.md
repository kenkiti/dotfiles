# TODO

## WSL2 / Oh My Zsh の dotfiles 管理

- [ ] WSL2 の Ubuntu で現在の `~/.zshrc` と `~/.zprofile` を確認する
- [ ] 自作テーマのファイル名と内容を確認する
- [ ] 自作プラグインがあれば、ファイル名と内容を確認する
- [ ] `zsh/` ディレクトリを作成する
- [ ] `.zshrc` を `zsh/.zshrc` として管理する
- [ ] `.zprofile` を `zsh/.zprofile` として管理する
- [ ] 自作テーマを `zsh/oh-my-zsh/custom/themes/` に配置する
- [ ] 自作プラグインを `zsh/oh-my-zsh/custom/plugins/` に配置する
- [ ] Oh My Zsh 本体（`plugins/`、`themes/`、`lib/`、`cache/`、`log/` など）は管理対象にしない
- [ ] `.zsh_history`、キャッシュ、ログ、秘密情報が含まれていないことを確認する
- [ ] WSL2 側の `~/.oh-my-zsh/custom` からリポジトリ側へシンボリックリンクを作成する
- [ ] `.zshrc` の `ZSH_CUSTOM` をリポジトリ側の custom ディレクトリに設定する
- [ ] 新しい WSL2 セッションで zsh が正常に起動することを確認する
- [ ] テーマ、プラグイン、補完、Git 表示が正常に動作することを確認する
- [ ] `git status` で不要な生成物や個人情報が含まれていないことを確認する
