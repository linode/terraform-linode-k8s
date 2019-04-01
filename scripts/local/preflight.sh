#!/bin/bash
set -e

function assertInstalled() {
    for var in "$@"; do
        if ! which $var &> /dev/null; then
            echo "$var not found"
            exit 1
        fi
    done
}

assertInstalled ssh scp sed kubectl python
