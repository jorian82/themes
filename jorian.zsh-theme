function prompt_char {
	if [ $UID -eq 0 ]; then echo "#"; else echo ">"; fi
}

function my_git_prompt() {
  tester=$(git rev-parse --git-dir 2> /dev/null) || return
  
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""

  # is branch ahead?
  if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi

  # is branch behind?
  if $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi

  # is anything unstaged?
  if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi

  # is anything untracked?
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi

  # is anything unmerged?
  if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi

  if [[ -n $STATUS ]]; then
    STATUS="$ZSH_THEME_SVN_PROMPT_DIRTY $STATUS"
  else
  	STATUS="$ZSH_THEME_SVN_PROMPT_CLEAN"
  fi

  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(my_current_branch)$STATUS"
}

function my_current_branch() {
   echo $(current_branch || echo "(no branch)")
#	echo $(git_prompt_info || echo "(no branch)")
}

function ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[red]%}(ssh) "
  fi
}

function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo ${SHORT_HOST:-$HOST}
}

function in_svn() {
  svn info >/dev/null 2>&1
}

function svn_dirty_choose_pwd () {
  if in_svn; then
    if svn status "$PWD" 2> /dev/null | command grep -Eq '^\s*[ACDIM!?L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

function svn_repo_info() {
	if in_svn; then
		STATUS="";
		svn_status="$(svn status 2> /dev/null)";
		if [[ $(svn_dirty_choose_pwd 1 0) -eq 1 ]]; then
			#STATUS=$ZSH_THEME_SVN_PROMPT_DIRTY
			if command grep -E '^\s*[CI!L]' &> /dev/null <<< $svn_status; 	then STATUS=$STATUS""$ZSH_THEME_SVN_PROMPT_DIRTY" ";		fi
			if command grep -E '^\s*A' &> /dev/null <<< $svn_status; 		then STATUS=$STATUS""$ZSH_THEME_SVN_PROMPT_ADDITIONS; 		fi
			if command grep -E '^\s*D' &> /dev/null <<< $svn_status; 		then STATUS=$STATUS""$ZSH_THEME_SVN_PROMPT_DELETIONS; 		fi
			if command grep -E '^\s*M' &> /dev/null <<< $svn_status; 		then STATUS=$STATUS""$ZSH_THEME_SVN_PROMPT_MODIFICATIONS;	fi
			if command grep -E '^\s*[R~]' &> /dev/null <<< $svn_status; 	then STATUS=$STATUS""$ZSH_THEME_SVN_PROMPT_REPLACEMENTS; 	fi
			if command grep -E '^\s*\?' &> /dev/null <<< $svn_status; 		then STATUS=$STATUS""$ZSH_THEME_SVN_PROMPT_UNTRACKED; 		fi
		else
			STATUS=$STATUS" "$ZSH_THEME_SVN_PROMPT_CLEAN
		fi
		
		echo -n $ZSH_THEME_GIT_PROMPT_PREFIX$(svn_current_branch_name)" %{$FG[239]%}"$(svn_current_revision)" "$STATUS
	fi
}

# local git_info='$(git_prompt_info)'
# local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"

#PROMPT='%{$FG[226]%}%n%{$reset_color%} %{$FG[239]%}at%{$reset_color%} %{$FG[040]%}$(box_name)%{$reset_color%} %{$fg_bold[blue]%}%~%{$reset_color%} $(my_git_prompt) $(svn_repo_info) %{$reset_color%}  [%*]
PROMPT='╭─%{$FG[040]%}%n@%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$reset_color%} $(my_git_prompt) $(svn_repo_info) %{$reset_color%}
╰─$(prompt_char)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[239]%}on%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[040]%}✔"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[magenta]%}↑"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[green]%}↓"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}●"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}●"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}✕"

ZSH_THEME_SVN_PROMPT_PREFIX="%{$fg_bold[blue]%}rev:(%{$reset_color%}"
ZSH_THEME_SVN_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_SVN_PROMPT_CLEAN="%{$fg_bold[blue]%} %{$FG[040]%}✔"
ZSH_THEME_SVN_PROMPT_DIRTY="%{$fg[red]%}✗"
#ZSH_THEME_SVN_PROMPT_ADDITIONS="%{$fg_bold[blue]%}+"
#ZSH_THEME_SVN_PROMPT_DELETIONS="%{$fg_bold[red]%}-"
#ZSH_THEME_SVN_PROMPT_MODIFICATIONS="%{$FG[226]%}✎"
#ZSH_THEME_SVN_PROMPT_REPLACEMENTS="%{$fg_bold[magenta]%}~"
#ZSH_THEME_SVN_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}●"
ZSH_THEME_SVN_PROMPT_ADDITIONS="%{$fg_bold[blue]%}●"
ZSH_THEME_SVN_PROMPT_DELETIONS="%{$fg_bold[red]%}●"
ZSH_THEME_SVN_PROMPT_MODIFICATIONS="%{$FG[226]%}●"
ZSH_THEME_SVN_PROMPT_REPLACEMENTS="%{$fg_bold[magenta]%}●"
ZSH_THEME_SVN_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}●"
