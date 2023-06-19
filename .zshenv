
# .zshenv IS read by zsh scripts
# .zshenv is read before .zshrc

export zm=~/.zsh/mod
export zf=~/.zsh/func
# specify functions to be autoloaded:
fpath=($zf $fpath)
foreach f ($zf/*)
    if [[ $f[-4,-1] != ".zwc" ]] && [ -f $f ] ; then
        autoload ${f:t}
    fi
end

function isloginshell () { [[ -o interactive ]] }
function path () { eval echo \$${1:-PATH} | tr -s ':' '\n' ; }
function ldpath () { path LD_LIBRARY_PATH ; }
function _addpath () {
    if [ ! -d $2 ] ; then
        # echo "directory does not exist: $2"
        false
        return
    fi
    if path $1 | grep -q "^$2$" ; then
        # echo "directory already in \$$1: $2"
        return
    fi
    # echo "Adding $2 to \$$1"
    if [[ "$3" == "start" ]] ; then
        eval export $1=$2:\$$1
    else
        eval export $1=\$$1:$2
    fi
}
function addpath () { _addpath PATH $* ; }
function addlibpath () { _addpath LD_LIBRARY_PATH $* ; }

# isloginshell || unfunction preexec precmd setTitleAndIcon

#if [[ ! -o interactive ]] ; then
#	# This is NOT an interactive shell
#	unfunction preexec precmd setTitleAndIcon
#fi

# fignore lists suffixes of files to ignore  during completion.
fignore=( .swp .bak )

setopt autocd
setopt interactivecomments
unsetopt bgnice
unsetopt autoremoveslash
setopt globdots
setopt noclobber	# don't allow overwriting of files without >!

setopt autolist
setopt automenu		# menu completion after 2nd tab.
# setopt menucomplete	# tab will cycle thru list
setopt listtypes	# see type of file in list.
setopt automenu

# This f**king thing is what makes the colors NOT work!
unset XFILESEARCHPATH

[ -f $HOME/.bc ] && export BC_ENV_ARGS="-l $HOME/.bc"

export HOSTNAME=$(hostname | cut -d. -f1 | tr '[:upper:]' '[:lower:]')
[ -f ~/.zsh/.zshenv.$HOSTNAME ] && . ~/.zsh/.zshenv.$HOSTNAME

[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH
skip_global_compinit=1
