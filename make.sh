#!/usr/bin/env bash

set -e

ROOT="$( cd $( dirname $0 ) && pwd -P )"

export GOPATH0="$ROOT/.gopath" 
if [ -n "$GOPATH" ];then
    # 若有預設的 GOPATH，就優先使用預設的 GOPATH 為主
    export GOPATH="$GOPATH:$GOPATH0" 
else
    export GOPATH="$GOPATH0" 
fi
echo "GOPATH: $GOPATH"

export TMPDIR="$ROOT/.tmp" 
export CGO_ENABLED="0" # 有效減少 dependencies
export BuildTags='exclude_graphdriver_devicemapper exclude_graphdriver_aufs exclude_graphdriver_btrfs' # 有效減少 dependencies

H4DIR="$GOPATH0/src/github.com/hacking-thursday"
SYSDDIR="$H4DIR/sysd"

function replace_sysd_dir(){
    pushd "$H4DIR" > /dev/null
        if [ -d "./sysd" ]; then
            rm -rf "./sysd"
            ln -s ../../../../ ./sysd
        fi
    popd > /dev/null
}

if [ ! -d "$TMPDIR" ]; then mkdir -p "$TMPDIR" ; fi
if [ ! -d "$SYSDDIR" ]; then mkdir -p "$SYSDDIR" ; fi

if [ -L "$SYSDDIR" ];then 
    echo -n -e "[Symbolic link]\t"; 
    MESSAGE=" => $( cd $SYSDDIR && pwd -P )";
else
    echo -n -e "[Mirror copy]\t"; 
fi
echo "$SYSDDIR $MESSAGE"

if [ -d "$SYSDDIR" -a ! -L "$SYSDDIR" ] ;then
    cp -r "$ROOT"/* "$SYSDDIR/"
    pushd "$SYSDDIR"
        TARGET_PATH="${GOPATH0}/src/github.com/docker/libcontainer/cgroups/systemd/apply_systemd.go"
        grep -e 'theConn\.StartTransientUnit.*, nil);' "$TARGET_PATH"
        if [ $? -eq 1 -a -f "$TARGET_PATH" ]; then
            cp -v "$ROOT/misc/apply_systemd.go" "$TARGET_PATH"
        fi
        go get -v -t -tags "$BuildTags" ./sysd
        if [ $? -eq 0 ];then
            replace_sysd_dir
        fi
    popd
fi

if [ -L "$SYSDDIR" ];then
    # build first
    pushd "$SYSDDIR/sysd"
        go build -v -tags "$BuildTags"
        if [ $? -eq 0 ];then
            # test later
            pushd "$SYSDDIR"
                go test -v -tags "$BuildTags" ./...
            popd
        fi
    popd
fi
