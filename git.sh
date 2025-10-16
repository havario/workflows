#!/bin/sh

set -eEu

# global variable
if ! git config --global --get-regexp url | grep -Fx "url.ssh://git@ssh.github.com:443/.insteadof git@github.com:" >/dev/null 2>&1; then
    git config --global url."ssh://git@ssh.github.com:443/".insteadof git@github.com:
    ssh -T -p 443 git@ssh.github.com
fi

# set user
git config user.name havario
git config user.email "157877551+havario@users.noreply.github.com"

git remote set-url origin "$(git config --get remote.origin.url)"
