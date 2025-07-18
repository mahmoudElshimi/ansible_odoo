# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

autoload -Uz vcs_info
precmd() {
  vcs_info
}

setopt prompt_subst
function history-fzy() {
  local tac

  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi

  BUFFER=$(history -n 1 | eval $tac | fzy --query "$LBUFFER")
  CURSOR=$#BUFFER

  zle reset-prompt
}

zle -N history-fzy
bindkey '^r' history-fzy

# SET PS1
PS1='%F{yellow}%n@%m:%F{green} %1~%F{cyan}${vcs_info_msg_0_}%F{green}>%f '

#zstyle ':vcs_info:git:*' formats ' (%b %m)'
zstyle ':vcs_info:git:*' formats ' (%b)'

#zstyle ':vcs_info:git:*' formats '%r/%b [%m]'


# Function to print json response 
jcurl() {
  local method=$1
  local url=$2
  local body=$3

  if [[ -z "$method" || -z "$url" || -z "$body" ]]; then
    echo "Usage: jcurl <METHOD> <URL> <BODY_JSON>"
    echo "Example:"
    echo "  jcurl POST https://example.com/end_ping '{\"jcurl\": \"2.0\", ... }'"
    return 1
  fi

  echo "$body" | curl -s -X "$method" "$url" \
    -H "Content-Type: application/json" \
    -d @- | python -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))" \
    | bat --language=json
}

js() {
  python -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))" | bat --language=json
}


# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=$HOME/.histfile
# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^ulfcd\n'

bindkey -s '^a' '^ubc -lq\n'

bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Enable partial completion on ambiguous input
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Bind up and down arrow keys to search through history
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Verbosity and settings that you pretty much just always are going to want.
alias \
	vi='vim' \
	cp='cp -irv' \
	mv='mv -iv' \
	rm='rm -vrI' \
	ll='ls -l' \
	la='ls -a' \
	c='clear' \
	rsync='rsync -vrPlu' \
	mkdir='mkdir -pv' \
	sudo='sudo ' \
	doas='doas' \
	pa='patch -p1 <' 
# Colorize commands when possible.
alias \
	ls='ls -hN --color=auto --group-directories-first' \
	grep='grep --color=auto' \
	diff='diff --color=auto' \
	ip='ip -color=auto'

fcd(){
  cd "$(find -type d | fzy)"
}


typeset -U path PATH
path=(~/.scripts $path)
export PATH

source  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
