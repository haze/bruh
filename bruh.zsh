# bruh theme

# setup
setopt prompt_subst
hl='%F{green}'
reset='%F{fb_default_code}'

function precmd() {
  if [ -d "$PWD/.git" ]
  then
    git_branch="$(git rev-parse --abbrev-ref HEAD) "
    git_shorthash="$hl$(git rev-parse --short HEAD)$reset "
    git_commit_age="$(bruh_lca $(date +%s) $(git show -s --format=%ct))"
    if [[ $(git diff --stat) != '' ]]; then
      git_dirty="$hl+$reset "
    else
      git_dirty=''
    fi
  else
    git_branch=''
    git_shorthash=''
    git_commit_age=''
  fi
}

PROMPT=' $(cpwd) '
RPROMPT='$git_dirty$git_branch$git_shorthash$git_commit_age'
