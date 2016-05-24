#!/usr/bin/env bash

REMOTE=$1
MODE=$2

OLD_DIR=${PWD}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

trap 'cd $OLD_DIR' 0

if [ $# -ne 2 ]; then
    echo "Usage: $0 {remote address} {master|slave|performance}"
    exit 1
fi

#copy installer
scp -r ../SparkCluster $REMOTE:~/SparkCluster

#install
ssh $REMOTE "~/SparkCluster/install.sh $MODE"