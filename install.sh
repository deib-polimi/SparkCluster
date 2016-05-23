#!/usr/bin/env bash

MODE=$1

if [ $# -ne 1 ]; then
	echo "Usage: $0 {master|slave|performance}"
	exit 1
fi

if [ "$MODE" == "master" ]; then
    echo "master"
    master/bootstrap.sh
    git clone http://github.com/carduz/spark-perf.git git/spark-perf
	exit 0
elif [ "$MODE" == "performance" ]; then
	echo "master"
	performance/bootstrap.sh
    https://github.com/carduz/spark-log-processor.git git/spark-log-processor
	exit 0
elif [ "$MODE" == "slave" ]; then
	echo "slave"
	slave/bootstrap.sh
	exit 0
else
	echo "Usage: $0 {master|slave|performance}"
	exit 1
fi