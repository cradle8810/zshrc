export LANG='en_US.UTF-8'
export LC_ALL="en_US.UTF-8"

if [ -f /usr/bin/uname ]; then
    OS=$(/usr/bin/uname)
fi

#Ctrl-Dを10回押すまでログアウトしない
setopt IGNOREEOF

#ssh
#export DISPLAY=localhost:0.0
XAUTHORITY=~/.Xauthority

#Proxy
if [ -f ~/.proxy-company ]; then
   source ~/.proxy-company
fi

# GPG
export GPG_TTY=$(tty)

# goss
export GOSS_USE_ALPHA=1

# k8s
source <(kubectl completion zsh)
alias k='kubectl'

#############################
# プロンプト設定
#############################
autoload colors
colors

if [ ! -f ~/.promptcolor ]; then

    HOSTNAMELEN="${#HOST}"
    HOSTNAMESUM=0

    for i in {1.."${HOSTNAMELEN}"};
    do
	digit=$(printf "%d\n" "'${HOST[$i]}")
	HOSTNAMESUM=$(( HOSTNAMESUM + digit ))
    done

    HOSTCOLOR=$(( HOSTNAMESUM % 8 ))

    # Black(0), Red(1), White(7) is not allowed
    if [ ${HOSTCOLOR} -eq 0 \
		      -o ${HOSTCOLOR} -eq 1 \
		      -o ${HOSTCOLOR} -eq 7 ]; then
	HOSTCOLOR=3
    fi

    echo "${HOSTCOLOR}" > ~/.promptcolor

else
    HOSTCOLOR=$(cat ~/.promptcolor)
fi

HOSTPROMPT="%F{${HOSTCOLOR}}${HOST}%f"		#ホスト名表示(緑)
CDIRPROMPT="[%3~]"	#カレントディレクトリと、すぐ下のパスを表示
ERRPROMPT="%F{red}%?%f"		#エラー時にはエラーコードを表示(赤)
PROMPTHEADER="%(?,${HOSTPROMPT},${ERRPROMPT})"

PROMPT="${PROMPTHEADER}${CDIRPROMPT}%# "
SPROMPT="%r is correct? [n,y,a,e]: "

#Colors
export LS_COLORS='di=34:ln=36:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

#Printing
setopt AUTO_CD
setopt AUTO_MENU
setopt LIST_PACKED
setopt LIST_TYPES
setopt PRINT_EIGHT_BIT
setopt NO_FLOW_CONTROL # Ignore C-s,C-q

#Complete
setopt AUTO_PARAM_SLASH
setopt NO_RC_EXPAND_PARAM
setopt NOAUTOPARAMKEYS
setopt NOAUTOREMOVESLASH
setopt MAGIC_EQUAL_SUBST
setopt AUTO_PUSHD
bindkey "^[[Z" reverse-menu-complete # Reverse move in menu when pushed Shift-tab
bindkey -e

# 履歴関係
export HISTFILE=~/.history_zsh
export HISTSIZE=15000
export SAVEHIST=15000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# 補完==========================
#completion:function:completer:command:argum ent:tag.

#Case insencitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*:default' completer _complete _expand
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select=long
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose false

zstyle ':completion:*:ssh:*' hosts

#一部の拡張子は補完しない
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'

#コマンドにキャッシュを使用
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache_zsh

#追加のfpath
if [ -d ~/.zcompletion ]; then
    export fpath=(~/.zcompletion $fpath)
fi
if [ "${OS}" = 'Darwin' ] && [ -d /usr/local/share/zsh/site-functions/ ]; then
    fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

autoload -Uz compinit
compinit -C

#====パスを通す======================
if [ ! "$ALREADYPATHLOADED" ]; then
    export ALREADYPATHLOADED=1

    # For Golang
    if [ -d "/Volumes/golang" ]; then
       export GOPATH="/Volumes/golang"
    else
       export GOPATH="${HOME}/go"
    fi

    #Mac用
    if [ "${OS}" = 'Darwin' ]; then
	export PATH=/opt/ImageMagick/bin:$PATH
    fi

    #Golang go/bin
    if [ -n "${GOPATH}" ]; then
       export PATH=$GOPATH:$PATH
    fi

    export PATH=/opt/bin:/opt/sbin:/usr/local/bin:/usr/local/sbin:$PATH
    export MANPATH=/usr/local/man:/usr/share/man:$MANPATH
fi
#===================================

#====エイリアス =========================
setopt complete_aliases

#Mac関連
if [ "${OS}" = 'Darwin' ]; then

    alias preview='open -a Preview'
    alias ql='qlmanage -p "$@" >& /dev/null'
    alias diskio='sudo fs_usage -e -w -f diskio'
    alias keyadd='eval `ssh-agent` & ssh-add'

    alias afsctool-c='afsctool -c -9'
    alias flushdns='sudo killall -HUP mDNSResponder'

    alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'

    #メモリ(Macはvm_stat)
    alias free="echo '\nUse vm_stat\n' && vm_stat"
    alias kaihou='du -sx / &> /dev/null & sleep 18 && kill $!'

    alias finder='open -a Finder'
    alias secretmode='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito'
fi

# Twitterをダウンロードする場合のwget時はuser-agentに'bot'の文字列が必要
alias wget="wget --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36 as bot' "
alias g="wget -nv --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36 as bot' "

#gccはclangに
alias gcc='clang'
alias g++='clang++'
alias gdb='lldb'

#日付をシェルに出す
# today -> yymmdd
# zikan -> hhmm
# ima -> yyyymmdd_hhmm
alias today='sh -c "echo `date +%y%m%d`"'
alias zikan='sh -c "echo `date +%H%M`"'
alias ima='sh -c "echo `date +%Y%m%d_%H%M`"'

alias sc='sort|uniq -c|sort'

alias e='emacs'
alias v='vim'
alias f='find'
alias grep='grep --line-buffered -i'
alias ngrep='grep -n -i --line-buffered --color=always'
alias less='less -R'

alias df='df -lh'
alias du='du -h'
#alias ps='ps aux'
alias dh='echo dh-\>du; du'

#ファイル操作（確認を取る・処理を表示）
alias rm='rm -i'
alias mv='mv -v'
alias cp='cp -v'

#ls関係(ksとかやっちゃったとき用)

#lsの色付けオプションをOSごとに切り替え
if [ 'Linux' = "$OS" ]; then
  alias ls='ls --color'
else
  alias ls='ls -GF'
fi

alias ks='ls'
alias os='ls'
alias ,s='ls'
alias la='ls -A'
alias ka='ls'
alias lks='ls'
alias kls='ls'
alias sl='ls'
alias ll='ls -lh'
alias l='ls'
alias s='ls'
alias lt='ls -lt'
alias ltr='ls -ltrh'
alias lrt='ls -ltrh'
alias lsr='ls -lSrh'

alias t='tree'

#プログラミング関連
alias a='./a.out'
alias javac='javac -encoding utf-8'
alias j='javac -encoding utf-8'
alias m='make'
alias kachi='make'

alias ssh='ssh -A'

# Add Docker comletion file on $fpath using this command...
# sudo curl -O 'https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker'
alias d='docker'

# カレントディレクトリ配下階層1のフォルダそれぞれのファイル数カウント
alias countfile='for i in `find .  -maxdepth 1  -type d `; do echo "`find ${i} -type f | wc -l`\t${i}"; done'

#======================================

# ファイル作成時のパーミッション
umask 022
setopt no_beep
setopt numeric_glob_sort
setopt no_multios
unsetopt promptcr

#起動時に日付を表示
date

