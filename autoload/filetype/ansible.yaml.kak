hook global WinSetOption filetype=ansible\.yaml %{
    set-option buffer makecmd 'ansible-lint --profile production --write=all -f pep8 -qq --nocolor'
    hook window ModeChange pop:insert:.* -group yaml-trim-indent yaml-trim-indent
    hook window InsertChar \n -group yaml-insert yaml-insert-on-new-line
    hook window InsertChar \n -group yaml-indent yaml-indent-on-new-line
    add-highlighter window/ansible.yaml ref yaml
}


hook global WinSetOption filetype=yaml %{
    evaluate-commands %sh{
        git_root="$(git rev-parse --show-toplevel)"
        fd '^playbook|^group_vars|^roles|^ansible|^collections' "$git_root" --has-results && {
        	printf %s 'set-option buffer filetype ansible.yaml'
        }
    }
}
