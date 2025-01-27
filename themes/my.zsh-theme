# Return status indicator
local ret_status="%(?:%{$fg_bold[green]%} :%{$fg_bold[red]%} %s)"

local ret_end_status="%(?:
%{$fg_bold[green]%} :
%{$fg_bold[red]%} %s)"


# Environment prompt:
env_prompt() {

  local js_files=$(find . -maxdepth 1 -name "*.js" -print -quit)
  
  local py_files=$(find . -maxdepth 1 -name "*.py" -print -quit)

  local java_files=$(find . -maxdepth 1 -name "*.java" -print -quit)

  local java_version=""
  if [[ -n "$java_files" ]]; then
    java_version="Java "$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
  fi

  local node_version=""
  if [[ -n "$js_files" ]]; then
    node_version=$(node -v 2>/dev/null)
  fi

  local deno_version=""
  if [[ -n "$js_files" ]]; then
    deno_version=$(deno -v 2>/dev/null)
  fi

  local python_version=""
  if [[ -n "$py_files" ]]; then
    python_version=$(python --version 2>/dev/null) || python_version=$(python3 --version 2>/dev/null)
  fi

  #local git_version=""
  #if git rev-parse --is-inside-work-tree &>/dev/null; then
  #  git_version=$(git --version | cut -d' ' -f3)
  #fi

  local env_prompt=""
  if [[ -n "$java_version" ]]; then
    env_prompt+=" %{$fg[red]%}\ue256 $java_version%{$reset_color%}"
  fi

  if [[ -n "$node_version" ]]; then
    env_prompt+=" %{$fg[green]%}\ued0d $node_version%{$reset_color%}"
  fi

  if [[ -n "$deno_version" ]]; then
    env_prompt+=" %{$fg[cyan]%}\ue7c0 $deno_version%{$reset_color%}"
  fi

  if [[ -n "$python_version" ]]; then
    env_prompt+=" %{$fg[yellow]%}\ue73c $python_version%{$reset_color%}"
  fi
  
  #if [[ -n "$git_version" ]]; then
  #  env_prompt+=" %{$fg[green]%}\ue702 $git_version%{$reset_color%}"
  #fi

  echo "$env_prompt"
}

# Get Git status
git_info() {
  local git_status=$(git status --porcelain=v2 --branch 2>/dev/null)

  if [[ -n "$git_status" ]]; then
    local branch_name=$(echo "$git_status" | grep -oE "^# branch.head [^ ]+" | cut -d' ' -f3)
    local upstream=$(echo "$git_status" | grep -oE "^# branch.upstream [^ ]+" | cut -d' ' -f3)
    local ahead_count=$(echo "$git_status" | grep -oE "^# branch.ab \+[0-9]+" | grep -oE "[0-9]+")
    local behind_count=$(echo "$git_status" | grep -oE "^# branch.ab -[0-9]+" | grep -oE "[0-9]+")
    local total_commits=$(git rev-list --all --count 2>/dev/null)
    local staged_count=$(echo "$git_status" | grep -c "^1 ")
    local unstaged_count=$(echo "$git_status" | grep -c "^2 ")
    local untracked_count=$(echo "$git_status" | grep -c "^\? ")


    local git_prompt="\ue725 $branch_name"
    

    [[ -n "$upstream" ]] && git_prompt+=" \uf09b $upstream"
    

    if [[ -n "$ahead_count" && "$ahead_count" -gt 0 ]]; then
      git_prompt+=" %{$fg[red]%}\ueb41 $ahead_count%{$reset_color%}"
    else
      git_prompt+=" %{$fg[green]%}✓%{$reset_color%}"
    fi
    
    [[ -n "$behind_count" ]] && git_prompt+=" %{$fg[yellow]%}↓$behind_count%{$reset_color%}"

    git_prompt+=" |%{$fg[cyan]%}\ue729 $total_commits%{$reset_color%}"

    [[ "$staged_count" -gt 0 ]] && git_prompt+=" | Staged: $staged_count"
    [[ "$unstaged_count" -gt 0 ]] && git_prompt+=" | Unstaged: $unstaged_count"
    [[ "$untracked_count" -gt 0 ]] && git_prompt+=" | Untracked: $untracked_count"

    echo "%{$fg_bold[blue]%} [git: $git_prompt%{$fg_bold[blue]%}]%{$reset_color%}"
  fi
}

PROMPT='${ret_status}%{$fg_bold[green]%}%{$fg[cyan]%}%c$(git_info) ${ret_end_status}%{$reset_color%} '

RPROMPT='$(env_prompt)'

ZSH_PROMPT_BASE_COLOR="%{$fg_bold[blue]%}"
ZSH_THEME_REPO_NAME_COLOR="%{$fg_bold[red]%}"
