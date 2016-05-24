#!/usr/bin/env bash

MODE=$1

OLD_DIR=${PWD}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

trap 'cd $OLD_DIR' 0

usage (){
echo "Usage: $0 {master|slave|performance}"
echo -e "\tmaster:\t\texecute master/bootstrap and clone spark-perf using the right config"
echo -e "\tslave:\t\texecute slave/bootstrap "
echo -e "\tperformance:\texecute performance/bootstrap, clone and compile spark-log-processors"
exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

if [ "$MODE" == "master" ]; then
    echo "master"
    sudo master/bootstrap.sh
    git clone http://github.com/carduz/spark-perf.git git/spark-perf
    cp spark-perf/config.py git/spark-perf/config
    exit 0
elif [ "$MODE" == "performance" ]; then
    echo "performance"
    sudo performance/bootstrap.sh
    git clone https://github.com/carduz/spark-log-processor.git git/spark-log-processor
    git/spark-log-processor/build.sh
    cp git/spark-log-processor/sparkloggerparser/target/uber-sparkloggerparser-0.0.1-SNAPSHOT.jar analysis_tool
    cp git/performance-estimator/target/performance-estimator-0.0.1-SNAPSHOT-jar-with-dependencies.jar analysis_tool
    exit 0
elif [ "$MODE" == "slave" ]; then
    echo "slave"
    sudo slave/bootstrap.sh
    exit 0
else
    usage
fi
