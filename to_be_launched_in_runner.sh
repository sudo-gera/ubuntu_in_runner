#!/usr/bin/env bash
set -x -eu

jobs='tmate vncserver novnc localhostrun x11vnc localssh squid runnerconsole'

for job in $jobs
do
    touch ~/todo_$job
done

(
    ( (
        export name=tmate
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 1
        tmux send -t $name -l "script -f ~/output_$name"$'\n'
        sleep 1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l "[ -f ~/todo_$name ] && "'( while sleep 1 ; do unset TMUX && tmate -F ; done )'" && rm ~/todo_$name ; exit"$'\n'
        ( (
            set +x
            while sleep 2
            do
                cat ~/output_$name | grep 'ssh session:' | tr -d '\r' | tail -n 1
            done
        )&)
        cat ~/fifo_$name
    )&)

    ( (
        export name=vncserver
        rm ~/todo_$name
        vncserver -alwaysshared :1
    )&)

    ( (
        export name=novnc
        rm ~/todo_$name
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l '( while sleep 1 ; do ~/novnc/utils/novnc_proxy --listen 127.0.0.1:6080 --vnc 127.0.0.1:5900 ; done ) ; exit'$'\n'
        cat ~/fifo_$name
    )&)

    ( (
        export name=x11vnc
        rm ~/todo_$name
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l '( while sleep 1 ; do export DISPLAY=:1 && x11vnc -shared -dontdisconnect -many -listen 127.0.0.1 ; done ) ; exit'$'\n'
        cat ~/fifo_$name
    )&)

    ( (
        export name=localhostrun
        rm ~/todo_$name
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 1
        tmux send -t $name -l "script -f ~/output_$name"$'\n'
        sleep 1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l '( while sleep 1 ; do ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -R 80:localhost:6080 nokey@localhost.run ; done ) ; exit'$'\n'
        ( (
            set +x
            while sleep 2
            do
                cat ~/output_$name | tr -d '\r' | grep 'lhr.life' | head -n 1
            done
        )&)
        cat ~/fifo_$name
    )&)

    ( (
        export name=localssh
        rm ~/todo_$name
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l '( cp /id_* ~/.ssh/ && ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -R 6080:localhost:6080 $(cat /id_*.pub | rev | awk '"'"'{print $1}'"'"' | rev | head -n 1) ) ; exit'$'\n'
        cat ~/fifo_$name
    )&)

    ( (
        export name=squid
        rm ~/todo_$name
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l '( while sleep 1 ; do squid -N ; done ) ; exit'$'\n'
        cat ~/fifo_$name
    )&)

    ( (
        export name=runnerconsole
        rm ~/todo_$name
        set +x
        while sleep 1
        do
            cat ~/runner_console > ~/output_$name
            printf '\n\n\n'
            cat ~/output_$name
            printf '\n\n\n'
        done
    )&)

)|tee
