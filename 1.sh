#!/bin/bash

export CGO_ENABLED=0
export GOOS=windows
export GOARCH=arm64
go build -v -trimpath -o dist/RealiTLScanner -gcflags="all=-l=4" -ldflags="-s -w -buildid="
##
