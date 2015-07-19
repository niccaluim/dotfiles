HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

unsetopt autocd
bindkey -e

zstyle :compinstall filename ~/.zshrc
autoload -Uz compinit
compinit

export PATH="$HOME/bin:$PATH"
export PAGER='less -X'
if command -v bbeditor >& -; then; export EDITOR=bbeditor; else
if command -v emacs >& -;    then; export EDITOR=emacs;
fi; fi

alias ls='ls -F'
alias less='less -X'

function git_branch {
    git_status=$(git status -b --porcelain 2> /dev/null) || return
    echo -n ' '
    n='
'
    if [[ $git_status =~ "## ([^$n]+)($n)?" ]]; then
        if ! [[ -z $match[2] ]]; then
            echo -n '*'
        fi
        echo "${match[1]%...*}"
    fi
}
setopt prompt_subst
PROMPT='%B%n@%m %3~$(git_branch) %#%b '

case $TERM in
    xterm*)
        precmd () { print -Pn "\e]0;%n@%m: %~\a" }
        ;;
esac

# virtualenvwrapper
if [[ -e /usr/local/bin/virtualenvwrapper.sh ]]; then
    export WORKON_HOME=~/.virtualenvs
    export PROJECT_HOME=~/workspace
    export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi

# git shortcuts
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gdm='git master'
alias gg='git grep'
alias gm='git merge'
alias gmm='git merge master'
alias gp='git pull'
alias gs='git status'

# go
export GOPATH=~/workspace
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# docker shortcuts
function b2d {
    if command -v boot2docker >& -; then
        boot2docker up &> /dev/null && \
            eval "$(boot2docker shellinit 2>& -)" && \
            export X_DOCKER_IP=`echo $DOCKER_HOST | sed 's|tcp://\(.*\):[0-9]*|\1|'` || \
            echo error >&2
    else
        export X_DOCKER_IP=127.0.0.1
    fi
    export X_DOCKER_PORT=`docker ps -l | tail -n 1 | grep : | cut -d : -f 2 | cut -d - -f 1`
}

function dcurl {
    if [[ -z $X_DOCKER_IP ]]; then b2d; fi
    curl "${@:1:$(( $# - 1 ))}" "$X_DOCKER_IP:$X_DOCKER_PORT${(P)#}"
}

if [[ "$(boot2docker status 2>& -)" == "running" ]]; then
    eval "$(boot2docker shellinit 2>& -)"
fi

# local config
if [[ -e ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
