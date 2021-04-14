# bruh theme

# setup
setopt prompt_subst
hl='%F{green}'
reset='%F{fb_default_code}'

function preexec() {
  before=$EPOCHREALTIME
}

function precmd() {
  git_commit_age=''
  if [ -z "${before}" ]; then
    elapsed=''
  else
    after=$EPOCHREALTIME
    raw_elapsed=$(echo "$after-$before" | bc)
    elapsed="$hl$(bruh tf $raw_elapsed)$reset "
    before=''
  fi
  git_dirty=''
  git_top_level="$(git rev-parse --show-toplevel -q 2>/dev/null)"
  if [ $? -eq 0 ]
  then
    git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null) "
    git_shorthash="$hl$(git rev-parse --short HEAD 2>/dev/null)$reset "
    if [ -d "$PWD/.git" ]; then
      git_raw_last_commit_age="$(git show -s --format=%ct 2>/dev/null)"
      if [ $? -eq 0 ]; then
        git_commit_age="$(bruh lca $(date +%s) $git_raw_last_commit_age)"
      fi
    else
    fi

    $(git diff-index --quiet HEAD -- 2>/dev/null)
    do_we_have_changes=$?
    if [ $do_we_have_changes -ne 0 ]; then
      git_dirty="$hl+$reset "
    fi
  else
    git_branch=''
    git_shorthash=''
    git_commit_age=''
  fi
}

PROMPT=' $elapsed$(bruh cwd) '
RPROMPT='$git_dirty$git_branch$git_shorthash$git_commit_age'
