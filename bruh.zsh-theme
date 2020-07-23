# bruh theme

# setup
setopt prompt_subst
hl='%F{green}'
reset='%F{fb_default_code}'

function preexec() {
  before=$EPOCHREALTIME
}

function precmd() {
  if [ -z "${before}" ]; then
    elapsed=''
  else
    after=$EPOCHREALTIME
    raw_elapsed=$(echo "$after-$before" | bc)
    elapsed="$hl$(bruh_tf $raw_elapsed)$reset "
    before=''
  fi
  git_dirty=''
  git_top_level="$(git rev-parse --show-toplevel -q 2>/dev/null)"
  if [ $? -eq 0 ]
  then
    git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null) "
    if [[ $(git rev-list --all --abbrev=0 --abbrev-commit | wc -l) != "       0" ]]; then
      git_shorthash="$hl$(git rev-parse --short HEAD 2>/dev/null)$reset "
    else
      git_shorthash=''
      git_commit_age=''
    fi
    if [ -d "$PWD/.git" ]; then
      git_commit_age="$(bruh_lca $(date +%s) $(git show -s --format=%ct))"
    else
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

PROMPT=' $elapsed$(bruh_cpwd) '
RPROMPT='$git_dirty$git_branch$git_shorthash$git_commit_age'
