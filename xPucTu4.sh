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
#    cat $TFN | grep -E "^(\s{3,})Exp\S* - [0-9.]{3,}$" | cut -f2 -d "-" | tr -d " " > /factorio/lkv
    echo $(cat $TFN | grep '<!-- experimental -->' -A 10 | grep -E "\"/get-download/[0-9.]{5,}/headless" | cut -f2 -d '=' | tr -d '"' | cut -f3 -d '/') > /factorio/lkv
    rm $TFN
    echo "Version check completed"
}

checkNewVersion
