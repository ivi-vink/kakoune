declare-option -hidden bool dispatch_init
eval %sh{
    $kak_opt_dispatch_init && exit
    printf 'declare-user-mode dispatch
declare-user-mode start'
}
set-option global dispatch_init true


hook global -group dispatch WinSetOption filetype=dispatch %{
    map window normal i %{:pane-undaemonize<ret>} -docstring "Go back to terminal mode"
    hook global -once -group dispatch FocusOut .* %{
        echo "focus out"
    }
}

define-command -hidden -override -params .. -docstring %{
    Send current pane to daemon session
} pane-undaemonize %{
    tmux swap-pane -s "kaks@%val{session}:%val{bufname}.0" -t :
    q!
}
define-command -override -params .. -docstring %{
    Focus [<arguments]: set focus dispatch
} Focus %{
    set global makecmd "compile %arg{@}"
}

define-command -override -params .. -docstring %{
    Start [<arguments]: start interactive processes
} start %{
    eval %sh{
        cmd="$*"
        if [ $# -eq 0 ]; then
        	cmd='bash'
        fi
    	if tmux has-session -t"kaks@$kak_session:dispatch://$cmd"; then
    		tmux join-pane -t"$kak_client_env_TMUX_PANE" -s"kaks@$kak_session:dispatch://$cmd".0
    	else
            	printf "terminal $cmd"
        fi
    }
}

map global normal ` %{:enter-user-mode dispatch<ret>}
map global dispatch <ret> %{:make<ret>} -docstring 'Dispatch'
map global dispatch <backspace> %{:Focus } -docstring 'FocusDispatch'

map global normal \' %{:enter-user-mode start<ret>}
map global start <ret> %{:start<ret>} -docstring 'Start interactive shell'
map global start <space> %{:start } -docstring 'Start interactive process'
