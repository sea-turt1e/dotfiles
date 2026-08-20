# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# 秘密情報を含みやすいコマンドは履歴に残さない。
# HISTCONTROL=ignoreboth により「行頭スペース」でも記録を抑止できる（秘匿用）。
HISTIGNORE='*TOKEN=*:*KEY=*:*SECRET=*:*PASSWORD=*:curl *Authorization*:* --password *'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1\n>"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi



# xsel で pbcopy を使う（Linux 限定）
# macOS には本物の pbcopy があるため、上書きすると壊れる。OS で分岐する。
if [ "$(uname -s)" = "Linux" ] && command -v xsel >/dev/null 2>&1; then
    alias pbcopy='xsel --clipboard --input'
fi

#端末のメッセージを英語にする
export LANG=en_US

case $TERM in
    linux) LANG=C ;;
    *) LANG=ja_JP.UTF-8 ;;
esac

# エイリアス
# GNU ls 専用オプション。macOS の BSD ls では動かないので分岐する
if [ "$(uname -s)" = "Linux" ]; then
    alias ls='ls --color=auto'
fi
alias so='source'
alias vi='vim'
alias vb='vim ~/.bashrc'

alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias back='pushd'
alias diff='diff -U1'
alias gc='git commit -m'
alias gitc='git commit -m '
alias pyt='python'
alias gits='git status'
alias gita='git add'
alias ga='git add'
alias gp='git push'
alias jn='jupyter notebook'
alias slp='systemctl suspend'

# see pickle file in terminal
alias pcat='python -m pickle'

# pyenvのPATHを通す
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# 注意: PATH に "~" をクォート付きで書くとチルダが展開されず、
# カレントディレクトリ基準の相対パスとして解釈される。
# 移動先のディレクトリに細工されたコマンドを置かれると実行してしまう
# （PATH ハイジャック）。必ず $HOME を使い、存在確認してから追加する。

# ngrok の PATH を通す
[ -d "$HOME/local/bin" ] && export PATH="$HOME/local/bin:${PATH}"

# original-shell-script の PATH
[ -d "$HOME/original-shell-script" ] && export PATH="$HOME/original-shell-script:${PATH}"

# source ~/enhancd/init.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# BoostNote のパスを通す（同上・$HOME を使う）
[ -d "$HOME/AppImage" ] && export PATH="$HOME/AppImage:${PATH}"

# --- 秘密情報はここに書かず ~/.bashrc.local に置く（.gitignore 済み） ---
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
