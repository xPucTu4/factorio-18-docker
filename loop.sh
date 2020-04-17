#!/bin/bash


# Below the variable $uin is short for User Input

autotimer=30
binpath="/factorio/factorio/bin/x64/factorio"
currentversion=0
$lmn=""
function updatelmn()
{
    if [ -f "/factorio/lmn" ]
    then
        lmn=`cat /factorio/lmn`
    fi
}



function getMyVersion()
{
    echo -e "\n\n\n"
    if [ ! -f $binpath ]
    then
	echo "We do not have factorio downloaded."
    else
	currentversion=`/factorio/factorio/bin/x64/factorio --version | grep output | cut -f2 -d ":"|cut -f1 -d "-" | tr -d " "`
	echo "Our version: $currentversion"
    fi

    if [ -f "/factorio/lkv" ]
    then
	echo "Last known version is: "`cat /factorio/lkv`
    fi
    if [ -f "/factorio/lmn" ]
    then
	updatelmn
	echo "Your last map name is: $lmn "
    else
	echo "You do not have any maps."
	echo "To start the server you should first create a new map with option 4."
    fi
    echo -e "\n\n\n"
}

function autostart()
{
    echo "The server will be started in $autotimer seconds."
    let autotimer="$autotimer - 1"
    if [ $autotimer -le 0 ]
    then
	autotimer=30
	startserver
    fi
}
function showHelp()
{
    echo "You can chooose from:"
    echo "1 - Start the server"
    echo "2 - Check for new version"
    echo "3 - Download latest (known) version"
    echo "4 - Create new map with name format Year-Month-Day-Hour-Minute-Seconds-RANDOM_STRING"
    echo "5 - Edit config files"
    echo "0 - Quit (exit the container)"
}

function persistConfig()
{
    for f in map-gen-settings map-settings server-settings server-whitelist
    do
	if [ ! -f "/factorio/data/$f.json" ]
	then
	    cp "/factorio/factorio/data/$f.example.json" "/factorio/conf/$f.json"
	fi
	cp "/factorio/conf/$f.json" "/factorio/factorio/data/"
    done
}


showHelp
while true
do
    updatelmn
    read -t 1 -n1 -s uin
    if [ ${#uin} -gt 0 ]
    then
	if [ "$uin" == "1" ]
	then
	    if [ "$lmn" == "" ]
	    then
		echo "Please create new map name first."
		sleep 3
	    else
		echo "Start the server"
		if [ ! -f $binpath ]
		then
		    echo "Cannot start. Server is not downloaded."
		    sleep 5
		else
		    if [ ! -f "/factorio/maps/$lmn/map.zip" ]
		    then
			echo "We should create the map first"
			$binpath --create "/factorio/maps/$lmn/map" --mod-directory /factorio/mods/
			echo "Created new map"
			sleep 2
		    fi
		    echo "Using map name '$lmn'"
		    $binpath --start-server "/factorio/maps/$lmn/map" --mod-directory /factorio/mods/
		fi
	    fi
    	elif [ "$uin" == "2" ]
	then
	    TFN="/tmp/factorio-"`date +"%s%s%s"`-`dd if=/dev/urandom status=none count=$((1024*4)) | md5sum | cut -f1 -d " "`-`date +"%s-%s"`
	    wget -O $TFN -o /dev/null "https://factorio.com/download-headless/experimental"
	    cat $TFN | grep " (64 bit" | head -n1 | cut -f3 -d "/" > /factorio/lkv
	    rm $TFN
	elif [ "$uin" == "3" ]
	then
	    if [ ! -f "/factorio/lkv" ]
	    then
		echo "Please check for the latest version first"
		sleep 5
	    else
		TFN="/tmp/factorio-"`date +"%s"`-`dd if=/dev/urandom status=none count=$((1024*8)) | md5sum | cut -f1 -d " "`-`date +"%s"`".tar.gz"
		wget -O $TFN "https://factorio.com/get-download/"`cat /factorio/lkv`"/headless/linux64"
		cd /tmp
		rm -fr factorio
		tar xfv $TFN
		mv /tmp/factorio/ "/factorio/"`cat /factorio/lkv`
		cd /factorio
		rm -fr factorio
		ln -s /factorio/`cat /factorio/lkv` /factorio/factorio
		persistConfig
	    fi
	elif [ "$uin" == "4" ]
	then
	    echo "Creating new map"
	    mapName=`date +"%Y-%m-%d-%H-%M-%S"`-`dd if=/dev/urandom status=none count=$((1024*16)) | sha256sum | cut -f1 -d " "`
	    echo "$mapName" > /factorio/lmn
	elif [ "$uin" == "5" ]
	then
	    mc /factorio/conf/
	elif [ "$uin" == "0" ] || [ "$uin" == "q" ]
	then
	    clear
	    echo "Exiting. BB."
	    sleep 0.5
	    exit
	fi
    else
	clear
	#autostart
	showHelp
	getMyVersion
    fi
done