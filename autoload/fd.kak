define-command -override -params 1 -docstring %{
    fd [<arguments>]: utility wrapper
} fd %{ edit %arg{1} }
complete-command -menu fd shell-script-candidates "fd -t file"
