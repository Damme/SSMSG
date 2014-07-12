-- phpMyAdmin SQL Dump
-- version 4.1.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 12, 2014 at 02:27 PM
-- Server version: 5.5.37-MariaDB-log
-- PHP Version: 5.5.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `sensors`
--

-- --------------------------------------------------------

--
-- Table structure for table `config`
--

CREATE TABLE IF NOT EXISTS `config` (
  `configid` tinyint(4) NOT NULL,
  `value` varchar(32) NOT NULL,
  PRIMARY KEY (`configid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `config`
--

INSERT INTO `config` (`configid`, `value`) VALUES
(0, 'M');

-- --------------------------------------------------------

--
-- Table structure for table `node`
--

CREATE TABLE IF NOT EXISTS `node` (
  `nodeid` int(11) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `version` varchar(32) DEFAULT NULL,
  `I_SKETCH_NAME` varchar(32) DEFAULT NULL,
  `I_SKETCH_VERSION` varchar(32) DEFAULT NULL,
  `lastseen` datetime DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `location` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`nodeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `node`
--

INSERT INTO `node` (`nodeid`, `type`, `version`, `I_SKETCH_NAME`, `I_SKETCH_VERSION`, `lastseen`, `name`, `location`) VALUES
(0, 0, NULL, NULL, NULL, NULL, NULL, NULL);


-- --------------------------------------------------------

--
-- Table structure for table `sendrequest`
--

CREATE TABLE IF NOT EXISTS `sendrequest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nodeid` tinyint(4) NOT NULL,
  `childid` tinyint(4) NOT NULL,
  `messagetype` tinyint(4) NOT NULL,
  `subtype` tinyint(4) NOT NULL,
  `payload` text,
  `sent` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Table structure for table `sensordata`
--

CREATE TABLE IF NOT EXISTS `sensordata` (
  `nodeid` int(11) NOT NULL,
  `childid` int(11) NOT NULL,
  `value` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `sensorlist`
--

CREATE TABLE IF NOT EXISTS `sensorlist` (
  `nodeid` int(11) NOT NULL,
  `childid` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  PRIMARY KEY (`nodeid`,`childid`),
  KEY `childid` (`childid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `sensorlist`
--
ALTER TABLE `sensorlist`
  ADD CONSTRAINT `sensorlist_ibfk_1` FOREIGN KEY (`nodeid`) REFERENCES `node` (`nodeid`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
