export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export GPG_TTY=$(tty)
export GOSS_USE_ALPHA=1
export XAUTHORITY="${HOME}/.Xauthority"

# OS判定
case "$OSTYPE" in
  darwin*) OS='Darwin' ;;
  linux*)  OS='Linux'  ;;
  *)       OS=$(uname -s 2>/dev/null) ;;
esac

#############################
# パス・fpath設定
#############################
typeset -U path fpath

# Go関連パス
if [ -d "/Volumes/golang" ]; then
  export GOPATH="/Volumes/golang"
else
  export GOPATH="${HOME}/go"
fi

path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  /usr/local/sbin
  /opt/bin
  /opt/sbin
  ${GOPATH}/bin
  $path
)

if [ "${OS}" = 'Darwin' ]; then
  path=(/opt/ImageMagick/bin $path)
fi

export PATH
export MANPATH="${MANPATH:-}:/usr/local/man:/usr/share/man"

# 補完関数の読み込みパス
[[ -d "${HOME}/.zcompletion" ]] && fpath=("${HOME}/.zcompletion" $fpath)
[[ -d "${HOME}/.docker/completions" ]] && fpath=("${HOME}/.docker/completions" $fpath)
if [ "${OS}" = 'Darwin' ] && [ -d /usr/local/share/zsh/site-functions ]; then
  fpath=(/usr/local/share/zsh/site-functions $fpath)
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

# PROMPT
HOSTPROMPT="%F{${HOSTCOLOR}}${HOST}%f"
CDIRPROMPT="[%3~]"

# 直前のコマンドの終了ステータスに応じて表示文字列を生成
set_prompt_exit_code() {
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    PS_EXIT_STATUS="(0)"
  else
    PS_EXIT_STATUS="%F{red}(${exit_code})%f"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt_exit_code

# プロンプト展開時に $PS_EXIT_STATUS を変数展開させるためPROMPT_SUBSTを有効化
setopt PROMPT_SUBST

PROMPTHEADER='${HOSTPROMPT}${PS_EXIT_STATUS}'
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

# ファイル作成時のパーミッション
umask 022
setopt no_beep
setopt numeric_glob_sort
setopt no_multios
unsetopt promptcr

# 補完==========================
#completion:function:completer:command:argument:tag.

#大文字小文字の区別をしない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zstyle ':completion:*:default' completer _complete _expand

#補完しているグループを太字で表示する(%d)
zstyle ':completion:*' format '%B%d:%b'

zstyle ':completion:*:default' menu select=2

#ls(1)時の表示はLS_COLORS変数の設定に任せる
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' menu select=long
zstyle ':completion:*' use-compctl false

## 各種コマンド用
# ssh(1)時はhosts(5)を補完対象にする
zstyle ':completion:*:ssh:*' hosts
# ssh(1)時は一部ユーザネームを対象外にする
zstyle ':completion:*:ssh:*:users' ignored-patterns '_*' 'daemon' 'Guest' 'nobody'

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

#############################
# エイリアス
#############################
# OS別 ls
if [ "${OS}" = 'Linux' ]; then
  alias ls='ls --color=auto'
else
  alias ls='ls -GF'
fi

# 基本エイリアス
alias ll='ls -lh'
alias la='ls -A'
alias l='ls'
alias s='ls'
alias sl='ls'
alias ks='ls'
alias os='ls'
alias ,s='ls'
alias lks='ls'
alias kls='ls'
alias lt='ls -lt'
alias ltr='ls -ltrh'
alias lrt='ls -ltrh'
alias lsr='ls -lSrh'
alias t='tree'

alias rm='rm -i'
alias mv='mv -v'
alias cp='cp -v'

alias df='df -lh'
alias du='du -h'
alias dh='echo "dh -> du"; du'

alias e='emacs'
alias v='vim'
alias f='find'
alias grep='grep --line-buffered -i'
alias ngrep='grep -n -i --line-buffered --color=always'
alias less='less -R'
alias sc='sort | uniq -c | sort'

alias a='./a.out'
alias m='make'
alias kachi='make'
alias javac='javac -encoding utf-8'
alias j='javac -encoding utf-8'

alias gcc='clang'
alias g++='clang++'
alias gdb='lldb'
alias ssh='ssh -A'
alias d='docker'
alias wget='wget --timestamping'
alias g='wget --timestamping'

alias yt-dlp-s="yt-dlp --use-postprocessor FixupMtime:mtime_key=upload_date -f 'bv*[vcodec^=avc]+ba[ext=m4a]/b[ext=mp4]/b' -o '%(title)s'"

# 日付出力 (サブシェルの重複を省き、dateコマンド直呼び出しに変更)
alias today='date +%y%m%d'
alias zikan='date +%H%M'
alias ima='date +%Y%m%d_%H%M'

# ディレクトリ直下のファイル数カウント
alias countfile='find . -maxdepth 1 -type d -print0 | while IFS= read -r -d "" d; do printf "%s\t%s\n" "$(find "$d" -type f | wc -l)" "$d"; done'

# macOS 固有のエイリアス
if [ "${OS}" = 'Darwin' ]; then
  alias preview='open -a Preview'
  alias ql='qlmanage -p "$@" >& /dev/null'
  alias diskio='sudo fs_usage -e -w -f diskio'
  alias keyadd='eval "$(ssh-agent)" && ssh-add'
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'
  alias free='printf "\nUse vm_stat\n\n" && vm_stat'
  alias kaihou='du -sx / &> /dev/null & sleep 18 && kill $!'
  alias finder='open -a Finder'
  alias secretmode='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito'
fi

#############################
# CLI ツールの補完設定
#############################
if (( $+commands[kubectl] )); then
  source <(kubectl completion zsh)
  alias k='kubectl'
fi

# 起動確認
date
