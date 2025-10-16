#!/bin/sh

# global variable
git config --global url."https://github.com/".insteadOf git@github.com:
ssh -T git@github.com

# project user
git config user.name havario
git config user.email "157877551+havario@users.noreply.github.com"

# REMOTE_BRANCH="$(git config --get remote.origin.url)"
# git remote set-url origin "$REMOTE_BRANCH"
