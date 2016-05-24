# SparkCluster

This project aims to be a simple guide for setting up a simple Hadoop cluster with Ambari on Ubuntu 14.04 Server and testing its performance using the ***[spark-perf](https://github.com/databricks/spark-perf)*** benchmarks.
It provides the script and the configuration files to install and Hadoop and Spark cluster; the installation of the cluster is to be done using Ambari, graphically.

## How to replicate the experiment
### 1. Set up the cluster
1. Install the required instances of [Ubuntu Server 14.04](http://www.ubuntu.com/download/server) on the number of VMs that you want. We first tested this configuration with 5 nodes. One of the nodes will be the master, the others will be the slaves of our Hadoop/Spark cluster. The configuration for the master and of the slaves are included in the Vagrantfiles and in the bootstrap.sh files. The bootstrap files also take care of installing the required packages.
1. Provision the machines (`vagrant up`) or execute `install.sh` as root.
1. For each machine:
    1. edit `/etc/hostname` to match "master" or "slave1", "slave2", ...
    1. edit `/etc/hosts` to add the IP address of the master and of the hostname set for the local machine
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

**If you have used `install.sh` you have to skip this point.**

We used [spark-perf](https://github.com/databricks/spark-perf) to evaluate the performance of our cluster. However, to gain more flexibility, we modified it in order to parametrize the memory used for the tasks and the number of executors.

So, we will used a [forked version](https://github.com/carduz/spark-perf). And we built a [configuration file](https://github.com/deib-polimi/SparkCluster/blob/master/spark-perf/config.py) for that.

    git clone https://github.com/deib-polimi/SparkCluster.git
    git clone https://github.com/carduz/spark-perf.git
    cp SparkCluster/spark-perf/config.py spark-perf/config/config.py

Then take a look at our version of `spark-perf/config/config.py`. The important things to look at are:

```python
# Point to an installation of Spark on the cluster.
SPARK_HOME_DIR = "/usr/hdp/current/spark-client"

# Additional options (our customization).
# --executor-cores must be 1 for YARN
ADDITIONAL_DATA = "--num-executors 5 --driver-memory 512m --executor-memory 512m --executor-cores 1"

SPARK_CLUSTER_URL = "yarn"
USE_CLUSTER_SPARK = True

# URL of the HDFS installation in the Spark cluster.
# We need a directory where the user that is running the tests has privileges.
HDFS_URL = "hdfs:///user/ubuntu/test/"

# Which tests to run
RUN_SPARK_TESTS = True
RUN_PYSPARK_TESTS = False
RUN_STREAMING_TESTS = False
RUN_MLLIB_TESTS = False
RUN_PYTHON_MLLIB_TESTS = False

# Which tests to prepare. Set this to true for the first
# installation or whenever you make a change to the tests.
PREP_SPARK_TESTS = True
PREP_PYSPARK_TESTS = False
PREP_STREAMING_TESTS = False
PREP_MLLIB_TESTS = False

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

# Set driver memory here
SPARK_DRIVER_MEMORY = "2g"
```

### 4. Configure and run the benchmarks

In `config/config.py` we can specify the classes of tests that we want to run.
There are five classes, and they can be set in this way:

```python
RUN_SPARK_TESTS = True
RUN_PYSPARK_TESTS = False
RUN_STREAMING_TESTS = False
RUN_MLLIB_TESTS = False
RUN_PYTHON_MLLIB_TESTS = False
```

**Note:** The first time a test is executed it is needed to set to true `PREP_{TEST}`

Also, we can specify the single tests that we want to run.
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

#### 5.1 Get logs

First, we need to fetch the logs from HDFS to the local filesystem:

    hdfs -get /spark-history .

#### 5.2 Clone and compile the software

**If you have used `install.sh` you have to skip this point.**

We'll use [spark-log-processor](https://github.com/GiovanniPaoloGibilisco/spark-log-processor) to parse the log.

    git clone https://github.com/carduz/spark-log-processor.git

`spark-log-processor` needs Spark 1.4.1 and MySQL to process the logs and generate the results. So, it will need to run on a separate cluster, if you don't want to have two different versions of Spark on the same machine.

Let's check the Spark configuration and take note of this.

    spark.eventLog.enabled=true
    spark.eventLog.dir=hdfs:///spark-history

Before building, we [removed (fork)](https://github.com/carduz/spark-log-processor/commit/4337f4dc74c333353640fb27e57fe224d895efd6) from `spark-log-processor/sparkloggerparser/pom.xml` an useless dependency which caused the build of performance-estimator to fail.

Build the software:

    cd spark-log-processor/sparkloggerparser
    mvn clean package -Dmaven.test.skip=true
    cd ../performance-estimator
    mvn install

To copy Spark logs in local:

    mkdir ~/spark-history
    chmod a+rwx ~/spark-history/
    hdfs -get /spark-history /home/ubuntu

Run:

    cd ~/spark-log-processor/sparkloggerparser
    spark-submit --class it.polimi.spark.LoggerParser --jars target/uber-sparkloggerparser-0.0.1-SNAPSHOT.jar target/sparkloggerparser-0.0.1-SNAPSHOT.jar -i /spark-history/application_1463564626422_0042 -o out

TODO

**Note:** if the bench doesn't produce any test with shuffle the parser fails

## TODO

- [ ] Save and publish Ambari blueprint containing cluster configuration
- [ ] Detail Ambari installation process
- [ ] Specify how to run the performance estimator
- [ ] Complete analyze.sh, installer for log analyzer
- [ ] Complete point 5
- [ ] Fix readme according to installRemote and vagrant
