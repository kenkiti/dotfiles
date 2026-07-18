# dotfiles

シェルと開発環境の設定ファイルを管理します。

## Windows PowerShell

PowerShell プロファイルは `powershell/Microsoft.PowerShell_profile.ps1` にあります。

シンボリックリンクを作成するには、PowerShell を管理者として起動してください。
Windows の開発者モードを有効にしている場合は、通常の権限でも作成できることがあります。

```powershell
$repoRoot = "$HOME\Github\dotfiles"
$profileDir = Split-Path $PROFILE
$profileTarget = Join-Path $repoRoot "powershell\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
New-Item -ItemType SymbolicLink -Path $PROFILE -Target $profileTarget -Force
```

作成後、リンク先を確認できます。

```powershell
Get-Item $PROFILE | Format-List FullName, LinkType, Target
```

## セットアップ

1. このリポジトリを任意の場所へ clone します。
2. PowerShell でリポジトリのルートから、上記のリンク作成コマンドを実行します。
3. PowerShell を再起動するか、`reload` を実行してプロファイルを読み込みます。

Unix 系の設定を使用する場合は、必要なファイルだけを個別にリンクしてください。

```sh
ln -s "$PWD/zsh/.zshrc" "$HOME/.zshrc"
ln -s "$PWD/zsh/.zprofile" "$HOME/.zprofile"
ln -s "$PWD/irb/.irbrc" "$HOME/.irbrc"
```

既存ファイルを削除する操作は行わず、リンク先にファイルがある場合はバックアップしてから設定してください。
