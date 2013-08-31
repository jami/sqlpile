-- create database and table structure
CREATE DATABASE sqlpile;

USE sqlpile;

CREATE TABLE `Table1` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `col1` int(11) DEFAULT '0',
    `col2` int(11) DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Table2` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `fid` int(11) NOT NULL,
    `data` varchar(100) DEFAULT 'data',  
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;