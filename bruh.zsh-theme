# bruh theme

# setup
setopt prompt_subst
hl='%F{green}'
reset='%F{fb_default_code}'

function precmd() {
  git_dirty=''
  if [ -d "$PWD/.git" ]
  then
    git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null) "
    if [[ $(git rev-list --all --abbrev=0 --abbrev-commit | wc -l) != "       0" ]]; then
      git_shorthash="$hl$(git rev-parse --short HEAD 2>/dev/null)$reset "
      git_commit_age="$(bruh_lca $(date +%s) $(git show -s --format=%ct))"
    else
      git_shorthash=''
      git_commit_age=''
    fi
    if [[ $(git status --short) != "" ]]; then
      git_dirty="$hl+$reset "
    fi
  else
    git_branch=''
    git_shorthash=''
    git_commit_age=''
  fi
}

PROMPT=' $(bruh_cpwd) '
RPROMPT='$git_dirty$git_branch$git_shorthash$git_commit_age'
