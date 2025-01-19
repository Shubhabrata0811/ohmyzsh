# Return status indicator
local ret_status="%(?:%{$fg_bold[green]%} :%{$fg_bold[red]%} %s)"

# Environment prompt:
env_prompt() {
  # Check if any .js files exist for Node.js and Deno.js
  local js_files=$(find . -maxdepth 1 -name "*.js" -print -quit)
  
  # Check if any .py files exist for Python
  local py_files=$(find . -maxdepth 1 -name "*.py" -print -quit)

  # Get current Node.js and Deno.js version if .js files exist
  local node_version=""
  if [[ -n "$js_files" ]]; then
    node_version=$(node -v 2>/dev/null)
  fi

  local deno_version=""
  if [[ -n "$js_files" ]]; then
    deno_version=$(deno -v 2>/dev/null)
  fi

  # Get current Python version if .py files exist
  local python_version=""
  if [[ -n "$py_files" ]]; then
    python_version=$(python --version 2>/dev/null) || python_version=$(python3 --version 2>/dev/null)
  fi
  

  # Get Git version if inside a Git repository
  #local git_version=""
  #if git rev-parse --is-inside-work-tree &>/dev/null; then
  #  git_version=$(git --version | cut -d' ' -f3)
  #fi

  # Build environment prompt
  local env_prompt=""
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


# Enhanced Git prompt
git_info() {
  # Get Git status
  local git_status=$(git status --porcelain=v2 --branch 2>/dev/null)

  if [[ -n "$git_status" ]]; then
    local branch_name=$(echo "$git_status" | grep -oE "^# branch.head [^ ]+" | cut -d' ' -f3)
    local upstream=$(echo "$git_status" | grep -oE "^# branch.upstream [^ ]+" | cut -d' ' -f3)
    local ahead_count=$(echo "$git_status" | grep -oE "^# branch.ab \+[0-9]+" | grep -oE "[0-9]+")
    local behind_count=$(echo "$git_status" | grep -oE "^# branch.ab -[0-9]+" | grep -oE "[0-9]+")

    # Get the total number of commits
    local total_commits=$(git rev-list --all --count 2>/dev/null)

    local staged_count=$(echo "$git_status" | grep -c "^1 ")
    local unstaged_count=$(echo "$git_status" | grep -c "^2 ")
    local untracked_count=$(echo "$git_status" | grep -c "^\? ")

    # Build git prompt
    local git_prompt="\ue725 $branch_name"
    
    # Upstream information
    [[ -n "$upstream" ]] && git_prompt+=" \uf09b $upstream"
    
    # Ahead/behind counts with clean/dirty state
    if [[ -n "$ahead_count" && "$ahead_count" -gt 0 ]]; then
      git_prompt+=" %{$fg[red]%}\ueb41 $ahead_count%{$reset_color%}"
    else
      git_prompt+=" %{$fg[green]%}✓%{$reset_color%}"
    fi
    
    [[ -n "$behind_count" ]] && git_prompt+=" %{$fg[yellow]%}↓$behind_count%{$reset_color%}"

    # Total commits
    git_prompt+=" |%{$fg[cyan]%}\ue729 $total_commits%{$reset_color%}"

    # Staged, unstaged, and untracked counts
    [[ "$staged_count" -gt 0 ]] && git_prompt+=" | Staged: $staged_count"
    [[ "$unstaged_count" -gt 0 ]] && git_prompt+=" | Unstaged: $unstaged_count"
    [[ "$untracked_count" -gt 0 ]] && git_prompt+=" | Untracked: $untracked_count"

    echo "%{$fg_bold[blue]%}[git: $git_prompt%{$fg_bold[blue]%}]%{$reset_color%}"
  fi
}

# SVN prompt for completeness
svn_info() {
  local svn_status=$(svn status 2>/dev/null)
  if [[ -n "$svn_status" ]]; then
    local dirty=$(echo "$svn_status" | grep -c "^[AMDR]")
    echo "%{$fg_bold[red]%}[svn: $dirty changes]%{$reset_color%}"
  fi
}

# Main prompt configuration
PROMPT='${ret_status}%{$fg_bold[green]%}%{$fg[cyan]%}%c $(git_info) $(svn_info) $(env_prompt)%{$reset_color%} '


# Base and repo name colors
ZSH_PROMPT_BASE_COLOR="%{$fg_bold[blue]%}"
ZSH_THEME_REPO_NAME_COLOR="%{$fg_bold[red]%}"
