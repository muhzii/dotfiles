# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export GOPATH="$(echo ~/go)"
export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:$(echo ~/.local/bin):$(echo ~/go/bin)"
export PATH="$PATH:$(echo ~/.local/share/gem/ruby/3.0.0/bin)"

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

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
force_color_prompt=yes

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;208m\]\u@\h\[\033[00m\]:\[\033[38;5;178m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
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

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Allow 256 colour support inside tmux.
alias tmux="TERM=xterm-256color tmux"

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias hs='history'

# git aliases
alias gs='git status'
alias gw='git show'
alias gl='git log'
alias gd='git diff'
alias gr='git restore'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'

vim_pager_cmd="nvim -nm --not-a-term -c 'set buftype=nowrite' -c '%sm/\\e.\\{-}m//g' -c 'set ft=diff' -"
alias PRETTY_PAGER="PAGER=\"${vim_pager_cmd}\""

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

# Make vim the default editor.
export EDITOR=nvim
export VISUAL="$EDITOR"

# Use vim mode on the command line.
set -o vi

ensure_tmux_is_running() {
  if [[ -z "$TMUX" ]] ; then
    tat
  fi
}
ensure_tmux_is_running

# File colors read by ls.
LS_COLORS_LIST=(
  "rs=0"
  "di=38;5;214"
  "ln=38;5;87"
  "ex=38;5;40"
  "bd=38;5;226"
  "cd=38;5;226"
  "su=38;5;117;41"
  "sg=0;30;43"
  "tw=38;5;214"
  "ow=38;5;214"
  "st=37;44"
  "pi=38;5;226"
  "so=0;35"
  "*.tar=0;31"
  "*.tgz=0;31"
  "*.zip=0;31"
  "*.gz=0;31"
  "*.bz2=0;31"
  "*.xz=0;31"
  "*.jpg=38;5;220"
  "*.jpeg=38;5;220"
  "*.png=38;5;220"
  "*.gif=38;5;220"
  "*.bmp=38;5;220"
  "*.svg=38;5;220"
  "*.mp3=0;32"
  "*.wav=0;32"
  "*.flac=0;32"
  "*.mp4=0;32"
  "*.mkv=0;32"
  "*.mov=0;32"
  "*.avi=0;32"
)
export LS_COLORS=$(IFS=: ; echo "${LS_COLORS_LIST[*]}")

function swap()
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
. "$HOME/.cargo/env"

sshti() {
    if [ $# -lt 1 ]; then
        echo "Usage: sshti <host>"
        return 1
    fi

    local HOST="$1"
    local TERM_NAME="${TERM:-xterm-kitty}"

    # Send local terminfo to remote ~/.terminfo
    infocmp -a "$TERM_NAME" 2>/dev/null | ssh "$HOST" "mkdir -p ~/.terminfo && tic -x -o ~/.terminfo /dev/stdin"
}

alias vi='nvim'
alias vim='nvim'

if [ -f "$HOME/.secrets/apikeys" ]; then
    source "$HOME/.secrets/apikeys"
fi
