/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_skill_relation` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `member_id` int(11) DEFAULT NULL,
  `skill_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `member_skill_relation` VALUES (1,1,1),(2,1,2),(3,2,3),(4,3,3),(5,3,4),(6,3,5);

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `members` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `members` VALUES (1,'User-A','2014-04-01 15:20:22','2014-04-01 15:20:22'),(2,'User-B','2014-04-01 15:21:30','2014-04-01 15:21:30'),(3,'User-C','2014-04-01 15:21:41','2014-04-01 15:21:41');

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skills` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(11) DEFAULT NULL,
  `url` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `skills` VALUES (1,'PHP','http://php.net/'),(2,'Ruby','https://www.ruby-lang.org/'),(3,'Python','https://www.python.org/'),(4,'Java','https://www.java.com/'),(5,'Perl','http://www.perl.org/');
