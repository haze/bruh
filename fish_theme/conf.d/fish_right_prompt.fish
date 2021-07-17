function fish_right_prompt
  show_git_info
end

function show_dirty_sign
  set -l have_changes (git diff-index --quiet HEAD -- 2>/dev/null)
  if [ $status -ne 0 ]
    set_color green
    echo -ne '+ '
    set_color normal
  end
end

function show_branch_name
  set -l branch_name (git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if test -n $branch_name
    echo -ne $branch_name" "
  end
end

function show_hash
  set -l hash (git rev-parse --short HEAD 2>/dev/null)
  if test -n $hash
    set_color green
    echo -ne $hash" "
    set_color normal
  end
end

function show_last_commit_age
  set -l last_commit_age (git show -s --format=%ct 2>/dev/null)
  if test -n $last_commit_age
    echo -ne (bruh lca (date +%s) $last_commit_age)" "
  end
end

function show_git_info 
  set -l git_root (git rev-parse --show-toplevel -q 2>/dev/null)
  if [ $status -eq 0 ]
    show_dirty_sign
    show_branch_name
    show_hash
    show_last_commit_age
  end
end
