#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

# configure environment
. "${DIR}/conf/env.sh"

#This scripts looks into the spark.eventLog.dir folder specified in the cluster configuration and retireves the ID of the latest application run
SPARK_CONF_FILE=$SPARK_HOME/conf/spark-defaults.conf
APP_LOGS=$(cat $SPARK_CONF_FILE | grep spark.eventLog.dir | cut -f4 -d"/")

HDFS=$HADOOP_HOME/bin/hdfs

id=$($HDFS dfs -ls  /$APP_LOGS | grep -v ".inprogress" | grep -v "local" | grep -v "Found" | cut -f3 -d"/" | sort| tail -n 1)
echo $id
