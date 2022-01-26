define-command runB %{
  eval -try-client tools %{kakpipe -S -w -- sh -c "janet main.janet"}
}

define-command ideB %{
  rename-session TOMATO
  ide
}

define-command prompt-commands %{
  peneira "DO: " %{
printf "ideB
runB"
  } %{
    eval %arg{1}
  }
}

map global user j ': prompt-commands<ret>'
