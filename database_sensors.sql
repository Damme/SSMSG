

CREATE TABLE IF NOT EXISTS `config` (
  `configid` tinyint(4) NOT NULL,
  `value` varchar(32) NOT NULL,
  PRIMARY KEY (`configid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `config` (`configid`, `value`) VALUES
(0, 'M');

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


CREATE TABLE IF NOT EXISTS `sensordata` (
  `nodeid` int(11) NOT NULL,
  `childid` int(11) NOT NULL,
  `value` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `sensorlist` (
  `nodeid` int(11) NOT NULL,
  `childid` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  PRIMARY KEY (`nodeid`,`childid`),
  KEY `childid` (`childid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `sensorlist`
  ADD CONSTRAINT `sensorlist_ibfk_1` FOREIGN KEY (`nodeid`) REFERENCES `node` (`nodeid`) ON DELETE CASCADE ON UPDATE CASCADE;
