#############################
# 基本環境変数
#############################
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

#############################
# 補完設定 (compinit)
#############################
autoload -Uz compinit
# キャッシュ有効化 (-C で2回目以降の起動を高速化)
compinit -C

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' completer _complete _expand
zstyle ':completion:*' format '%B%d:%b'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' use-compctl false

export LS_COLORS='di=34:ln=36:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:ssh:*' hosts
zstyle ':completion:*:ssh:*:users' ignored-patterns '_*' 'daemon' 'Guest' 'nobody'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache_zsh

#############################
# Zsh オプション設定
#############################
# 新規作成するファイル・ディレクトリのデフォルトパーミッションを設定 (644 / 755)
umask 022

# 動作・表示
setopt IGNOREEOF            # Ctrl-Dの誤入力による即時ログアウトを防止 (複数回押すまで終了しない)
setopt NO_FLOW_CONTROL      # 端末の出力停止(Ctrl-S)・再開(Ctrl-Q)のフロー制御を無効化 (キーバインド誤爆防止)
setopt AUTO_CD              # ディレクトリ名を入力してEnterを押すだけでcdを実行
setopt AUTO_PUSHD           # cd時に古いディレクトリをディレクトリスタックへ自動追加 (pushd相当)
setopt AUTO_MENU            # Tab連打時に補完候補一覧からメニュー選択形式へ自動移行
setopt LIST_PACKED          # 補完候補一覧を横幅に合わせてコンパクト(詰めて)に表示
setopt LIST_TYPES           # 補完候補一覧にファイル種別マーク(/, *, @など)を表示 (ls -F相当)
setopt PRINT_EIGHT_BIT      # 8ビット文字(日本語・マルチバイト文字)をエスケープシーケンス化せず直接表示
setopt NO_BEEP              # コマンドエラー時や補完候補がない時のビープ音を鳴らさない
setopt NUMERIC_GLOB_SORT    # ファイル名展開(glob)時、数値を文字列順ではなく数値の昇順(1, 2, 10...)でソート
setopt NO_MULTIOS           # 複数リダイレクト(tee相当の挙動: cmd > file1 > file2)を無効化
unsetopt PROMPT_CR          # プロンプト表示前の改行復帰コード出力を抑制 (改行のない最終行の出力を上書きしない)

# 補完動作
setopt complete_aliases     # エイリアス展開前の名前に対して個別の補完定義を有効化
setopt AUTO_PARAM_SLASH     # ディレクトリ名の補完完了時、末尾に自動でスラッシュ(/)を付加
setopt NO_RC_EXPAND_PARAM   # 配列展開時にrcシェル風の総当たり展開(foo${array}bar)を行わない
setopt NO_AUTO_PARAM_KEYS   # 補完直後に空白や特定文字を打った際の余計な自動キー調整・削除を無効化
setopt NO_AUTO_REMOVE_SLASH # パス補完後にスペースや記号を入力しても、末尾のスラッシュ(/)を自動削除しない
setopt MAGIC_EQUAL_SUBST    # コマンド引数内の「変数=値」形式(引数=~/path等)でもチルダやglobを展開

# キーバインド
bindkey -e                           # キーバインド体系をEmacs風に設定 (Ctrl-A, Ctrl-Eなど)
bindkey "^[[Z" reverse-menu-complete # Shift-Tabで補完メニューの候補を逆順に選択

#############################
# 履歴設定
#############################
export HISTFILE="${HOME}/.history_zsh" # 履歴を保存するファイルパス
export HISTSIZE=15000                  # メモリ内に保持する履歴の最大件数
export SAVEHIST=15000                  # 履歴ファイルに永続保存する最大件数

setopt APPEND_HISTORY       # シェル終了時に履歴ファイル全体を上書きせず末尾に追記
setopt HIST_IGNORE_ALL_DUPS # 入力したコマンドが過去の履歴に存在する場合、古い重複履歴をすべて削除
setopt HIST_IGNORE_SPACE    # スペースから始まるコマンドを履歴に登録しない (パスワードや機密コマンドの除外用)
setopt HIST_NO_STORE        # historyコマンド(fc -l含む)自体の実行ログを履歴に登録しない
setopt HIST_REDUCE_BLANKS   # コマンドライン前後の余分なスペースや連続する空白文字を1つに詰めて保存
setopt HIST_FIND_NO_DUPS    # 履歴検索時(Ctrl-Rや上矢印)に重複する同一コマンドをスキップ
setopt HIST_SAVE_NO_DUPS    # 履歴ファイル書き出し時に同一の重複コマンドを保存しない
setopt HIST_VERIFY          # 履歴展開(!$)を使用時、即時実行せず一度コマンドライン上に展開して確認

#############################
# プロンプト設定
#############################
autoload -Uz colors && colors

# ホスト名色決定
if [ ! -f ~/.promptcolor ]; then
  integer HOSTNAMESUM=0
  for (( i=1; i<=${#HOST}; i++ )); do
    (( HOSTNAMESUM += $(( [##10] ##${HOST[i]} )) ))
  done
  HOSTCOLOR=$(( HOSTNAMESUM % 8 ))

  # Black(0), Red(1), White(7) を除外
  if [[ $HOSTCOLOR -eq 0 || $HOSTCOLOR -eq 1 || $HOSTCOLOR -eq 7 ]]; then
    HOSTCOLOR=3
  fi
  echo "${HOSTCOLOR}" > ~/.promptcolor
else
  HOSTCOLOR=$(< ~/.promptcolor)
fi

setopt PROMPT_SUBST
SPROMPT="%r is correct? [n,y,a,e]: "

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

setopt PROMPT_SUBST
PROMPT='%F{'${HOSTCOLOR}'}${HOST}%f${PS_EXIT_STATUS}[%3~]%# '

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
