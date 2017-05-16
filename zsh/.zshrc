if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sudo apt-get install curl -y
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="amuse"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

plugins=(bower ubuntu git laravel5 command-not-found common-aliases composer docker docker-compose git-extras git-flow gitignore gulp npm pip ssh-agent supervisor tmux vagrant vim-interaction last-working-dir yarn zsh-syntax-highlighting)

# User configuration
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$PATH"

# COMPOSER
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

# AZK
export PATH="$PATH:$HOME/azk/bin"

# GO
export GOPATH=$HOME/go
export PATH=$PATH:/usr/bin/go:$GOPATH/bin

source $ZSH/oh-my-zsh.sh

export LANG=pt_BR.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# Ensure 'escape dot' sequence works like default bash/zsh.
bindkey '\e.' insert-last-word

# Turn off annoying autocorrect
unsetopt CORRECT_ALL

# Say how long a command took, if it took more than 30 seconds
export REPORTTIME=30

export TERM=xterm-256color

# Base16 Shell
BASE16_SHELL="$HOME/.base16-shell/base16-ocean.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

fpath=(~/.zsh/completion $fpath)

#################
### FUNCTIONS ###
#################

# GIT

# Commit all the current changes with a message
function comme {
  git add --all
  if (($# > 1)); then
    params=''
    for i in $*;
    do
        params=" $params $i"
    done
    git commit -m "$params"
  else
    git commit -m "$1"
  fi
}

# Commit the current changes and push to the current branch
function pushme {
  br=`git branch | grep "*"`
  git add --all
  if (($# > 1)); then
    params=''
    for i in $*;
    do
        params=" $params $i"
    done
    git commit -m "$params"
  else
    git commit -m "$1"
  fi
  git push origin ${br/* /}
}

# Docker

function docker_build() {
  sudo docker build -t $1 .
}

function docker_tag() {
  sudo docker tag $1 $2
}

function docker_push() {
  sudo docker push $1
}

function dclean() {
    processes=`docker ps -q -f status=exited`
    if [ -n "$processes" ]; then
      docker rm $processes
    fi

    images=`docker images -q -f dangling=true`
    if [ -n "$images" ]; then
      docker rmi $images
    fi
}

lsp() {
  lpass show -c --password $(lpass ls  | fzf | awk '{print $(NF)}' | sed 's/\]//g')
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fkill() {
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    kill -${1:-9} $pid
  fi
}

ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}

# LARAVEL
alias as='php artisan'

# ALIAS
alias ls='ls -Glah --color=always'
alias ll='ls -lah'
alias l='ls -CF'

# GIT
alias gt='git status'
alias ga='git add --all'
alias gc='git commit'
alias guo='git pull origin'
alias gpo='git push origin'


# GIT FLOW
alias gffs='git flow feature start'
alias gfff='git flow feature finish'
alias gfrs='git flow release start'
alias gfrf='git flow release finish'

# VAGRANT
alias vu='vagrant up'
alias vh='vagrant halt'
alias vr='vagrant reload'
alias vs='vagrant status'
alias vsh='vagrant ssh'
alias vp='vagrant provision'
alias vbu='vagrant box update'

# COMPOSER
alias cu='composer update --prefer-dist'
alias ci='composer install --prefer-dist'

# NPM
alias ni='npm install'
alias nig='npm install -g'

# YARN
alias y='yarn'
alias yg='yarn global add'

# GULP
alias g='gulp'
alias gw='gulp watch'

# Docker
alias db='docker_build '
alias dt='docker_tag '
alias dp='docker_push '
alias phpstan='docker run -v $PWD:/app --rm phpstan/phpstan'
alias phpqa='docker run --rm -u $UID -v $PWD:/app eko3alpha/docker-phpqa --report --ignoreDirs vendor,build,migrations,test'

# SYSTEM
alias agi='sudo apt-get install'
alias agu='sudo apt-get update'
alias agg='sudo apt-get upgrade'
alias aguu='sudo apt-get update && sudo apt-get upgrade'
alias workspace='cd ~/workspace'
alias downloads='cd ~/Downloads'
alias dotfiles='cd ~/.dotfiles'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias egrep='grep --color=auto'
alias fixdns='sudo apt-get install -yqq dnsmasq && sudo /etc/init.d/dnsmasq restart && sudo apt-get remove --purge  dnsmasq -y'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(thefuck --alias)"

export RANCHER_URL="http://163.172.129.177:8080"
export RANCHER_ACCESS_KEY="41E3CFE70EC8428A2B68"
export RANCHER_SECRET_KEY="ne5pzZJkx3hGzuPx2XDdroi7Vgh4bp5mnDcaHuCE"
export RANCHER_CLIENT_DEBUG=false

