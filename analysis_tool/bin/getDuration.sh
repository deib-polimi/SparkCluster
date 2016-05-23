#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

# configure environment
. "${DIR}/conf/env.sh"

APP_EVENTS_FILE=$1
startTime=$(cat $APP_EVENTS_FILE | grep SparkListenerApplicationStart | cut -d ',' -f 3 );
endTime=$(cat $APP_EVENTS_FILE | grep SparkListenerApplicationEnd | cut -d ',' -f 3 );
let "executionTime = endTime - startTime"
echo $executionTime

