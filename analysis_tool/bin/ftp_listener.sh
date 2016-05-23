#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

# configure environment
. "${DIR}/conf/env.sh"
#this script is triggered each time a file is created into the ftp incoming folder

#incron runs in a sparse environment, we have to re-build everything here. 
export PATH=$PATH:/$HADOOP_HOME/bin:/$SPARK_HOME/bin




analyze () {

FILE_NAME=$1
LOG_FILE=$DIR/logs/trigger.log
ANALYSIS_LOG_FILE=$DIR/logs/analysis.log
WORKING_ROOT=$DIR/working
FULL_PATH=$FTP_BASE/incoming/$FILE_NAME
WORKING_DIRECTORY=$WORKING_ROOT/$(echo $FILE_NAME | cut -d '.' -f 1)
USER=$(ls -all $FULL_PATH | cut -d ' ' -f 3)
ANALYSIS_SCRIPT=$DIR/bin/application_statistics.sh 

date >> $LOG_FILE
echo "received file $FULL_PATH by $USER" >> $LOG_FILE

#create temporary folder for the processing and move the file there
mkdir -p $WORKING_DIRECTORY >> $LOG_FILE
cp $FULL_PATH $WORKING_DIRECTORY >> $LOG_FILE

#call the analysis script specifying the input file, the default user to upload data to the db, its password, and the user who uploaded the file
date >> $ANALYSIS_LOG_FILE
cd $WORKING_DIRECTORY
$ANALYSIS_SCRIPT $WORKING_DIRECTORY/$FILE_NAME trigger passw0rd $USER &>> $ANALYSIS_LOG_FILE $WORKING_DIRECTORY

rm -r $WORKING_DIRECTORY >> $LOG_FILE
echo "$FULL_PATH Analized" >> $LOG_FILE
rm $FULL_PATH >>  $LOG_FILE


}



while true;
do

if [ "$(ls -A $FTP_INCOMING)" ];
 then
  FILE_NAME=$(ls -A -1 $FTP_INCOMING | head -1)
  analyze $FILE_NAME;
 else
  sleep 10;
fi

done

