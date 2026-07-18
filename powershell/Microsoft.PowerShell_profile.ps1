# ============================================================
# PowerShell Profile
# ============================================================

# ------------------------------------------------------------
# PSReadLine and command-line editing
# ------------------------------------------------------------

Import-Module PSReadLine -ErrorAction SilentlyContinue

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {

# Enable Emacs-style command-line editing
Set-PSReadLineOption -EditMode Emacs

# Enable inline suggestions from command history
Set-PSReadLineOption -PredictionSource History

# Explicit key bindings
Set-PSReadLineKeyHandler -Chord Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function KillLine
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Ctrl+l -Function ClearScreen

# Keep Ctrl+F available for moving forward one character
Set-PSReadLineKeyHandler -Chord Ctrl+f -Function ForwardChar
}


# ------------------------------------------------------------
# Claude Code
# ------------------------------------------------------------

# Start Claude Code with the Discord channel plugin
function claude-discord {
    claude --channels plugin:discord@claude-plugins-official
}


# ------------------------------------------------------------
# File and directory operations
# ------------------------------------------------------------

# Remove files or directories recursively and forcibly
# Usage:
#   rmrf .\test
#   rmrf .\folder1 .\folder2
function rmrf {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromRemainingArguments = $true
        )]
        [string[]]$Path
    )

    Remove-Item -LiteralPath $Path -Recurse -Force
}

# ------------------------------------------------------------
# Directory navigation
# ------------------------------------------------------------

# Move to the parent directory
function .. {
    Set-Location ..
}

# Move up two directory levels
function ... {
    Set-Location ..\..
}

# Open the current directory in File Explorer
function open {
    explorer.exe .
}

# Move to the GitHub working directory
function cdd {
    Set-Location "$HOME\Github"
}


# ------------------------------------------------------------
# File listing and search
# ------------------------------------------------------------

# Show a detailed directory listing including hidden files
function ll {
    param(
        [Parameter(Position = 0)]
        [string[]]$Path = @(".")
    )

    Get-ChildItem -LiteralPath $Path -Force
}

# Show all files including hidden files
function la {
    Get-ChildItem -Force
}

# Find the command that would be executed
function which {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    Get-Command $Name -ErrorAction SilentlyContinue
}

# Create an empty file or update an existing file's timestamp
function touch {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        (Get-Item -LiteralPath $Path).LastWriteTime = Get-Date
    }
    else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

# Search text in files using grep-like syntax
# Usage:
#   grep "search text"
#
# Recursive search:
#   grep "search text" -Recurse
function grep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [Parameter(Position = 1)]
        [string[]]$Path = @("."),

        [switch]$Recurse,

        [switch]$CaseSensitive
    )

    $getChildItemParams = @{
        LiteralPath = $Path
        File = $true
        ErrorAction = "SilentlyContinue"
    }

    if ($Recurse) {
        $getChildItemParams.Recurse = $true
    }

    Get-ChildItem @getChildItemParams |
        Select-String -Pattern $Pattern -CaseSensitive:$CaseSensitive
}


# ------------------------------------------------------------
# Git commands
# ------------------------------------------------------------

# Run git status
function gs {
    git status
}

# Show unstaged changes
function gd {
    git diff
}

# Show a compact commit graph
function gl {
    git log --oneline --decorate --graph -20
}

# Switch branches
function gco {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Branch
    )

    git checkout $Branch
}

# Add all changes and create a commit
# Usage:
#   gcm "Commit message"
function gcm {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )

    git add .

    if ($LASTEXITCODE -ne 0) {
        Write-Error "git add failed."
        return
    }

    git commit -m $Message
}

# Push the current branch
function gp {
    git push
}

# Pull the current branch
function gpull {
    git pull
}


# ------------------------------------------------------------
# PowerShell profile management
# ------------------------------------------------------------

# Open this profile in Notepad
function edit-profile {
    notepad.exe $PROFILE
}

# Short command for editing this profile
function ep {
    notepad.exe $PROFILE
}

# Reload this profile
function reload {
    . $PROFILE
}


# ============================================================
# End of PowerShell Profile
# ============================================================
