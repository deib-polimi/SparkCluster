-- MySQL dump 10.13  Distrib 5.5.49, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: sparkbench
-- ------------------------------------------------------
-- Server version	5.5.49-0ubuntu0.14.04.1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `benchmark`
--

DROP TABLE IF EXISTS `benchmark`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `benchmark` (
  `appID` varchar(45) NOT NULL,
  `clusterName` varchar(45) NOT NULL,
  `appName` varchar(45) DEFAULT NULL,
  `dataSize` double DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `parallelism` int(11) DEFAULT NULL,
  `driverMemory` double DEFAULT NULL,
  `executorMemory` double DEFAULT NULL,
  `kryoMaxBuffer` int(11) DEFAULT NULL,
  `rddCompress` tinyint(1) DEFAULT NULL,
  `shuffleMemoryFraction` double DEFAULT NULL,
  `storageMemoryFraction` double DEFAULT NULL,
  `storageLevel` varchar(45) DEFAULT NULL,
  `executors` int(11) DEFAULT NULL,
  `state` varchar(45) DEFAULT NULL,
  `estimatedDuration` int(11) DEFAULT NULL,
  `logFolder` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`appID`,`clusterName`),
  KEY `cluster_idx` (`clusterName`),
  CONSTRAINT `inCluster` FOREIGN KEY (`clusterName`) REFERENCES `cluster` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cluster`
--

DROP TABLE IF EXISTS `cluster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cluster` (
  `name` varchar(45) NOT NULL,
  `owner` varchar(45) DEFAULT NULL,
  `url` varchar(45) DEFAULT NULL,
  `cores` int(11) DEFAULT NULL,
  `ram` int(11) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job`
--

DROP TABLE IF EXISTS `job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job` (
  `jobID` int(11) NOT NULL,
  `appID` varchar(45) NOT NULL,
  `clusterName` varchar(45) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `estimatedDuration` int(11) DEFAULT NULL,
  PRIMARY KEY (`jobID`,`appID`,`clusterName`),
  KEY `app_idx` (`appID`,`clusterName`),
  CONSTRAINT `inApp` FOREIGN KEY (`appID`, `clusterName`) REFERENCES `benchmark` (`appID`, `clusterName`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rdd`
--

DROP TABLE IF EXISTS `rdd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rdd` (
  `rddID` int(11) NOT NULL,
  `appID` varchar(45) NOT NULL,
  `clusterName` varchar(45) NOT NULL,
  `rddName` varchar(200) DEFAULT NULL,
  `stageID` varchar(45) DEFAULT NULL,
  `scope` varchar(45) DEFAULT NULL,
  `useDisk` tinyint(1) DEFAULT NULL,
  `useMemory` tinyint(1) DEFAULT NULL,
  `deserialized` tinyint(1) DEFAULT NULL,
  `numberOfPartitions` int(11) DEFAULT NULL,
  `cachedPartitions` int(11) DEFAULT NULL,
  `memorySize` double DEFAULT NULL,
  `diskSize` double DEFAULT NULL,
  PRIMARY KEY (`rddID`,`appID`,`clusterName`),
  KEY `inApp_idx` (`appID`,`clusterName`),
  CONSTRAINT `rddInApp` FOREIGN KEY (`appID`, `clusterName`) REFERENCES `benchmark` (`appID`, `clusterName`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stage`
--

DROP TABLE IF EXISTS `stage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stage` (
  `stageID` int(11) NOT NULL,
  `jobID` int(11) NOT NULL,
  `appID` varchar(45) NOT NULL,
  `clusterName` varchar(45) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `estimatedDuration` int(11) DEFAULT NULL,
  `inputSize` double DEFAULT NULL,
  `outputSize` double DEFAULT NULL,
  `shuffleReadSize` double DEFAULT NULL,
  `shuffleWriteSize` double DEFAULT NULL,
  PRIMARY KEY (`stageID`,`jobID`,`appID`,`clusterName`),
  KEY `inJob_idx` (`jobID`,`appID`,`clusterName`),
  CONSTRAINT `inJob` FOREIGN KEY (`jobID`, `appID`, `clusterName`) REFERENCES `job` (`jobID`, `appID`, `clusterName`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-05-23 13:06:35
