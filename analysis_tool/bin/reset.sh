#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

# configure environment
. "${DIR}/conf/env.sh"
INCOMING=$FTP_BASE/incoming


#declare -a APPLICATION_FOLDERS=("LinerRegressionApp_Example" "LogisticRegressionApp_Example" "Spark_PageRank_Application")
declare -a APPLICATION_FOLDERS=("LogisticRegressionApp_Example")

#process all the applications in the list
for application in "${APPLICATION_FOLDERS[@]}"
do
	APP_FOLDER=$FTP_BASE/$application
	cp -r $APP_FOLDER $FTP_BASE/processing
	rm -rf $APP_FOLDER
	APP_FOLDER=$FTP_BASE/processing
	
	#for each user thhat submitted an application
	for user in $(ls $APP_FOLDER)
	do
		USER_FOLDER=$APP_FOLDER/$user
		counter=5;
		for benchmark in $(ls $USER_FOLDER)
		do
			BENCHMARK_FOLDER=$USER_FOLDER/$benchmark
			echo "Processing: $BENCHMARK_FOLDER"
			
			FILENAME=${application}_${user}_${benchmark}.json
			echo "New filename: $FILENAME"
			mv $BENCHMARK_FOLDER/Application.log $FTP_BASE/$FILENAME
			rm -r $BENCHMARK_FOLDER
			mv $FTP_BASE/$FILENAME $INCOMING
			echo "moving $FTP_BASE/$FILENAME into $INCOMING"
	
			let "counter=$counter-1"
			if [ $counter -eq 0 ]; then
				echo "waiting a bit (5 min) before scheduling other operations";
				sleep 300;
				counter=5
			fi
		done
		#remove user folder
		rm -r $USER_FOLDER
	done
done

#remove processing folder
rm -rf $APP_FOLDER
