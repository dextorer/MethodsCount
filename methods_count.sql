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
INSERT INTO `dependencies` VALUES (3,4),(3,5),(3,6),(3,7),(8,9),(8,10),(8,11),(12,13),(12,14),(12,15),(16,17),(16,18),(16,19),(16,20),(16,21),(16,22),(16,23),(24,25),(24,26),(27,28),(27,6),(27,7),(31,32);
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
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libraries`
--

LOCK TABLES `libraries` WRITE;
/*!40000 ALTER TABLE `libraries` DISABLE KEYS */;
INSERT INTO `libraries` VALUES (3,'com.github.dextorer:sofa:1.0.0',817,'com.github.dextorer','sofa','1.0.0',104108),(4,'com.android.support:leanback-v17:22.2.0',5223,'com.android.support','leanback-v17','22.2.0',842268),(5,'com.android.support:recyclerview-v7:22.2.0',1984,'com.android.support','recyclerview-v7','22.2.0',239214),(6,'com.android.support:support-annotations:22.2.0',20,'com.android.support','support-annotations','22.2.0',19096),(7,'com.android.support:support-v4:22.2.0',7946,'com.android.support','support-v4','22.2.0',1020632),(8,'com.wnafee:vector-compat:1.0.5',609,'com.wnafee','vector-compat','1.0.5',87234),(9,'com.android.support:appcompat-v7:22.1.0',5162,'com.android.support','appcompat-v7','22.1.0',829066),(10,'com.android.support:support-annotations:22.1.0',3,'com.android.support','support-annotations','22.1.0',11467),(11,'com.android.support:support-v4:22.1.0',7876,'com.android.support','support-v4','22.1.0',1005480),(12,'com.squareup.leakcanary:leakcanary-android:1.3.1',454,'com.squareup.leakcanary','leakcanary-android','1.3.1',114011),(13,'com.squareup.haha:haha:1.3',1759,'com.squareup.haha','haha','1.3',316913),(14,'com.squareup.leakcanary:leakcanary-analyzer:1.3.1',126,'com.squareup.leakcanary','leakcanary-analyzer','1.3.1',14774),(15,'com.squareup.leakcanary:leakcanary-watcher:1.3.1',73,'com.squareup.leakcanary','leakcanary-watcher','1.3.1',13798),(16,'com.facebook.fresco:fresco:0.7.0',91,'com.facebook.fresco','fresco','0.7.0',9419),(17,'com.parse.bolts:bolts-android:1.1.4',357,'com.parse.bolts','bolts-android','1.1.4',47225),(18,'com.facebook.fresco:drawee:0.7.0',852,'com.facebook.fresco','drawee','0.7.0',86979),(19,'com.facebook.fresco:fbcore:0.7.0',866,'com.facebook.fresco','fbcore','0.7.0',88827),(20,'com.facebook.fresco:imagepipeline:0.7.0',2816,'com.facebook.fresco','imagepipeline','0.7.0',3446143),(21,'com.nineoldandroids:library:2.4.0',929,'com.nineoldandroids','library','2.4.0',110747),(22,'com.android.support:support-annotations:21.0.3',3,'com.android.support','support-annotations','21.0.3',11467),(23,'com.android.support:support-v4:21.0.3',6721,'com.android.support','support-v4','21.0.3',860830),(24,'com.android.support:percent:23.0.0',97,'com.android.support','percent','23.0.0',12570),(25,'com.android.support:support-annotations:23.0.0',20,'com.android.support','support-annotations','23.0.0',19096),(26,'com.android.support:support-v4:23.0.0',8591,'com.android.support','support-v4','23.0.0',1108921),(27,'com.android.support:design:22.2.0',1751,'com.android.support','design','22.2.0',217438),(28,'com.android.support:appcompat-v7:22.2.0',5260,'com.android.support','appcompat-v7','22.2.0',846282),(29,'com.android.support:support-annotations:22.2.0',20,'com.android.support','support-annotations','22.2.0',19096),(30,'com.android.support:support-v4:22.2.0',7946,'com.android.support','support-v4','22.2.0',1020632),(31,'com.squareup.retrofit:retrofit:1.9.0',766,'com.squareup.retrofit','retrofit','1.9.0',121559),(32,'com.google.code.gson:gson:2.3.1',1231,'com.google.code.gson','gson','2.3.1',210856);
/*!40000 ALTER TABLE `libraries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_statuses`
--

DROP TABLE IF EXISTS `library_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `library_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `library_name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_statuses`
--

LOCK TABLES `library_statuses` WRITE;
/*!40000 ALTER TABLE `library_statuses` DISABLE KEYS */;
INSERT INTO `library_statuses` VALUES (1,'com.github.dextorer:sofa:1.0.0','done'),(2,'com.github.dextorer:sofa:1.0.0','done'),(3,'com.github.dextorer:sofa:1.0.0','done'),(4,'com.squareup.okio:okio:1.6.0','done'),(5,'com.android.support:percent:23.0.0','done');
/*!40000 ALTER TABLE `library_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20150829153516');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-09-04  0:15:25
