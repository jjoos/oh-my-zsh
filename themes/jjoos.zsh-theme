# Change this to your own username
DEFAULT_USERNAME='jan'

# Threshold (sec) for showing cmd exec time
CMD_MAX_EXEC_TIME=5

local pwd='%~'
local return_state='%(?.%{$fg[green]%}✓%{$reset_color%}.%{$fg[red]%}✗%{$reset_color%})'
local time='%T' 
([ "$USER" != "$DEFAULT_USERNAME" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]) && local username='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%}:'

PROMPT="${return_state} "
RPROMPT="[ ${username}%{$fg[cyan]%}${pwd}%{$reset_color%} ] [ %{$fg[green]%}${time} %{$reset_color%}]"

# git prompt theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

# Displays the exec time of the last command if set threshold was exceeded
preexec() {
  cmd_timestamp=`date +%s`
}
cmd_exec_time() {
  local stop=`date +%s`
  local start=${cmd_timestamp:-$stop}
  let local elapsed=$stop-$start
  [ $elapsed -gt $CMD_MAX_EXEC_TIME ] && print -nP "${elapsed}s"
}

rbenv_version() {
  if which rbenv &> /dev/null; then
    version=$(rbenv version) 
    [[ "$version" =~ '^.*\.ruby\-version.*$' ]] && print -nP "$(echo "$version" | sed -e "s/ (set.*$//")"
  fi
}

precmd() {
  git_prompt_info=`git_prompt_info`
  cmd_exec_time=`cmd_exec_time`
  rbenv_version=`rbenv_version`

  if [[ -n "$git_prompt_info" || -n "$cmd_exec_time" || -n "$rbenv_version" ]]; then
    git_prompt_short_sha=`git_prompt_short_sha`
    git_prompt_status=`git_prompt_status`
    
    # right alligning {{{
    length=0
    #extract to function (prompt length)
    [[ -n "$git_prompt_info" ]] && (( length=${length} + ${#${git_prompt_info}}-13 ))
    [[ -n "$git_prompt_short_sha" ]] && (( length=${length} + ${#${git_prompt_short_sha}}+5 ))
    [[ -n "$git_prompt_status" ]] && (( length=${length} + ${#${git_prompt_status}}-5 ))
    [[ -n "$cmd_exec_time" ]] && (( length=${length} + ${#${cmd_exec_time}}+5 ))
    [[ -n "$rbenv_version" ]] && (( length=${length} + ${#${rbenv_version}}+5 ))
    if [[ $length -gt 0 && $COLUMNS -gt $length ]]; then
      print -nP "${(l.(($COLUMNS-$length)).. .)}"
    fi
    #}}}
    
    [[ -n "$git_prompt_info" ]] && print -nP "[ $git_prompt_info%{$reset_color%} ] "
    [[ -n "$git_prompt_short_sha" ]] && print -nP "[ %{$fg[cyan]%}$git_prompt_short_sha%{$reset_color%} ] "
    [[ -n "$git_prompt_status" ]] && print -nP "[$git_prompt_status%{$reset_color%} ] "
    [[ -n "$cmd_exec_time" ]] && print -nP "[ %{$fg[red]%}$cmd_exec_time%{$reset_color%} ] "
    [[ -n "$rbenv_version" ]] && print -nP "[ %{$fg[cyan]%}$rbenv_version%{$reset_color%} ] "
    print -P ""
  fi
  # Reset value since `preexec` isn't always triggered
  unset cmd_timestamp
}
