declare-option -hidden int compile_current_line 0
declare-option str compile_focus

define-command -override -params .. -docstring %{
    compile [<arguments>]: custom compile shell script
} compile %{ evaluate-commands %sh{
     output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-compile.XXXXXXXX)/fifo
     mkfifo ${output}

     args=()
     case "${@}" in
       ("") args+=($kak_opt_compile_focus) ;;
     esac

     ( compile "${args[@]}" | tr -d '\r' > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null

     printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
               edit! -fifo ${output} *compile*
               set-option buffer filetype compile
               set-option buffer compile_current_line 0
               hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${output}) } }
           }"
}}
complete-command compile shell

declare-option -hidden bool compile_mode_init
eval %sh{
    $kak_opt_compile_mode_init && exit
    printf 'declare-user-mode compile'
}
set-option global compile_mode_init true

def -override -params .. -docstring %{
    Focus [<arguments]: set focus dispatch
} Focus %{
    set global compile_focus "%arg{@}"
}

map global normal ` %{:enter-user-mode compile<ret>}
map global compile <ret> %{:compile<ret>} -docstring 'Dispatch'
map global compile <backspace> %{:Focus } -docstring 'FocusDispatch'
