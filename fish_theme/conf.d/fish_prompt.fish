function fish_prompt
  set -l last_status $status

  echo -en " "

  if test -n "$SSH_CONNECTION"
    echo -en (whoami)"@"(hostname)" "
  end

  if [ $last_status != 0 ]
      set_color red
      echo -en "$last_status "
      set_color normal
  end

  if test -n "$duration"
    and test $duration -ne 0
    set_color --bold green
    echo -en (bruh tf $duration)" "
    set_color normal
  end

  echo -en

  echo -en (bruh cwd)" "
end

function fish_command_timer_postexec -e fish_postexec
  set -g duration (math -s3 "$CMD_DURATION/1000")
end

function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color --bold blue
      echo -ne ' n'
      set_color normal
    case visual
      set_color --bold purple
      echo -ne ' v'
      set_color normal
  end
end
