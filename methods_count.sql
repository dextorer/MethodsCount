-- MySQL dump 10.13  Distrib 5.6.26, for osx10.8 (x86_64)
--
-- Host: localhost    Database: methods_count
-- ------------------------------------------------------
-- Server version	5.6.26

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
-- Current Database: `methods_count`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `methods_count` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `methods_count`;

--
-- Table structure for table `dependencies`
--

DROP TABLE IF EXISTS `dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dependencies` (
  `library_id` int(11) NOT NULL,
  `dependency_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dependencies`
--

LOCK TABLES `dependencies` WRITE;
/*!40000 ALTER TABLE `dependencies` DISABLE KEYS */;
INSERT INTO `dependencies` VALUES (78,79),(78,80),(78,81),(82,83),(84,85),(86,87),(86,88),(86,89),(86,90),(92,93),(92,94);
/*!40000 ALTER TABLE `dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libraries`
--

DROP TABLE IF EXISTS `libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `libraries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fqn` varchar(255) NOT NULL,
  `count` int(11) DEFAULT '0',
  `group_id` varchar(255) NOT NULL,
  `artifact_id` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libraries`
--

LOCK TABLES `libraries` WRITE;
/*!40000 ALTER TABLE `libraries` DISABLE KEYS */;
INSERT INTO `libraries` VALUES (78,'com.github.dextorer:sofa:1.0.0',817,'com.github.dextorer','sofa','1.0.0',103622),(79,'com.android.support:leanback-v17:22.2.0',5223,'com.android.support','leanback-v17','22.2.0',682686),(80,'com.android.support:recyclerview-v7:22.2.0',1984,'com.android.support','recyclerview-v7','22.2.0',252391),(81,'com.android.support:support-v4:22.2.0',7946,'com.android.support','support-v4','22.2.0',883426),(82,'com.squareup.retrofit:retrofit:1.9.0',766,'com.squareup.retrofit','retrofit','1.9.0',121559),(83,'com.google.code.gson:gson:2.3.1',1231,'com.google.code.gson','gson','2.3.1',210856),(84,'com.android.support:percent:23.0.0',97,'com.android.support','percent','23.0.0',11659),(85,'com.android.support:support-v4:23.0.0',8591,'com.android.support','support-v4','23.0.0',956260),(86,'com.facebook.fresco:fresco:0.7.0',91,'com.facebook.fresco','fresco','0.7.0',9206),(87,'com.android.support:support-v4:21.0.3',6721,'com.android.support','support-v4','21.0.3',762542),(88,'com.facebook.fresco:drawee:0.7.0',852,'com.facebook.fresco','drawee','0.7.0',93506),(89,'com.facebook.fresco:fbcore:0.7.0',866,'com.facebook.fresco','fbcore','0.7.0',103331),(90,'com.facebook.fresco:imagepipeline:0.7.0',2816,'com.facebook.fresco','imagepipeline','0.7.0',470604),(91,'com.makeramen:roundedimageview:2.1.1',224,'com.makeramen','roundedimageview','2.1.1',18757),(92,'com.wnafee:vector-compat:1.0.5',609,'com.wnafee','vector-compat','1.0.5',66760),(93,'com.android.support:appcompat-v7:22.1.0',5162,'com.android.support','appcompat-v7','22.1.0',568259),(94,'com.android.support:support-v4:22.1.0',7876,'com.android.support','support-v4','22.1.0',882586),(95,'com.squareup.okio:okio:1.6.0',610,'com.squareup.okio','okio','1.6.0',65928),(96,'com.squareup.leakcanary:leakcanary-android:1.3.1',454,'com.squareup.leakcanary','leakcanary-android','1.3.1',75028);
/*!40000 ALTER TABLE `libraries` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-09-02 16:44:15
