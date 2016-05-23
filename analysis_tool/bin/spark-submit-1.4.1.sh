#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

# configure environment
. "${DIR}/conf/env.sh"
#stop SPARK
$SPARK_HOME/sbin/stop-all.sh

sleep 5;
OLD_SPARK_HOME=$SPARK_HOME
#this variables are exported only locally 
export SPARK_HOME=$SPARK_141_HOME

$SPARK_HOME/sbin/start-all.sh
echo "submitting $@"
$SPARK_HOME/bin/spark-submit $@
$SPARK_HOME/sbin/stop-all.sh

sleep 5;

#export back the original variables to restart the default spark
export SPARK_HOME=$OLD_SPARK_HOME
$SPARK_HOME/sbin/start-all.sh

sleep 5;
