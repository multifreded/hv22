#!/bin/bash

urlencode() (
    string=${*:-$(
        cat -
        printf x
    )}
    [ -n "$*" ] || string=${string%x}
    # Zero index, + 1 to start from 1 since sed starts from 1
    lines=$(($(printf %s "$string" | wc -l) + 1))
    lineno=1
    while [ $lineno -le $lines ]; do
        currline=$(printf %s "$string" | sed "${lineno}q;d")
        pos=1
        chars=$(printf %s "$currline" | wc -c)
        while [ $pos -le "$chars" ]; do
            c=$(printf %s "$currline" | cut -b$pos)
            case $c in
            [-_.~a-zA-Z0-9]) printf %c "$c" ;;
            *) printf %%%02X "'${c:-\n}'" ;;
            esac
            pos=$((pos + 1))
        done
        [ $lineno -eq $lines ] || printf %%0A
        lineno=$((lineno + 1))
    done
)

rot13() {
    echo "$1" \
    | tr 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' \
         'nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM'
}

urlencode "$(rot13 "$1")"
