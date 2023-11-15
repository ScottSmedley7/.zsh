# This file is read for interactive zsh sessions.
# (ie. not read by zsh scripts when they are executed.)

#shopt() { }
#. $HOME/.bashrc

alias d='ls -alF --color'

[ -z "$SHELL" ] && export SHELL=$0
[[ $SHELL == "-zsh" ]] && export SHELL=zsh

export SAVEHIST=256
export HISTSIZE=256
export HISTFILE=${ZDOTDIR:=$HOME}/.history.zsh

bindkey -v	# Vi key bindings on the command-line.

# Turn on spelling-correction.
setopt correct	# for commands.
setopt correctall	# for arguments.

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^U' kill-whole-line # backward-kill-line
# bindkey "$(echotc kl)" vi-backward-char
# bindkey "$(echotc kr)" vi-forward-char
# bindkey "$(echotc ku)" up-line-or-history
# bindkey "$(echotc kd)" down-line-or-history
bindkey '^V' copy-prev-word
bindkey '^B' history-search-backward
bindkey '^F' history-search-forward
# bindkey '^K' send-break	# mostly used for aborting a buffer.
# bindkey '^M' accept-and-infer-next-history
bindkey '^P' push-input # push in2 a buffer.
bindkey ' ' magic-space

export COMPLETEINWORD=1

# Don't allow CONTROL-D to exit shell.
setopt ignoreeof

autoload -U compinit
# -i: compinit may complain about "insecure directories".
# This just means that some of the completion files that
# will b used r owned by some1 other than root or $USER.
compinit -i
# not allowed to use old 'compctl' syntax
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' _list completer _expand _complete _correct _approximate
zstyle ':completion:*' glob 1
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' insert-unambiguous true

# menu selection
zmodload -i zsh/complist
# activate menu completion
zstyle ':completion:*' menu select=10
bindkey -M menuselect '^o' accept-and-infer-next-history
# autocompletion should use colors from LS_COLORS env. var.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
setopt completeinword
# maximum number of errors 2 look 4 when spelling correction.
zstyle ':completion:*' max-errors 2
zstyle ':completion:*:*:kill:*:processes' list-colors

# already available:
# zstyle ':completion:*:*:gzip:*:*' file-patterns '*gz'

if [ -r $HOME/.rhosts ] ; then
	cat $HOME/.rhosts | while read host user ; do
		rloginBuffer=($rloginBuffer $user:$host)
		# telnetBuffer=($telnetBuffer $host:23:$user)
	done

	zstyle ':completion:*' users-hosts $rloginBuffer
	# zstyle ':completion:*' hosts-ports-users $telnetBuffer
fi

# zftp : don't load until I work out how 2 use it
# properly
# zmodload -i zsh/zftp

# prediction: this is great, albeit slow!
autoload -U incremental-complete-word predict-on
zle -N incremental-complete-word
zle -N predict-on
zle -N predict-off
bindkey '^Xi' incremental-complete-word
bindkey '^Xp' predict-on
bindkey '^X^P' predict-off
bindkey "^Xh" _complete_help

# _rcsdiff () { compadd ${${(f)"$(/bin/ls -A RCS/)"}%%,v} }
compdef _rcs rci rco ci co rdiff rcsdiff
compdef _runChess runChess

# menu selection doesn't work unless we add these bindings.
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[C" forward-char
bindkey "^[[D" backward-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

setopt globdots

# Some machines overwrite $HOSTNAME in /etc/profile, so set it again.
# export HOSTNAME=$(hostname | cut -d. -f1 | tr '[:upper:]' '[:lower:]')

export PS1=$USER@$HOSTNAME
if type getDir > /dev/null ; then
	let i=32+$RANDOM%5
	(( i == 34 )) && (( i++ ))	# darkblue is too dark.
	(( i == 33 )) && (( i-- ))	# yellow is too light.
	PROMPT_COLOR_ARGS=($i invisible bold)
	unset i
	export PROMPT_STRING="%{$(setColor $PROMPT_COLOR_ARGS[1,2])%}$PS1"
    # modify the prompt if shell is running in 32-bit mode on a 64-bit OS
    [[ $(uname -m) == "i686" ]] && [[ $(getconf LONG_BIT) == "64" ]] && export PROMPT_STRING="$PROMPT_STRING%{$(setColor 33 invisible bold)%}:i686"
else
	export PS1="$PS1>> "
    [[ $(uname -m) == "i686" ]] && [[ $(getconf LONG_BIT) == "64" ]] && export PS1="$PS1:i686"
fi


umask 022


h () { builtin history ${1:=1} }



color () { echo "$(setColor $2 invisible ${3:=bold})$1$(setColor normal)" }

# Auto-complete from ctags file when gvim -t.
function _get_tags {
  [ -f $p/tags ] || return
  local cur=$words[$CURRENT]
  compadd $(/bin/grep "^$cur" $p/tags | cut -f1 | sort | uniq)
  return 0
}
_ctags () { _arguments '-o::_files' '-t:tag:_get_tags' ':files:_files' }
compdef _ctags gvim

unset LANG

updategetdirs () {
    export GETDIR_DIRS=""
	foreach d ($(env | grep '=/' | egrep -v '(:|PWD|CCACHE)' | perl -e 'print sort { length $b <=> length $a } <>' | cut -f1 -d=))
		val=$(eval echo \$$d)
		[ -d $val ] && echo -n $val | wc -c | tr -d '\n' && echo " $d $val"
	end | sort -r -n | cut -f2 -d' ' | while read ev ; do
		export GETDIR_DIRS="$GETDIR_DIRS $ev"
	done
}
setproject_postcmd () { updategetdirs ; chpwd }
# _setproject - command-line completion for setproject command.
_setproject () {
	compadd $r/integration/integ*(:t) $r/project/prj*(:t) $r/main*(:t) $r/support/spt-*(:t) $r/intproject/prj*(:t)
}
compdef _setproject setproject


_setcompiler () { compadd default /usr/local/gcc-*(:t:s/gcc-//) $BK/../$(uname -m)*(:t:s/$(uname -m)-gcc//) }
compdef _setcompiler setcompiler

export compiler=$HOME/.compiler.$HOSTNAME
if [ -f $compiler ] ; then
    setcompiler $(cat $compiler)
    # isloginshell && echo -n Compiler version: $(gcc -dumpversion)
fi


# TODO: need to add .00. suffix to labels
# http://zsh.sourceforge.net/Doc/Release/Expansion.html#Modifiers
_buildrelease () { compadd $r/integration/integ*(:t:s/integ-//) }
compdef _buildrelease buildrelease



foreach f (${ZDOTDIR:=$HOME}/.zsh/mod/.zshrc.*)
    [[ $f:e != "old" ]] && [[ $f:e != "swp" ]] && . $f
end

[ -f ${ZDOTDIR:=$HOME}/.zsh/.zshrc.$HOSTNAME ] && . ${ZDOTDIR:=$HOME}/.zsh/.zshrc.$HOSTNAME

updategetdirs

chpwd
