if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


test -s ~/.useralias && . ~/.useralias
test -s ~/.usersettings && . ~/.usersettings
test -s ~/.asciidoc_snippets && . ~/.asciidoc_snippets

eval "`dircolors -b $HOME/.dir_colors`"
