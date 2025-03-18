# Color definitions (converting tput colors to zsh format)
bold='%B'
reset='%b%f'
blue='%F{153}'
steel_blue='%F{67}'
green='%F{71}'
orange='%F{166}'
red='%F{167}'
white='%F{15}'
yellow='%F{228}'

# Set user style based on root status
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}"
else
    userStyle="${orange}"
fi

# Set host style based on SSH status
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}"
else
    hostStyle="${yellow}"
fi

# Git status function
function prompt_git() {
    local git_status=''
    local branchName=''
    
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local gitSummary=$(git status --porcelain)
        [[ -n $(echo "$gitSummary" | grep '^M') ]] && git_status+='+'
        [[ -n $(echo "$gitSummary" | grep '^ M') ]] && git_status+='!'
        [[ -n $(echo "$gitSummary" | grep '^\?\?') ]] && git_status+='?'
        [[ $(git rev-parse --verify refs/stash &>/dev/null; echo "${?}") == '0' ]] && git_status+='$'
        
        branchName="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo '(unknown)')"
        [ -n "${git_status}" ] && git_status=" [${git_status}]"
        
        echo "${white} on ${blue}${branchName}${git_status}"
    fi
}

# Virtual environment function
export VIRTUAL_ENV_DISABLE_PROMPT=1
function prompt_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        echo "\n${steel_blue}(${venv_name})\n"
    fi
}

# Enable required zsh options
setopt PROMPT_SUBST

# Set the prompt
PROMPT='$(prompt_venv)' # virtual environment
PROMPT+='${bold}'$'\n' # newline
PROMPT+='${userStyle}%n' # username
PROMPT+='${white} at '
PROMPT+='${hostStyle}%m' # host
PROMPT+='${white} in '
PROMPT+='${green}%1~' # working directory
PROMPT+='$(prompt_git)' # Git repository details
PROMPT+=$'\n'
PROMPT+='${white}$ ${reset}' # `$` (and reset color)

# Set the continuation prompt (PS2)
PROMPT2='${yellow}→ ${reset}'

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
