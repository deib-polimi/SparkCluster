-- phpMyAdmin SQL Dump
-- version 4.6.1
-- http://www.phpmyadmin.net
--
-- Host: 131.175.135.120
-- Generation Time: May 23, 2016 at 05:26 PM
-- Server version: 5.5.49-0ubuntu0.14.04.1-log
-- PHP Version: 7.0.4-7ubuntu2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE DATABASE sparkbench;
use sparkbench;

--
-- Database: `sparkbench`
--

-- --------------------------------------------------------

--
-- Table structure for table `benchmark`
--

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
  `logFolder` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `cluster`
--

CREATE TABLE `cluster` (
  `name` varchar(45) NOT NULL,
  `owner` varchar(45) DEFAULT NULL,
  `url` varchar(45) DEFAULT NULL,
  `cores` int(11) DEFAULT NULL,
  `ram` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cluster`
--

INSERT INTO `cluster` (`name`, `owner`, `url`, `cores`, `ram`) VALUES
  ('yarn-client', 'ubuntu', 'yarn-client', 2, 4);

-- --------------------------------------------------------

--
-- Table structure for table `job`
--

CREATE TABLE `job` (
  `jobID` int(11) NOT NULL,
  `appID` varchar(45) NOT NULL,
  `clusterName` varchar(45) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `estimatedDuration` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `rdd`
--

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
  `diskSize` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `stage`
--

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
  `shuffleWriteSize` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `benchmark`
--
ALTER TABLE `benchmark`
  ADD PRIMARY KEY (`appID`,`clusterName`),
  ADD KEY `cluster_idx` (`clusterName`);

--
-- Indexes for table `cluster`
--
ALTER TABLE `cluster`
  ADD PRIMARY KEY (`name`);

--
-- Indexes for table `job`
--
ALTER TABLE `job`
  ADD PRIMARY KEY (`jobID`,`appID`,`clusterName`),
  ADD KEY `app_idx` (`appID`,`clusterName`);

--
-- Indexes for table `rdd`
--
ALTER TABLE `rdd`
  ADD PRIMARY KEY (`rddID`,`appID`,`clusterName`),
  ADD KEY `inApp_idx` (`appID`,`clusterName`);

--
-- Indexes for table `stage`
--
ALTER TABLE `stage`
  ADD PRIMARY KEY (`stageID`,`jobID`,`appID`,`clusterName`),
  ADD KEY `inJob_idx` (`jobID`,`appID`,`clusterName`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `benchmark`
--
ALTER TABLE `benchmark`
  ADD CONSTRAINT `inCluster` FOREIGN KEY (`clusterName`) REFERENCES `cluster` (`name`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `job`
--
ALTER TABLE `job`
  ADD CONSTRAINT `inApp` FOREIGN KEY (`appID`,`clusterName`) REFERENCES `benchmark` (`appID`, `clusterName`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `rdd`
--
ALTER TABLE `rdd`
  ADD CONSTRAINT `rddInApp` FOREIGN KEY (`appID`,`clusterName`) REFERENCES `benchmark` (`appID`, `clusterName`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `stage`
--
ALTER TABLE `stage`
  ADD CONSTRAINT `inJob` FOREIGN KEY (`jobID`,`appID`,`clusterName`) REFERENCES `job` (`jobID`, `appID`, `clusterName`) ON DELETE CASCADE ON UPDATE CASCADE;
