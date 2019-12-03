# bruh theme

# setup
setopt prompt_subst
hl='%F{green}'
reset='%F{fb_default_code}'

function precmd() {
  git_dirty=''
  if [ -d "$PWD/.git" ]
  then
    git_branch="$(git rev-parse --abbrev-ref HEAD) "
    git_shorthash="$hl$(git rev-parse --short HEAD)$reset "
    git_commit_age="$(bruh_lca $(date +%s) $(git show -s --format=%ct))"
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
      git_dirty="$hl+$reset "
    else
    fi
  else
    git_branch=''
    git_shorthash=''
    git_commit_age=''
  fi
}

PROMPT=' $(bruh_cpwd) '
RPROMPT='$git_dirty$git_branch$git_shorthash$git_commit_age'