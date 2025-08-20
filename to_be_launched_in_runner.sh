#!/usr/bin/env bash
set -x -euo pipefail

jobs='tmate vncserver novnc localhostrun x11vnc localssh'

for job in $jobs
do
    touch ~/todo_$job
done

(
    ( (
        export name=tmate
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-window -t $name -x 512 -y 128
        [ -f ~/todo_$name ]
        tmux send -t $name -l "unset TMUX ; tmate && rm ~/todo_$name ; exit"$'\n'
        while sleep 0.1
        do
            tmux capture -pt $name | grep 'ssh session:' && break
        done
        tmux send -t $name -l 'q'
        set +x
        while sleep 0.1
        do
            ( ! [ -f ~/todo_$name ] ) && break
        done
    )&)


    ( (
        export name=vncserver
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 0.1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l "[ -f ~/todo_$name ] && "'( vncserver -alwaysshared :1 )'" && rm ~/todo_$name ; exit"$'\n'
        sleep 0.1
        cat ~/fifo_$name
    )&)

    ( (
        export name=novnc
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 0.1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l "[ -f ~/todo_$name ] && "'( ~/novnc/utils/novnc_proxy --listen 127.0.0.1:6080 --vnc 127.0.0.1:5900 )'" && rm ~/todo_$name ; exit"$'\n'
        sleep 0.1
        cat ~/fifo_$name
    )&)

    ( (
        export name=x11vnc
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 0.1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l "[ -f ~/todo_$name ] && "'( export DISPLAY=:1 && x11vnc -shared -dontdisconnect -many -listen 127.0.0.1 )'" && rm ~/todo_$name ; exit"$'\n'
        sleep 0.1
        cat ~/fifo_$name
    )&)

    ( (
        export name=localhostrun
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 0.1
        tmux send -t $name -l "script -f ~/output_$name"$'\n'
        sleep 0.1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l "[ -f ~/todo_$name ] && "'( ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -R 80:localhost:6080 nokey@localhost.run )'" && rm ~/todo_$name ; exit"$'\n'
        sleep 0.1
        ( (
            while sleep 5
            do
                if [ $(( $RANDOM % 2 )) -eq 0 ]
                then
                    if [ $(( $RANDOM % 2 )) -eq 0 ]
                    then
                        tail -n 40 ~/output_$name | sed $'s/\x1b\\[49m  \x1b\\[0m/  /g' | sed $'s/\x1b\\[7m  \x1b\\[0m/@@/g'
                    else
                        tail -n 40 ~/output_$name | sed $'s/\x1b\\[49m  \x1b\\[0m/   /g' | sed $'s/\x1b\\[7m  \x1b\\[0m/@@@/g'
                    fi
                else
                    if [ $(( $RANDOM % 2 )) -eq 0 ]
                    then
                        tail -n 40 ~/output_$name | sed $'s/\x1b\\[49m  \x1b\\[0m/@@/g' | sed $'s/\x1b\\[7m  \x1b\\[0m/  /g'
                    else
                        tail -n 40 ~/output_$name | sed $'s/\x1b\\[49m  \x1b\\[0m/@@@/g' | sed $'s/\x1b\\[7m  \x1b\\[0m/   /g'
                    fi
                fi
            done
        )&)
        cat ~/fifo_$name
    )&)

    ( (
        export name=localssh
        mkfifo ~/fifo_$name
        tmux new -d -s $name
        tmux resize-pane -t $name -x 512 -y 128
        tmux send -t $name -l "script -f ~/fifo_$name"$'\n'
        sleep 0.1
        tmux send -t $name -l "echo $name"$'\n'
        tmux send -t $name -l "[ -f ~/todo_$name ] && "'( cp /id_* ~/.ssh/ && ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -R 6080:localhost:6080 $(cat /id_*.pub | rev | awk '"'"'{print $1}'"'"' | rev | head -n 1) )'" && rm ~/todo_$name ; exit"$'\n'
        sleep 0.1
        cat ~/fifo_$name
    )&)

)|tee

for job in $jobs
do
    ! [ -f ~/todo_$job ]
done

