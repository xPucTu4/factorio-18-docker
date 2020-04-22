#!/bin/bash

. xPucTu4.sh

opts="--no-cache"
opts=""

if ! [[ -f ./IMAGE_VERSION ]]; then echo -n "0" > IMAGE_VERSION;fi
IMAGE_VERSION=$(cat IMAGE_VERSION)

if [ "$1" != "--no-increment" ]
then
    let "IMAGE_VERSION++"
    echo -n $IMAGE_VERSION > IMAGE_VERSION
    opts="$opts -t xpuctu4/factorio-18:0.${IMAGE_VERSION}"
fi

read -r -d '' buildargs << EOARGS
--build-arg IMAGE_VERSION="$IMAGE_VERSION"
--build-arg IMAGE_DATE="$(date)"
EOARGS

eval `echo docker build ${buildargs} $opts --network dicknet -t "xpuctu4/factorio-18" .`
#docker run --network dicknet --name "fffff-$(getRandomString 4)" -it --rm xpuctu4/factorio-18