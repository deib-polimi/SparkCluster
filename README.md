# SparkCluster

This project aims to be a simple guide for setting up a simple Hadoop cluster with Ambari on Ubuntu 14.04 Server and testing its performance using the ***[spark-perf](https://github.com/databricks/spark-perf)*** benchmarks.
It provides the script and the configuration files to install and Hadoop and Spark cluster; the installation of the cluster is to be done using Ambari, graphically.

## How to replicate the experiment
### 1. Set up the cluster

#### 1.1 Hardware setup
This setup was tested with **5 virtual nodes**, each with:
* 4 GB of RAM
* 2 virtual CPU
* 40 GB of disk space

#### 1.2 Installation procedure

1. Install the required instances of [Ubuntu Server 14.04](http://www.ubuntu.com/download/server) on the number of VMs that you want. We first tested this configuration with 5 nodes. One of the nodes will be the master, the others will be the slaves of our Hadoop/Spark cluster. The configuration for the master and of the slaves are included in the Vagrantfiles and in the bootstrap.sh files. The bootstrap files also take care of installing the required packages.
1. Provision the machines. Two alternatives:
    * execute `install.sh {master|slave}` as root directly on the instances
    * execute `installRemote.sh address {master|slave}` locally
1. For each machine:
    1. edit `/etc/hostname` to match "master" or "slave1", "slave2", ...
    1. edit `/etc/hosts` to add the IP address of all the machines in the cluster
    1. `sudo service hostname restart`
1. master must be able to access via SSH to itself and to the slaves using public key and passwordless (required for Ambari setup). So, on master:
    1. `ssh-keygen`
    1. `ssh-copy-id master`
    1. `for i in {1..$N_SLAVES}; do ssh-copy-id slave$i; done;`
1. On master, [set up](https://ambari.apache.org/1.2.1/installing-hadoop-using-ambari/content/ambari-chap2-2.html) Ambari server (v 2.2.2.0) on master (`ambari-server setup`). Choose custom Java JDK and give the result of the `echo $JAVA_HOME` command when asked for Java Home.
1. [Start](https://ambari.apache.org/1.2.1/installing-hadoop-using-ambari/content/ambari-chap2-3.html) Ambari server (v 2.2.2.0) (`ambari-server start`).
1. Go to the web page of Ambari server (`http://master:8080`).
1. Start installation process and give to Ambari the names (the same of `/etc/hosts`) of the master and the slaves. It could complain about them not being FQDNs: that's not a problem.
1. Give to Ambari the SSH private key (`~/.ssh/id_rsa`) of the master when asked: it needs it to install all the things on the slaves.
1. Using Ambari, install on the cluster the following software. Pure slaves should have at least the DataNode, NodeManager, YARN Client and Spark Client. Master services can be distributed among some slaves.
    * HDFS 2.7.1.2.4
    * YARN + MapReduce2 2.7.1.2.4
    * Tez 0.7.0.2.4
    * Hive 1.2.1.2.4
    * Pig 0.15.0.2.4
    * ZooKeeper 3.4.6.2.4
    * Hadoop 2.7.1.2.4
    * Ambari Metrics 0.1.0
    * Spark 1.6.1
1. Start all the services from Ambari and check that they're working.

There is a saved Ambari blueprint with all the settings in the [`blueprint` folder](https://github.com/deib-polimi/SparkCluster/tree/master/blueprint).
It was obtained with the Ambari API call:

    http://master:8080/api/v1/clusters/myclustername?format=blueprint

### 2. Configure Spark and YARN

We tweaked a couple variables to assign more memory to the workers.

Configuration changes for Spark:

    spark.yarn.driver.memoryOverhead=1000
    spark.yarn.executor.memoryOverhead=1000

Configuration changes for YARN:

    yarn.nodemanager.resource.memory-mb=3584
    yarn.scheduler.maximum-allocation-mb=3584

All of these can be done with Ambari.

### 3. Clone and inspect the benchmarks

We used [spark-perf](https://github.com/databricks/spark-perf) to evaluate the performance of our cluster. However, to gain more flexibility, we modified it in order to parametrize the memory used for the tasks and the number of executors.

So, we will used a [forked version](https://github.com/carduz/spark-perf). And we built a [configuration file](https://github.com/deib-polimi/SparkCluster/blob/master/spark-perf/config.py) for that.

**`install.sh master` already cloned those repositories for you.**

Now take a look at our version of `spark-perf/config/config.py`. The important things to look at are:

```python
# ================================ #
#  Standard Configuration Options  #
# ================================ #

# Point to an installation of Spark on the cluster.
# This path is valid for Spark 1.6.1 installed with Ambari.
SPARK_HOME_DIR = "/usr/hdp/current/spark-client"

# Set driver memory here
# --driver-memory MEM         Memory for driver (e.g. 1000M, 2G) (Default: 1024M).
SPARK_DRIVER_MEMORY = "2g"

# Additional data: spark-submit options, launch spark-submit to see them all.
# --executor-cores NUM        Number of cores per executor. (Default: 1 in YARN mode,
#                               or all available cores on the worker in standalone mode)
# --num-executors NUM         Number of executors to launch (Default: 2).
# --executor-memory MEM       Memory per executor (e.g. 1000M, 2G) (Default: 1G).
ADDITIONAL_DATA = "--num-executors 5 --executor-memory 512m --executor-cores 1"
ADDITIONAL_DATA += " --driver-memory %s" % SPARK_DRIVER_MEMORY

# SPARK_CLUSTER_URL: Master used when submitting Spark jobs.
# For local clusters: "spark://%s:7077" % socket.gethostname()
# For Yarn clusters: "yarn"
# Otherwise, the default uses the specified EC2 cluster
#SPARK_CLUSTER_URL = open("/root/spark-ec2/cluster-url", 'r').readline().strip()
SPARK_CLUSTER_URL = "yarn"

# If this is true, we'll submit your job using an existing Spark installation.
# If this is false, we'll clone and build a specific version of Spark, and
# copy configurations from your existing Spark installation.
USE_CLUSTER_SPARK = True

# Which test sets to run. Each test set contains several tests.
RUN_SPARK_TESTS = True
RUN_PYSPARK_TESTS = True
RUN_STREAMING_TESTS = True
RUN_MLLIB_TESTS = True
RUN_PYTHON_MLLIB_TESTS = True

# Which tests to prepare. Set this to true for the first
# installation or whenever you make a change to the tests.
PREP_SPARK_TESTS = True
PREP_PYSPARK_TESTS = True
PREP_STREAMING_TESTS = True
PREP_MLLIB_TESTS = True

# The default values configured below are appropriate for approximately 20 m1.xlarge nodes,
# in which each node has 15 GB of memory. Use this variable to scale the values (e.g.
# number of records in a generated dataset) if you are running the tests with more
# or fewer nodes. When developing new test suites, you might want to set this to a small
# value suitable for a single machine, such as 0.001.
SCALE_FACTOR = 0.001

# Memory options are really important: defaults are too high, we need to reduce them.

COMMON_JAVA_OPTS = [
    # ...
    JavaOptionSet("spark.executor.memory", ["2g"]),
    # ...
]
```

### 4. Configure and run the benchmarks

In `config/config.py` we can specify the test sets that we want to run.
There are five test set, and they can be enabled or disabled with the corresponding configuration variables:

```python
RUN_SPARK_TESTS = True
RUN_PYSPARK_TESTS = False
RUN_STREAMING_TESTS = False
RUN_MLLIB_TESTS = False
RUN_PYTHON_MLLIB_TESTS = False
```

**Note:** The first time a test is executed you need to set the corresponding `PREP_{TEST}` variable to true in order to compile it.

Also, using `config.py` we can specify the single tests that we want to run inside each test set.
For example, if in the pyspark tests we want to exclude `python-scheduling-throughput`, we can simply comment out the lines:

```python
PYSPARK_TESTS += [("python-scheduling-throughput", "core_tests.py",
    SCALE_FACTOR, COMMON_JAVA_OPTS,
    [ConstantOption("SchedulerThroughputTest"), OptionSet("num-tasks", [5000])] + COMMON_OPTS)]
```

We can execute the tests, by running:

    bin/run

**Note:** Don't configure `SPARK_HOME_DIR/config/slaves` since we use YARN, even if spark-perf suggests to do that

### 5. Parse the logs

We'll use [spark-log-processor](https://github.com/GiovanniPaoloGibilisco/spark-log-processor) to parse the log.

`spark-log-processor` needs Spark 1.4.1 and MySQL to process the logs and generate the results. So, **it will need to run on a separate cluster**, if you don't want to have two different versions of Spark on the same machine.

**Installation of Spark 1.4.1 is not covered by install.sh. You will need to do it by hand.**

#### 5.1 Get logs

First, we need to fetch the logs from HDFS to the local filesystem of our cluster:

    sudo -u hdfs hdfs dfs -get /spark-history .

Then you will need to copy them to the analysis server, e.g. with rsync.

If you want to clear the generated logs:

    sudo -u hdfs hdfs dfs -rm "/spark-history/* "

Don't remove the spark-history folder, as the benchmarks may encounter permission problems.

#### 5.2 Clone and compile the software on the analysis cluster

Let's check the Spark configuration of the cluster to benchmark and take note of this.

    spark.eventLog.enabled=true
    spark.eventLog.dir=hdfs:///spark-history

Before building, we [removed (fork)](https://github.com/carduz/spark-log-processor/commit/4337f4dc74c333353640fb27e57fe224d895efd6) from `spark-log-processor/sparkloggerparser/pom.xml` an useless dependency which caused the build of performance-estimator to fail.

To install all the things that are needed on the host dedicated to log parsing, simply run:

    ./SparkCluster/install.sh performance

This will install all the packages needed for the analysis of the Spark logs, including MySQL, the performance database, spark-log-processor; it will also compile the required dependencies.

You may want to tweak the parameters of the cluster to test corresponding to the name `yarn-client` in the `sparkperf.cluster` table in MySQL.

### 5.3 Automated parsing of the logs

The `analysis_tool` folder contains a method to automatically parse the logs and write the results to MySQL. It was automatically installed by `install.sh performance`.

You must check out `analysis_tool/conf/env.sh` and configure the paths for your machine.

To analyze the logs:
1. Copy the log files into `$FTP_BASE/incoming`
1. Run `analysis_tool/bin/ftp_listener.sh`

The script will automatically detect the logs and it will process them. In case of errors, check `analysis_tool/logs`.

**Note:** if the benchmark doesn't perform any shuffle operation in a single log file, the parser fails to parse that file: it expect some shuffle statistics.

## TODO

- [ ] Complete analyze.sh, installer for log analyzer
