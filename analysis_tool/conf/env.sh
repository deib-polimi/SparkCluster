#Properties file for the logger parser

#Address to notify of completed analyses
SEND_TO=eugenio.gianniti@polimi.it

#The directory on HDFS where the parser save the result of the analysis
HDFS_OUTPUT_DIR=/analysis
LOCAL_TMP_DIR=working
ABORTED_DIR=aborted

#The hadoop and spark home and configuration folders and urls
SPARK_MASTER=spark://clusterino1:7077
SPARK_HOME=/opt/spark
SPARK_141_HOME=/opt/spark-1.4.1
HADOOP_HOME=/opt/hadoop-2.6.2
HADOOP_CONF_DIF=/$HADOOP_HOME/etc/hadoop
HDFS_MASTER=hdfs://clusterino1:9000

#some environent needed when running trigger with cron
JAVA_HOME=/usr/lib/jvm/java-8-oracle
SHELL=/bin/bash
MAIL=/var/spool/mail/gibilisco

#Username and password of the db to which export the analysis results
DB_URL=jdbc:mysql://127.0.0.1/sparkbench
DB_USER_NAME=analysis
DB_PASSWORD=PASSWORD

#Base folder of the ftp used to store logs and results after the analysis
FTP_BASE=/opt/ftp
FTP_URL=ftp://131.175.135.120/ftp
FTP_INCOMING=$FTP_BASE/incoming
