declare-option -hidden bool dispatch_init
eval %sh{
    $kak_opt_dispatch_init && exit
    printf 'declare-user-mode dispatch
declare-user-mode start'
}
set-option global dispatch_init true

define-command -override -params .. -docstring %{
    Focus [<arguments]: set focus dispatch
} Focus %{
    set global makecmd "compile %arg{@}"
}

define-command -override -params .. -docstring %{
    Start [<arguments]: start interactive processes
} start %{
    eval %sh{
        if [ $# -eq 0 ]; then
        	printf 'terminal bash'
        else
        	echo "terminal ${@}"
        fi
    }
}

map global normal ` %{:enter-user-mode dispatch<ret>}
map global dispatch <ret> %{:make<ret>} -docstring 'Dispatch'
map global dispatch <backspace> %{:Focus } -docstring 'FocusDispatch'

map global normal \' %{:enter-user-mode start<ret>}
map global start <ret> %{:start<ret>} -docstring 'Start interactive shell'
map global start <space> %{:start } -docstring 'Start interactive process'
