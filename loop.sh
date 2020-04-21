#!/bin/bash

clear
. xPucTu4.sh

# Below the variable $uin is short for User Input

autotimer=30
binpath="/factorio/factorio/bin/x64/factorio"
cfgdir="/factorio/conf/"
currentversion=0
lmn="" # last map name
defaultSleep=1.5

function mainLoop()
{
    clear
    #autostart
    showHelp
    showMyVersion
    showContainerVersion
}


moreopts="--map-gen-settings ${cfgdir}map-gen-settings.json --map-settings ${cfgdir}map-settings.json --server-settings ${cfgdir}server-settings.json"
function updatelmn()
{
    if [ -f "/factorio/lmn" ]
    then
        lmn=`cat /factorio/lmn`
    fi
}


function showContainerVersion()
{
    # The 0 is hardcoded because this is too early version
    echo -e "\nContainer version is: 0."$CONTAINER_VERSION"\n\n"
}

function showMyVersion()
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
	echo -n "Last known version is: "`cat /factorio/lkv`
	echo " (Last checked: "`stat -c %y /factorio/lkv`")"
    fi
    if [ -f "/factorio/lmn" ]
    then
	updatelmn
	echo "Your last map name is: $lmn "
    else
	echo "You do not have any maps."
	echo "To start the server you should first create a new map with option 4."
    fi
    echo -e "\n"
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
	if [ ! -f "/factorio/conf/$f.json" ]
	then
	    echo "Copying conf example: $f"
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
		sleep $defaultSleep
	    else
		echo "Start the server"
		if [ ! -f $binpath ]
		then
		    echo "Cannot start. Server is not downloaded."
		    sleep $defaultSleep
		else
		    if [ ! -f "/factorio/maps/$lmn/map.zip" ]
		    then
			echo "We should create the map first"
			persistConfig
			$binpath --create "/factorio/maps/$lmn/map" --mod-directory /factorio/mods/ $moreopts
			echo "Created new map"
			sleep $defaultSleep
		    fi
		    echo "Using map name '$lmn'"
		    persistConfig
		    $binpath --start-server "/factorio/maps/$lmn/map" --mod-directory /factorio/mods/ $moreopts
		fi
	    fi
    	elif [ "$uin" == "2" ]
	then
	    TFN=$(mktemp)
	    wget -O $TFN -o /dev/null "https://factorio.com/download-headless/experimental"
	    cat $TFN | grep " (64 bit" | head -n1 | cut -f3 -d "/" > /factorio/lkv
	    rm $TFN
	    echo "Version check completed"
	    sleep $defaultSleep
	elif [ "$uin" == "3" ]
	then
	    if [ ! -f "/factorio/lkv" ]
	    then
		echo "Please check for the latest version first"
		sleep $defaultSleep
	    else
		TFN=$(mktemp)
		wget -O $TFN "https://factorio.com/get-download/"`cat /factorio/lkv`"/headless/linux64"
#cp /linux64-0.18.18.tar.gz $TFN
		cd /tmp
		rm -fr factorio
		tar xfv $TFN
		mv /tmp/factorio/ "/factorio/"`cat /factorio/lkv`
		cd /factorio
		rm -fr factorio
		ln -s /factorio/`cat /factorio/lkv` /factorio/factorio
		persistConfig
		rm $TFN
	    fi
	elif [ "$uin" == "4" ]
	then
	    echo "Creating new map"
	    mapName=`date +"%Y-%m-%d-%H-%M-%S"`"-$(getRandomString)"
	    echo "$mapName" > /factorio/lmn
	elif [ "$uin" == "5" ]
	then
	    mc /factorio/conf/
	elif [ "$uin" == "0" ] || [[ "$uin" =~ [qQ] ]]
	then
	    clear
	    echo "Exiting. BB."
	    sleep $defaultSleep
	    exit
	fi
    else
	mainLoop
    fi
done
