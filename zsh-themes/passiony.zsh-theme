# ZSH theme based on the fishy theme, that ships with oh-my-zsh.
# Differs in two aspects:
# 1. full path is shown instead of abbreviated directories
# 2. user@machine is not shown for localhost, only in ssh sessions and inside
# docker containers

local user_color='green'; [ $UID -eq 0 ] && user_color='red'
local ret_status="%(?:%{$fg_bold[255]%}%(!.#.>) :%{$fg_bold[red]%}%(!.#.>) %s)"

# command
function update_command_status() {
    local arrow="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";
    if $1;
    then
        arrow="%F{202}❱%F{255}❱%{$fg_bold[cyan]%}❱";
    else
        arrow="%{$fg_bold[red]%}❱❱❱";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}
update_command_status true;

function command_status() {
    echo "${COMMAND_STATUS}"
}

# command execute after
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
precmd() {
    # last_cmd
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi

    # update_command_status
    update_command_status $last_cmd_result;
}

if [[ -n "$SSH_CLIENT" ]]; then
  PROMPT='%{$fg[cyan]%}%n@%m%{$reset_color%} %{$fg[$user_color]%}%~%{$reset_color%}$(command_status) '
else
  PROMPT='%{$fg[$user_color]%}%~%{$reset_color%}$(command_status) '
fi 
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'

local return_status="%{$fg_bold[red]%}%(?..%?)%{$reset_color%}"
RPROMPT='${return_status}$(git_prompt_info)$(git_prompt_status)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

ls_cmd=ls
if [[ "$OSTYPE" == "darwin"* ]]; then
    # ls for macOS
    ls_cmd=gls
    {
        gls > /dev/null
    } || {
        echo "\n$fg_bold[yellow]passiony.zsh-theme depends on cmd [gls] to get ls colors$reset_color"
        echo "$fg_bold[yellow][gls] is not installed by default in macOS$reset_color"
        echo "$fg_bold[yellow]to get [gls] by running:$reset_color"
        echo "$fg_bold[green]brew install coreutils;$reset_color";
        echo "$fg_bold[yellow]\nREF: https://github.com/tengattack/dotfiles/blob/master/zsh-themes\n$reset_color"
    }
fi
# * LS_COLORS
typeset -TUg LS_COLORS ls_colors

ls_colors=(
  # Standard Descriptors.
  'no=00'                 # Normal
  'fi=00'                 # Files
  'di=01;38;05;63'        # Directories
  'ln=04;38;05;44'        # Links
  'pi=38;05;88'           # Named Pipes
  'so=38;05;252'          # Sockets
  'bd=38;05;237'          # Block Devices
  'cd=38;05;243'          # Character Devices
  'or=01;38;05;196'       # ???
  'mi=01;05;38;05;196'    # Missing Files
  'ex=03;38;05;46'        # Executables

  # Files, by extension.

  # Documents
  '*.csv=38;05;208'
  '*.pdf=38;05;208'
  '*.doc=38;05;208'
  '*.docx=38;05;208'
  '*.xls=38;05;208'
  '*.xlsx=38;05;208'

  # Images
  '*.bmp=38;05;51'
  '*.gif=38;05;51'
  '*.jpg=38;05;51'
  '*.png=38;05;51'
  '*.psd=38;05;51'
  '*.svg=38;05;51'
  '*.tif=38;05;51'
  '*.xbm=38;05;51'
  '*.xpm=38;05;51'

  # Audio
  '*.flac=38;05;141'
  '*.m4a=38;05;141'
  '*.mp3=38;05;141'
  '*.ogg=38;05;141'
  '*.wav=38;05;141'
  '*.wma=38;05;141'

  # Video
  '*.avi=38;05;61'
  '*.mkv=38;05;61'
  '*.divx=38;05;61'
  '*.mp4=38;05;61'
  '*.xvid=38;05;61'

  # Archives
  '*.7z=38;05;162'
  '*.Z=38;05;162'
  '*.ace=38;05;162'
  '*.arj=38;05;162'
  '*.bz2=38;05;162'
  '*.bz=38;05;162'
  '*.cpio=38;05;162'
  '*.deb=38;05;162'
  '*.gz=38;05;162'
  '*.lzh=38;05;162'
  '*.rar=38;05;162'
  '*.rpm=38;05;162'
  '*.tar=38;05;162'
  '*.taz=38;05;162'
  '*.tgz=38;05;162'
  '*.tz=38;05;162'
  '*.xz=38;05;162'
  '*.z=38;05;162'
  '*.zip=38;05;162'

  # Secrets
  '*.pem=38;05;196'
)

export LS_COLORS

# * Aliases
alias ls="$ls_cmd --color"

zstyle ':completion:*' list-colors "${LS_COLORS}"
