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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[0;32m\]\u@\h\[\033[00m\]:\[\033[0;34m\]\w\[\033[00m\]\$ '
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

# Make kitty work correctly when remoting to another machine.
alias ssh="kitty +kitten ssh"

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
export EDITOR=vim
export VISUAL="$EDITOR"

# Use vim mode on the command line.
set -o vi

ensure_tmux_is_running() {
  if [[ -z "$TMUX" ]] ; then
    tat
  fi
}
ensure_tmux_is_running

# Use xcape to map Ctrl to Esc if released before a 200ms timeout.
pgrep xcape >/dev/null
if [[ $? -ne 0 ]]; then
  xcape -e 'Control_L=Escape' -t 200
fi

# File colors read by ls.
export LS_COLORS='rs=0:di=0;34:ln=0;36:mh=00:pi=40;33:so=0;35:do=0;35:bd=41;33;0:cd=33;0:or=40;31;0:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=0;32:*.tar=0;31:*.tgz=0;31:*.arc=0;31:*.arj=0;31:*.taz=0;31:*.lha=0;31:*.lz4=0;31:*.lzh=0;31:*.lzma=0;31:*.tlz=0;31:*.txz=0;31:*.tzo=0;31:*.t7z=0;31:*.zip=0;31:*.z=0;31:*.dz=0;31:*.gz=0;31:*.lrz=0;31:*.lz=0;31:*.lzo=0;31:*.xz=0;31:*.zst=0;31:*.tzst=0;31:*.bz2=0;31:*.bz=0;31:*.tbz=0;31:*.tbz2=0;31:*.tz=0;31:*.deb=0;31:*.rpm=0;31:*.jar=0;31:*.war=0;31:*.ear=0;31:*.sar=0;31:*.rar=0;31:*.alz=0;31:*.ace=0;31:*.zoo=0;31:*.cpio=0;31:*.7z=0;31:*.rz=0;31:*.cab=0;31:*.wim=0;31:*.swm=0;31:*.dwm=0;31:*.esd=0;31:*.jpg=0;35:*.jpeg=0;35:*.mjpg=0;35:*.mjpeg=0;35:*.gif=0;35:*.bmp=0;35:*.pbm=0;35:*.pgm=0;35:*.ppm=0;35:*.tga=0;35:*.xbm=0;35:*.xpm=0;35:*.tif=0;35:*.tiff=0;35:*.png=0;35:*.svg=0;35:*.svgz=00;35:*.mng=0;35:*.pcx=0;35:*.mov=0;35:*.mpg=0;35:*.mpeg=0;35:*.m2v=0;35:*.mkv=0;35:*.webm=0;35:*.webp=0;35:*.ogm=0;35:*.mp4=0;35:*.m4v=0;35:*.mp4v=0;35:*.vob=0;35:*.qt=0;35:*.nuv=0;35:*.wmv=0;35:*.asf=0;35:*.rm=0;35:*.rmvb=0;35:*.flc=0;35:*.avi=0;35:*.fli=0;35:*.flv=0;35:*.gl=0;35:*.dl=0;35:*.xcf=0;35:*.xwd=0;35:*.yuv=0;35:*.cgm=0;35:*.emf=0;35:*.ogv=0;35:*.ogx=0;35:*.aac=0;36:*.au=0;36:*.flac=0;36:*.m4a=0;36:*.mid=0;36:*.midi=0;36:*.mka=0;36:*.mp3=0;36:*.mpc=0;36:*.ogg=0;36:*.ra=0;36:*.wav=0;36:*.oga=0;36:*.opus=0;36:*.spx=0;36:*.xspf=0;36:'
