# once
declare-option -hidden bool init_done
evaluate-commands %sh{
    $kak_opt_init_done && exit
    printf '
    add-highlighter global/ number-lines -relative
    declare-user-mode split
    '
}
eval %sh{
    $kak_opt_init_done && exit
    kak-lsp --kakoune -s $kak_session
}
eval %sh{
    $kak_opt_init_done && exit
    [[ -f ~/projects/kak-dap/rc/kak-dap.kak ]] && source ~/projects/kak-dap/rc/kak-dap.kak
}
set-option global init_done true

# https://discuss.kakoune.com/t/clipboard-integration-using-osc-52/1002/5
define-command -override -hidden clipboard-sync \
-docstring "yank selection to terminal clipboard using OSC 52" %{
    nop %sh{
        eval set -- "$kak_quoted_selections"
        copy=$1
        shift
        for sel; do
            copy=$(printf '%s\n%s' "$copy" "$sel")
        done
        encoded=$(printf %s "$copy" | base64 | tr -d '\n')

        printf "\e]52;;%s\e\\" "$encoded" >"/proc/$kak_client_pid/fd/0"
    }
}

hook global -group terminalyank RegisterModified '"' %{ nop %sh{
    encoded=$(printf %s "$kak_main_reg_dquote" | base64 | tr -d '\n')
    printf "\e]52;;%s\e\\" "$encoded" >"/proc/$kak_client_pid/fd/0"
}}

# options
colorscheme gruvbox-dark
set-option global autoreload yes

# hooks
hook global -group lsp WinSetOption filetype=(rust|python|go|javascript|typescript|c|cpp) %{
   lsp-enable-window
   lsp-enable
   lsp-auto-signature-help-enable
   hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
   hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
   hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
   hook -once -always window WinSetOption filetype=.* %{
      remove-hooks window semantic-tokens
   }
}

hook global BufCreate (.*/)?(\.kakrc\.local) %{
    set-option buffer filetype kak
}
try %{ source .kakrc.local }


# commands
define-command -override -hidden -params 1.. tmux %{
    echo %sh{
        tmux=''${kak_client_env_TMUX}
        pane=''${kak_client_env_TMUX_PANE}
        if [ -z "$tmux" ]; then
            echo "fail 'This command is only available in a tmux session'"
            exit
        fi
        eval TMUX_PANE=$pane TMUX=$tmux tmux ''${@}
    }
}

define-command -override -params 1 -docstring %{
    fd [<arguments>]: utility wrapper
} fd 'edit %arg{1}'
complete-command -menu fd shell-script-candidates "fd -t file -L"

# mappings
map global user s ':source ~/.config/kak/autoload/kakrc.kak<ret>' -docstring 'Source user config'
map global user p ':terminal kakup<ret>' -docstring 'Open new tmux tab/window with a new kakoune server/client'
map global normal <c-p> ':fd ' -docstring ''
map global insert <c-w> '<left><a-;>B<a-;>d' -docstring "Delete word before cursor"

map global normal <c-w> %{:enter-user-mode split<ret>} -docstring "Navigate splits"
map global split j %{:tmux select-pane -t "{down-of}"<ret>} -docstring "Down"
map global split k %{:tmux select-pane -t "{up-of}"<ret>} -docstring "Up"
map global split h %{:tmux select-pane -t "{left-of}"<ret>} -docstring "Left"
map global split l %{:tmux select-pane -t "{right-of}"<ret>} -docstring "Right"
map global split = %{:tmux select-layout even-vertical<ret>} -docstring "Balance"
map global split o %{:tmux kill-pane -a<ret>} -docstring "Only"
map global split t %{:tmux next-window<ret>} -docstring "Only"
map global split T %{:tmux previous-window<ret>} -docstring "Only"

map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"
map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
map global object e '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
map global object k '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'
