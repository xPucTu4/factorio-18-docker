#!/bin/bash

function getRandomString()
{
    NUMCHARS=16 # default
    RegX='^\-?[0-9]+$'
    if [[ -n "$1" ]] && [[ "$1" =~ $RegX ]]
    then
	NUMCHARS=$1
	if [[ $1 -le 0 ]]; then NUMCHARS=1; fi
	if [[ $1 -gt 512 ]]; then NUMCHARS=512; fi # max 512 is sane
    fi
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $NUMCHARS | head -n 1
}


function checkNewVersion()
{
    TFN=$(mktemp)
    wget -O $TFN -o /dev/null "https://factorio.com/download"
    echo $(cat $TFN | grep 'href="/get' | grep headless | grep linux | cut -f3 -d '/') > /factorio/lkv
    rm $TFN
    echo "Version check completed"
}

checkNewVersion
