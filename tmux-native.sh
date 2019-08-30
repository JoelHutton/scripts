#!/bin/sh
tmux set prefix C-b
tmux set status-bg green
tmux set status-fg black
tmux set-environment SSH_CLIENT ""
tmux set-environment SSH_TTY ""
tmux set-environment SESSION_TYPE "local"
