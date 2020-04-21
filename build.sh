#!/bin/bash
opts="--no-cache"
opts=""


if [ "$1" != "--no-increment" ]
then
    V_TMP=`mktemp`
    V_CURRENT=`cat Dockerfile | grep CONTAINER_VERSION | cut -f2 -d "="`
    let V_NEXT=$V_CURRENT+1
    cat Dockerfile | replace "ENV CONTAINER_VERSION=$V_CURRENT" "ENV CONTAINER_VERSION=$V_NEXT" > $V_TMP
    cat $V_TMP > Dockerfile
    rm $V_TMP
fi
V_CURRENT=`cat Dockerfile | grep CONTAINER_VERSION | cut -f2 -d "="`

docker build $opts --network dicknet -t "xpuctu4/factorio-18" -t "xpuctu4/factorio-18:0.${V_CURRENT}" .;
docker run --network dicknet --name fffff -it --rm xpuctu4/factorio-18