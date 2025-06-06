#!/bin/bash
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# SPDX-License-Identifier: GPL-2.0

set -e

REPOSITORY="$(pwd | awk -F'/' '{print $NF}')"
CODE_PLATFORM="$(pwd | awk -F'/' '{print $(NF-1)}')"

case "$CODE_PLATFORM" in
    github*) WORK_PLATFORM="github" ;;
    gitlab*) WORK_PLATFORM="gitlab" ;;
    *) echo "Error: Unknown platform." && exit 1 ;;
esac

read -rep "Please enter user: " USER
case "$USER" in
    honeok)
        git config user.name "$USER"
        git config user.email "100125733+honeok@users.noreply.github.com"
        git remote set-url origin "git@${WORK_PLATFORM}-${USER}:${USER}/${REPOSITORY}.git"
        echo "----------"
        git config --get user.name
        git config --get user.email
    ;;
    havario)
        git config user.name "$USER"
        git config user.email "157877551+havario@users.noreply.github.com"
        git remote set-url origin "git@${WORK_PLATFORM}-${USER}:${USER}/${REPOSITORY}.git"
        echo "----------"
        git config --get user.name
        git config --get user.email
    ;;
    *)
        echo "Error: Unknown User" && exit 1
    ;;
esac