## Completion configuration
autoload -U compinit
compinit

# auto change directory
setopt auto_cd

# auto directory pushd that you can get dirs list by cd -[tab]
setopt auto_pushd

# command correct edition before each completion attempt
setopt correct

# compacked complete list display
setopt list_packed

# no beep sound when complete list displayed
setopt nolistbeep

## Keybind configuration
#
# emacs like keybind (e.x. Ctrl-a goes to head of a line and Ctrl-e goes 
#   to end of it)
#
bindkey -e

## Command history configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=100000
setopt hist_ignore_dups     # ignore duplication command history list
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt share_history        # share command history data
setopt inc_append_history   # append history in order of executing the command with each terminal.
setopt bang_hist
setopt hist_verify          # It doesn't execute soon when history expand, and it reads once.
setopt hist_no_functions    # The function is excluded from history list.
setopt hist_no_store        # History command is not recorded.
setopt extended_history     # The execution time is recorded.
setopt hist_reduce_blanks   # The extra space is excluded and it records.

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

## Default shell configuration
#
# set prompt
#
case ${UID} in
0)
    PROMPT="%B%{[31m%}%/#%{[m%}%b "
    PROMPT2="%B%{[31m%}%_#%{[m%}%b "
    SPROMPT="%B%{[31m%}%r is correct? [n,y,a,e]:%{[m%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
    ;;
*)
    PROMPT="%{[33m%}%/%%%{[m%} "
    #PROMPT="%{[31m%}%/%%%{[m%} "
    PROMPT2="%{[31m%}%_%%%{[m%} "
    SPROMPT="%{[31m%}%r is correct? [n,y,a,e]:%{[m%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
    ;;
esac

# set terminal title including current directory
case "${TERM}" in
kterm*|xterm)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# backword-kill-word of zsh behavior is changed like emacs.
# http://d.hatena.ne.jp/yaotti/20090217/1234833770
WORDCHARS="*?_-.[]~=&!#$%^(){}<>"

# Emacs hoo fof
[[ $TERM = "eterm-color" ]] && TERM=xterm-color

preexec () {
  [ ${STY} ] && echo -ne "\ek${1%% *}\e\\"  # 20070907 修正
}

# [ ${STY} ] || screen -rx || screen -D -RR  # 20070905 修正

## load user .zshrc configuration file
[ -f ~/.zshrc.mine ] && source ~/.zshrc.mine

export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init - zsh)"
export CC=/usr/bin/gcc-4.2

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 

