declare-option -hidden bool dispatch_init
eval %sh{
    $kak_opt_dispatch_init && exit
    printf 'declare-user-mode dispatch
declare-user-mode start'
}
set-option global dispatch_init true


hook global -group dispatch WinSetOption filetype=dispatch %{
    map window normal i %{:pane-insertmode<ret>} -docstring "Go back to terminal mode"
    hook global -once -group dispatch FocusOut .* %{
        echo "focus out"
    }
}

hook global -group dispatch KakEnd .* %{
    nop %sh{
        tmux kill-window -a
    }
}

define-command -hidden -override -params .. -docstring %{
    Get current dispatch pane from daemon session
} pane-insertmode %{
    tmux swap-pane -s "'kaks@%val{session}:%val{bufname}.0'" -t "%val{client_env_TMUX_PANE}"
    q!
}

define-command -hidden -override -params 1.. -docstring %{
    Make Dispatch pane to daemon session
} pane-undaemonize %{
    tmux join-pane -t "%val{client_env_TMUX_PANE}" -s "'kaks@%val{session}:dispatch://%arg{@}.0'"
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
		printf "pane-undaemonize '$cmd'"
    	else
            	printf "terminal $cmd"
        fi
    }
}
complete-command start shell

map global normal ` %{:enter-user-mode dispatch<ret>}
map global dispatch <ret> %{:make<ret>} -docstring 'Dispatch'
map global dispatch <backspace> %{:Focus } -docstring 'FocusDispatch'

map global normal \' %{:enter-user-mode start<ret>}
map global start <ret> %{:start<ret>} -docstring 'Start interactive shell'
map global start <space> %{:start } -docstring 'Start interactive process'
