#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

# configure environment
. "${DIR}/conf/env.sh"

APPLICATION_LOG=$1
LOG_FILE_NAME=$(basename $APPLICATION_LOG)
LOCAL_TMP_DIR=$DIR/$LOCAL_TMP_DIR

mkdir -p $LOCAL_TMP_DIR
echo "Parsing logs from $APPLICATION_LOG"
echo "temporary local folder: $LOCAL_TMP_DIR"
echo "temporary logfilename on hdfs $LOG_FILE_NAME"

hdfs dfs -copyFromLocal $APPLICATION_LOG $LOG_FILENAME

"$bin"/spark-submit-1.4.1.sh --master $SPARK_MASTER\
        --class it.polimi.spark.LoggerParser\
         $DIR/uber-sparkloggerparser-0.0.1-SNAPSHOT.jar\
         -o $HDFS_OUTPUT_DIR\
         -i $LOG_FILE_NAME\
         -es\
         -e\
         -j\
         -t\
         --exportToDatabase\
	 --dbUrl $DB_URL\
         --dbUser $DB_USER_NAME\
         --dbPassword $DB_PASSWORD



echo "Copying results from hdfs to local disk in $LOCAL_TMP_DIR"
hdfs dfs -copyToLocal $HDFS_OUTPUT_DIR/* $LOCAL_TMP_DIR

echo "Removign temportary files from hdfs"
hdfs dfs -rm $LOG_FILE_NAME
mv $APPLICATION_LOG $LOCAL_TMP_DIR/Application.log

echo "removing hive temporary files"
rm derby.log
rm -rf metastore_db

echo "Rendering images"
for f in $LOCAL_TMP_DIR/*/*.dot
do
 echo "Rendering: $f"
 dot -Tpng $f -o $f.png &
done

echo "removing .crc files from dags folder"
for f in $LOCAL_TMP_DIR/dags/.*.crc
do
 rm $f
done


echo "moving RDD dags away in a separate folder since they are not supported by the performance estimator at the moment"
mkdir $LOCAL_TMP_DIR/dags/RDD
for f in $LOCAL_TMP_DIR/dags/RDD*
do
 mv $f $LOCAL_TMP_DIR/dags/RDD/
done


APP_NAME=$(cat $LOCAL_TMP_DIR/application.info | egrep "Application Name" | cut -d ';' -f 2 | tr ' ' _)
APP_ID=$(cat $LOCAL_TMP_DIR/application.info | egrep "Application Id" | cut -d ';' -f 2)
CLUSTER_NAME=$(cat $LOCAL_TMP_DIR/application.info | egrep "Cluster name" | cut -d ';' -f 2)
FINAL_OUTPUT_DIR=$FTP_BASE/results/$APP_NAME/$USER/$APP_ID
FTP_FOLDER=$FTP_URL/$APP_NAME/$USER/$APP_ID
TEST_TYPE=aggregation


echo "App id: $APP_ID App name $APP_NAME Cluster Name $CLUSTER_NAME Ftp folder: $FTP_FOLDER"

echo "UPDATE benchmark SET logFolder='$FTP_FOLDER' WHERE appID='$APP_ID' AND clusterName='$CLUSTER_NAME'" | mysql sparkbench -u$DB_USER_NAME -p$DB_PASSWORD


echo "Estimating performaces of Jobs"
java -jar  $DIR/performance-estimator-0.0.1-SNAPSHOT-jar-with-dependencies.jar\
	-i $LOCAL_TMP_DIR/dags\
	-s $LOCAL_TMP_DIR/StageDetails.csv\
	-j $LOCAL_TMP_DIR/JobDetails.csv\
	-o $LOCAL_TMP_DIR/Estimation.csv\
	--exportToDatabase\
	--dbUrl $DB_URL\
	--dbUser $DB_USER_NAME\
	--dbPassword $DB_PASSWORD\
	--clusterName $CLUSTER_NAME\
	--appId $APP_ID\
	--test $TEST_TYPE

actual_time=$($DIR/bin/getDuration.sh $LOCAL_TMP_DIR/application.csv);
echo "Application execution time: $actual_time"


mkdir -p $FINAL_OUTPUT_DIR
#Wait for render to finish
echo "Waiting a bit for the render of DAGS to finish.."
sleep 10;
#mv $APPLICATION_LOG $LOCAL_OUTPUT_DIR/Application.json
mv $LOCAL_TMP_DIR/* $FINAL_OUTPUT_DIR
rm -r $LOCAL_TMP_DIR/*
echo "The output of the analysis can be found in $FINAL_OUTPUT_DIR"

if [ "x${SEND_TO:+set}" = "xset" ]; then
  echo "Application $APP_NAME with id $APP_ID added by user $USER." | mail -s "SparkBench DB Application Added" -a $FINAL_OUTPUT_DIR/application.info "$SEND_TO"
fi

