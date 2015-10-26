-- MySQL dump 10.13  Distrib 5.1.69, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: methods_count
-- ------------------------------------------------------
-- Server version	5.1.69

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
INSERT INTO `dependencies` VALUES (3,4),(3,5),(3,6),(3,7),(8,9),(8,10),(8,11),(12,13),(12,14),(12,15),(16,17),(16,18),(16,19),(16,20),(16,21),(16,22),(16,23),(24,25),(24,26),(27,28),(27,6),(27,7),(31,32),(33,6),(36,35),(36,10),(36,11),(40,41),(40,42),(44,43),(46,45),(46,47),(46,48),(51,49),(51,50),(55,52),(55,53),(55,54),(61,7),(61,58),(61,6),(61,59),(61,60),(61,62),(61,63),(65,23),(65,22),(65,17),(67,66),(71,69),(79,73),(79,74),(79,75),(79,76),(79,77),(79,78),(79,80),(79,81),(79,82),(79,83),(79,84),(79,85),(79,86),(79,87),(79,88),(79,89),(79,90),(79,91),(79,92),(79,93),(79,94),(79,95),(79,96),(79,97),(107,7),(107,102),(107,103),(107,104),(107,105),(107,106),(107,6),(107,108),(107,109),(107,110),(107,28),(107,111),(107,112),(107,113),(107,114),(107,115),(107,116),(107,117),(107,118),(107,119),(107,120),(107,121),(107,122),(107,123),(107,124),(107,125),(107,126),(130,128),(130,129),(131,53),(131,54),(133,132),(133,128),(133,129),(133,130),(134,52),(134,53),(134,54),(135,128),(135,129),(136,53),(136,54);
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
) ENGINE=InnoDB AUTO_INCREMENT=139 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libraries`
--

LOCK TABLES `libraries` WRITE;
/*!40000 ALTER TABLE `libraries` DISABLE KEYS */;
INSERT INTO `libraries` VALUES (3,'com.github.dextorer:sofa:1.0.0',817,'com.github.dextorer','sofa','1.0.0',104108),(4,'com.android.support:leanback-v17:22.2.0',5223,'com.android.support','leanback-v17','22.2.0',842268),(5,'com.android.support:recyclerview-v7:22.2.0',1984,'com.android.support','recyclerview-v7','22.2.0',239214),(6,'com.android.support:support-annotations:22.2.0',20,'com.android.support','support-annotations','22.2.0',19096),(7,'com.android.support:support-v4:22.2.0',7946,'com.android.support','support-v4','22.2.0',1020632),(8,'com.wnafee:vector-compat:1.0.5',609,'com.wnafee','vector-compat','1.0.5',87234),(9,'com.android.support:appcompat-v7:22.1.0',5162,'com.android.support','appcompat-v7','22.1.0',829066),(10,'com.android.support:support-annotations:22.1.0',3,'com.android.support','support-annotations','22.1.0',11467),(11,'com.android.support:support-v4:22.1.0',7876,'com.android.support','support-v4','22.1.0',1005480),(12,'com.squareup.leakcanary:leakcanary-android:1.3.1',454,'com.squareup.leakcanary','leakcanary-android','1.3.1',114011),(13,'com.squareup.haha:haha:1.3',1759,'com.squareup.haha','haha','1.3',316913),(14,'com.squareup.leakcanary:leakcanary-analyzer:1.3.1',126,'com.squareup.leakcanary','leakcanary-analyzer','1.3.1',14774),(15,'com.squareup.leakcanary:leakcanary-watcher:1.3.1',73,'com.squareup.leakcanary','leakcanary-watcher','1.3.1',13798),(16,'com.facebook.fresco:fresco:0.7.0',91,'com.facebook.fresco','fresco','0.7.0',9419),(17,'com.parse.bolts:bolts-android:1.1.4',357,'com.parse.bolts','bolts-android','1.1.4',47225),(18,'com.facebook.fresco:drawee:0.7.0',852,'com.facebook.fresco','drawee','0.7.0',86979),(19,'com.facebook.fresco:fbcore:0.7.0',866,'com.facebook.fresco','fbcore','0.7.0',88827),(20,'com.facebook.fresco:imagepipeline:0.7.0',2816,'com.facebook.fresco','imagepipeline','0.7.0',3446143),(21,'com.nineoldandroids:library:2.4.0',929,'com.nineoldandroids','library','2.4.0',110747),(22,'com.android.support:support-annotations:21.0.3',3,'com.android.support','support-annotations','21.0.3',11467),(23,'com.android.support:support-v4:21.0.3',6721,'com.android.support','support-v4','21.0.3',860830),(24,'com.android.support:percent:23.0.0',97,'com.android.support','percent','23.0.0',12570),(25,'com.android.support:support-annotations:23.0.0',20,'com.android.support','support-annotations','23.0.0',19096),(26,'com.android.support:support-v4:23.0.0',8591,'com.android.support','support-v4','23.0.0',1108921),(27,'com.android.support:design:22.2.0',1751,'com.android.support','design','22.2.0',217438),(28,'com.android.support:appcompat-v7:22.2.0',5260,'com.android.support','appcompat-v7','22.2.0',846282),(29,'com.android.support:support-annotations:22.2.0',20,'com.android.support','support-annotations','22.2.0',19096),(30,'com.android.support:support-v4:22.2.0',7946,'com.android.support','support-v4','22.2.0',1020632),(31,'com.squareup.retrofit:retrofit:1.9.0',766,'com.squareup.retrofit','retrofit','1.9.0',121559),(32,'com.google.code.gson:gson:2.3.1',1231,'com.google.code.gson','gson','2.3.1',210856),(33,'com.badoo.mobile:android-weak-handler:1.1',68,'com.badoo.mobile','android-weak-handler','1.1',6919),(34,'com.android.support:support-annotations:22.2.0',20,'com.android.support','support-annotations','22.2.0',19096),(35,'com.android.support:recyclerview-v7:22.1.0',1721,'com.android.support','recyclerview-v7','22.1.0',209461),(36,'xyz.danoz:recyclerviewfastscroller:0.1.3',129,'xyz.danoz','recyclerviewfastscroller','0.1.3',19704),(37,'com.android.support:support-annotations:22.1.0',3,'com.android.support','support-annotations','22.1.0',11467),(38,'com.android.support:support-v4:22.1.0',7876,'com.android.support','support-v4','22.1.0',882586),(39,'com.github.mmin18.layoutcast:library:1.1.4',313,'com.github.mmin18.layoutcast','library','1.1.4',33244),(40,'com.microsoft.azure:azure-mobile-services-android-sdk:2.0.3',2653,'com.microsoft.azure','azure-mobile-services-android-sdk','2.0.3',368815),(41,'com.google.code.gson:gson:2.3',1230,'com.google.code.gson','gson','2.3',206853),(42,'com.google.guava:guava:18.0',14833,'com.google.guava','guava','18.0',2256213),(43,'com.android.support:support-annotations:22.0.0',3,'com.android.support','support-annotations','22.0.0',11467),(44,'net.grandcentrix.tray:tray:0.9.2',285,'net.grandcentrix.tray','tray','0.9.2',32480),(45,'com.android.support:recyclerview-v7:22.1.1',1721,'com.android.support','recyclerview-v7','22.1.1',209461),(46,'com.tonicartos:superslim:0.4.13',305,'com.tonicartos','superslim','0.4.13',46394),(47,'com.android.support:support-annotations:22.1.1',3,'com.android.support','support-annotations','22.1.1',11467),(48,'com.android.support:support-v4:22.1.1',7876,'com.android.support','support-v4','22.1.1',882586),(49,'com.android.support:support-annotations:22.2.1',20,'com.android.support','support-annotations','22.2.1',19096),(50,'com.android.support:support-v4:22.2.1',7946,'com.android.support','support-v4','22.2.1',883563),(51,'com.android.support:appcompat-v7:22.2.1',5258,'com.android.support','appcompat-v7','22.2.1',581858),(52,'com.android.support:appcompat-v7:23.0.1',5139,'com.android.support','appcompat-v7','23.0.1',571583),(53,'com.android.support:support-v4:23.0.1',8604,'com.android.support','support-v4','23.0.1',958726),(54,'com.android.support:support-annotations:23.0.1',20,'com.android.support','support-annotations','23.0.1',19096),(55,'com.github.fafaldo:fab-toolbar:1.0.1',137,'com.github.fafaldo','fab-toolbar','1.0.1',18314),(56,'org.bonnyfone:brdcompat:0.1',71,'org.bonnyfone','brdcompat','0.1',7368),(57,'com.google.code.gson:gson:2.4',1242,'com.google.code.gson','gson','2.4',212164),(58,'com.google.android.gms:play-services-base:7.8.0',4769,'com.google.android.gms','play-services-base','7.8.0',868639),(59,'com.jakewharton.timber:timber:3.0.1',92,'com.jakewharton.timber','timber','3.0.1',7760),(60,'io.reactivex:rxjava:1.0.14',4276,'io.reactivex','rxjava','1.0.14',834040),(61,'com.github.prefanatic.hermes:hermes-core:0.3.0',291,'com.github.prefanatic.hermes','hermes-core','0.3.0',27997),(62,'io.reactivex:rxandroid:1.0.1',54,'io.reactivex','rxandroid','1.0.1',6382),(63,'org.apache.commons:commons-csv:1.2',261,'org.apache.commons','commons-csv','1.2',38795),(64,'net.orfjackal.retrolambda:retrolambda:2.0.6',0,'net.orfjackal.retrolambda','retrolambda','2.0.6',224768),(65,'com.facebook.android:facebook-android-sdk:3.23.1',3975,'com.facebook.android','facebook-android-sdk','3.23.1',622439),(66,'org.xerial:sqlite-jdbc:3.8.7',4403,'org.xerial','sqlite-jdbc','3.8.7',3959324),(67,'com.novoda:sqlite-analyzer:0.3.2',708,'com.novoda','sqlite-analyzer','0.3.2',57673),(69,'javax.inject:javax.inject:1',2,'javax.inject','javax.inject','1',2497),(71,'com.google.dagger:dagger:2.0.1',94,'com.google.dagger','dagger','2.0.1',17559),(72,'com.github.bumptech.glide:glide:3.6.1',2882,'com.github.bumptech.glide','glide','3.6.1',475237),(73,'com.android.tools.ddms:ddmlib:24.3.1',1911,'com.android.tools.ddms','ddmlib','24.3.1',294217),(74,'commons-logging:commons-logging:1.1.1',521,'commons-logging','commons-logging','1.1.1',60686),(75,'com.android.tools:sdk-common:24.3.1',2774,'com.android.tools','sdk-common','24.3.1',453897),(76,'org.ow2.asm:asm-analysis:5.0.3',218,'org.ow2.asm','asm-analysis','5.0.3',20443),(77,'org.apache.httpcomponents:httpclient:4.1.1',2171,'org.apache.httpcomponents','httpclient','4.1.1',351132),(78,'com.android.tools.layoutlib:layoutlib-api:24.3.1',664,'com.android.tools.layoutlib','layoutlib-api','24.3.1',88015),(79,'com.android.tools.lint:lint-checks:24.3.1',2464,'com.android.tools.lint','lint-checks','24.3.1',675568),(80,'com.android.tools.build:builder-model:1.3.1',242,'com.android.tools.build','builder-model','1.3.1',24498),(81,'com.android.tools:sdklib:24.3.1',3395,'com.android.tools','sdklib','24.3.1',738823),(82,'com.android.tools.build:builder-test-api:1.3.1',97,'com.android.tools.build','builder-test-api','1.3.1',11628),(83,'org.ow2.asm:asm:5.0.3',457,'org.ow2.asm','asm','5.0.3',53231),(84,'net.sf.kxml:kxml2:2.3.0',429,'net.sf.kxml','kxml2','2.3.0',43858),(85,'commons-codec:commons-codec:1.4',401,'commons-codec','commons-codec','1.4',58160),(86,'org.apache.commons:commons-compress:1.8.1',2246,'org.apache.commons','commons-compress','1.8.1',365552),(87,'com.intellij:annotations:12.0',18,'com.intellij','annotations','12.0',20195),(88,'org.ow2.asm:asm-tree:5.0.3',336,'org.ow2.asm','asm-tree','5.0.3',29036),(89,'com.android.tools.lint:lint-api:24.3.1',1383,'com.android.tools.lint','lint-api','24.3.1',196218),(90,'com.android.tools:annotations:24.3.1',9,'com.android.tools','annotations','24.3.1',8015),(91,'com.android.tools:dvlib:24.3.1',84,'com.android.tools','dvlib','24.3.1',23689),(92,'com.google.code.gson:gson:2.2.4',1144,'com.google.code.gson','gson','2.2.4',190432),(93,'com.android.tools:common:24.3.1',646,'com.android.tools','common','24.3.1',91331),(94,'com.android.tools.external.lombok:lombok-ast:0.2.3',6194,'com.android.tools.external.lombok','lombok-ast','0.2.3',720633),(95,'org.apache.httpcomponents:httpmime:4.1',188,'org.apache.httpcomponents','httpmime','4.1',26813),(96,'com.google.guava:guava:17.0',14824,'com.google.guava','guava','17.0',2243036),(97,'org.apache.httpcomponents:httpcore:4.1',1197,'org.apache.httpcomponents','httpcore','4.1',181041),(98,'com.birbit:android-priority-jobqueue:1.3.4',611,'com.birbit','android-priority-jobqueue','1.3.4',88730),(99,'de.greenrobot:eventbus:2.4.0',314,'de.greenrobot','eventbus','2.4.0',45282),(100,'com.briangriffey:slideuppane:1.0',58,'com.briangriffey','slideuppane','1.0',4678),(101,'eu.inmite.android.lib:android-validation-komensky:0.9.4',347,'eu.inmite.android.lib','android-validation-komensky','0.9.4',58303),(102,'com.google.android.gms:play-services-appinvite:8.1.0',152,'com.google.android.gms','play-services-appinvite','8.1.0',17511),(103,'com.google.android.gms:play-services-maps:8.1.0',2520,'com.google.android.gms','play-services-maps','8.1.0',271634),(104,'com.google.android.gms:play-services-gcm:8.1.0',560,'com.google.android.gms','play-services-gcm','8.1.0',57801),(105,'com.google.android.gms:play-services-analytics:8.1.0',3137,'com.google.android.gms','play-services-analytics','8.1.0',405326),(106,'com.google.android.gms:play-services-appstate:8.1.0',3137,'com.google.android.gms','play-services-appstate','8.1.0',261),(107,'com.google.android.gms:play-services:8.1.0',0,'com.google.android.gms','play-services','8.1.0',0),(108,'com.google.android.gms:play-services-nearby:8.1.0',1264,'com.google.android.gms','play-services-nearby','8.1.0',193685),(109,'com.google.android.gms:play-services-panorama:8.1.0',90,'com.google.android.gms','play-services-panorama','8.1.0',14325),(110,'com.google.android.gms:play-services-cast:8.1.0',1670,'com.google.android.gms','play-services-cast','8.1.0',199050),(111,'com.google.android.gms:play-services-drive:8.1.0',2912,'com.google.android.gms','play-services-drive','8.1.0',449565),(112,'com.google.android.gms:play-services-measurement:8.1.0',1085,'com.google.android.gms','play-services-measurement','8.1.0',110076),(113,'com.google.android.gms:play-services-location:8.1.0',1775,'com.google.android.gms','play-services-location','8.1.0',243085),(114,'com.google.android.gms:play-services-vision:8.1.0',596,'com.google.android.gms','play-services-vision','8.1.0',96125),(115,'com.google.android.gms:play-services-identity:8.1.0',180,'com.google.android.gms','play-services-identity','8.1.0',23648),(116,'com.google.android.gms:play-services-ads:8.1.0',6632,'com.google.android.gms','play-services-ads','8.1.0',989363),(117,'com.google.android.gms:play-services-plus:8.1.0',1462,'com.google.android.gms','play-services-plus','8.1.0',137398),(118,'com.android.support:mediarouter-v7:22.2.0',1189,'com.android.support','mediarouter-v7','22.2.0',165467),(119,'com.google.android.gms:play-services-appindexing:8.1.0',600,'com.google.android.gms','play-services-appindexing','8.1.0',80683),(120,'com.google.android.gms:play-services-safetynet:8.1.0',164,'com.google.android.gms','play-services-safetynet','8.1.0',22629),(121,'com.google.android.gms:play-services-fitness:8.1.0',2292,'com.google.android.gms','play-services-fitness','8.1.0',352175),(122,'com.google.android.gms:play-services-wearable:8.1.0',1959,'com.google.android.gms','play-services-wearable','8.1.0',259061),(123,'com.google.android.gms:play-services-base:8.1.0',608,'com.google.android.gms','play-services-base','8.1.0',59951),(124,'com.google.android.gms:play-services-wallet:8.1.0',1240,'com.google.android.gms','play-services-wallet','8.1.0',164239),(125,'com.google.android.gms:play-services-basement:8.1.0',4530,'com.google.android.gms','play-services-basement','8.1.0',866726),(126,'com.google.android.gms:play-services-games:8.1.0',4863,'com.google.android.gms','play-services-games','8.1.0',620244),(127,'com.squareup.picasso:picasso:2.5.2',849,'com.squareup.picasso','picasso','2.5.2',120459),(128,'com.android.support:support-v4:23.1.0',8914,'com.android.support','support-v4','23.1.0',1023209),(129,'com.android.support:support-annotations:23.1.0',20,'com.android.support','support-annotations','23.1.0',19096),(130,'com.android.support:recyclerview-v7:23.1.0',2200,'com.android.support','recyclerview-v7','23.1.0',286999),(131,'com.android.support:recyclerview-v7:23.0.1',2142,'com.android.support','recyclerview-v7','23.0.1',279574),(132,'com.android.support:appcompat-v7:23.1.0',5283,'com.android.support','appcompat-v7','23.1.0',592948),(133,'com.android.support:design:23.1.0',2127,'com.android.support','design','23.1.0',249994),(134,'com.android.support:design:23.0.1',1908,'com.android.support','design','23.0.1',219025),(135,'com.android.support:palette-v7:23.1.0',183,'com.android.support','palette-v7','23.1.0',21902),(136,'com.android.support:palette-v7:23.0.1',173,'com.android.support','palette-v7','23.0.1',21006),(137,'com.android.support:cardview-v7:23.1.0',197,'com.android.support','cardview-v7','23.1.0',17999),(138,'com.android.support:cardview-v7:23.0.1',197,'com.android.support','cardview-v7','23.0.1',17999);
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
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_statuses`
--

LOCK TABLES `library_statuses` WRITE;
/*!40000 ALTER TABLE `library_statuses` DISABLE KEYS */;
INSERT INTO `library_statuses` VALUES (1,'com.github.dextorer:sofa:1.0.0','done'),(2,'com.github.dextorer:sofa:1.+','done'),(3,'com.wnafee:vector-compat:1.0.5','done'),(8,'com.android.support:appcompat-v7:22.2.1','done'),(9,'com.github.fafaldo:fab-toolbar:1.0.1','done'),(13,'org.bonnyfone:brdcompat:0.1','done'),(15,'com.google.code.gson:gson:2.3.1','done'),(16,'com.google.code.gson:gson:2.4','done'),(17,'com.github.prefanatic.hermes:hermes-core:0.3.0','done'),(20,'net.orfjackal.retrolambda:retrolambda:2.0.6','done'),(21,'com.facebook.android:facebook-android-sdk:3.23.1','done'),(22,'com.novoda:sqlite-analyzer:0.3.2','done'),(25,'com.novoda:notils:2.2.13\'','error'),(48,'com.google.dagger:dagger:2.0.1','done'),(49,'com.github.bumptech.glide:glide:3.6.1','done'),(50,'com.android.tools.lint:lint-checks:24.3.1','done'),(52,'com.birbit:android-priority-jobqueue:1.3.4','done'),(53,'de.greenrobot:eventbus:2.4.0','done'),(54,'com.squareup.retrofit:retrofit:1.9.0','done'),(55,'com.briangriffey:slideuppane:1.0@aar','done'),(56,'eu.inmite.android.lib:android-validation-komensky:0.9.4@aar','done'),(61,'com.google.android.gms:play-services:8.1.0','done'),(62,'com.android.support:support-v4:23.0.1','done'),(64,'com.google.android.gms:play-services-ads:8.1.0','done'),(65,'com.google.android.gms:play-services-games:8.1.0','done'),(66,'com.google.android.gms:play-services-base:7.8.0','done'),(67,'com.google.guava:guava:17.0','done'),(68,'com.android.support:support-v4:22.2.0','done'),(69,'io.reactivex:rxjava:1.0.14','done'),(70,'com.google.android.gms:play-services-basement:8.1.0','done'),(71,'com.android.support:leanback-v17:22.2.0','done'),(72,'com.squareup.leakcanary:leakcanary-android:1.3.1','done'),(73,'com.google.guava:guava:18.0','done'),(75,'com.squareup.picasso:picasso:2.5.2','done'),(76,'com.github.dextorer:sofa:+','done'),(77,'com.android.support:support-v4:23.0.0','done'),(81,'com.android.support:recyclerview-v7:23.1.0','done'),(82,'com.android.support:recyclerview-v7:23.0.1','done'),(83,'com.android.support:support-v4:23.1.0','done'),(84,'com.android.support:design:23.1.','error'),(85,'com.android.support:design:23.1.0','done'),(86,'com.android.support:design:23.0.1','done'),(87,'com.android.support:palette-v7:23.1.0','done'),(88,'com.android.support:appcompat-v7:23.1.0','done'),(89,'com.android.support:palette-v7:23.0.1','done'),(90,'com.android.support:cardview-v7:23.1.0','done'),(91,'com.android.support:cardview-v7:23.0.1','done');
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

-- Dump completed on 2015-10-16 20:15:03
