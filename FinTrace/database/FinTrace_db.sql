-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: fintracedb
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `account_id` varchar(100) NOT NULL,
  `total_sent` decimal(15,2) DEFAULT '0.00',
  `total_received` decimal(15,2) DEFAULT '0.00',
  `transaction_count` int DEFAULT '0',
  `suspicious_score` float DEFAULT '0',
  `ring_id` varchar(50) DEFAULT NULL,
  `last_analyzed` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  KEY `idx_score` (`suspicious_score`),
  KEY `idx_ring` (`ring_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `analysis_log`
--

DROP TABLE IF EXISTS `analysis_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `analysis_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) DEFAULT NULL,
  `transaction_count` int DEFAULT NULL,
  `account_count` int DEFAULT NULL,
  `rings_detected` int DEFAULT NULL,
  `processing_time_ms` int DEFAULT NULL,
  `analyzed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `analysis_log`
--

LOCK TABLES `analysis_log` WRITE;
/*!40000 ALTER TABLE `analysis_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `analysis_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fraud_rings`
--

DROP TABLE IF EXISTS `fraud_rings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fraud_rings` (
  `ring_id` varchar(50) NOT NULL,
  `pattern_type` varchar(50) NOT NULL,
  `risk_score` float DEFAULT '0',
  `member_count` int DEFAULT '0',
  `detected_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ring_id`),
  KEY `idx_pattern` (`pattern_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fraud_rings`
--

LOCK TABLES `fraud_rings` WRITE;
/*!40000 ALTER TABLE `fraud_rings` DISABLE KEYS */;
/*!40000 ALTER TABLE `fraud_rings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(100) NOT NULL,
  `sender_id` varchar(100) NOT NULL,
  `receiver_id` varchar(100) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_time` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  KEY `idx_time` (`transaction_time`)
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (230,'TXN001','ACC1001','ACC2001',5000.00,'2024-01-15 05:00:00','2026-02-19 18:16:59'),(231,'TXN002','ACC2001','ACC3001',2500.00,'2024-01-15 06:15:00','2026-02-19 18:16:59'),(232,'TXN003','ACC3001','ACC1001',7500.00,'2024-01-15 08:50:00','2026-02-19 18:16:59'),(233,'TXN004','ACC1002','ACC2002',1500.00,'2024-01-16 03:30:00','2026-02-19 18:16:59'),(234,'TXN005','ACC1003','ACC2002',2000.00,'2024-01-16 03:45:00','2026-02-19 18:16:59'),(235,'TXN006','ACC1004','ACC2002',1800.00,'2024-01-16 04:00:00','2026-02-19 18:16:59'),(236,'TXN007','ACC1005','ACC2002',2200.00,'2024-01-16 04:30:00','2026-02-19 18:16:59'),(237,'TXN008','ACC1006','ACC2002',1700.00,'2024-01-16 05:00:00','2026-02-19 18:16:59'),(238,'TXN009','ACC1007','ACC2002',1900.00,'2024-01-16 05:30:00','2026-02-19 18:16:59'),(239,'TXN010','ACC1008','ACC2002',2100.00,'2024-01-16 06:00:00','2026-02-19 18:16:59'),(240,'TXN011','ACC1009','ACC2002',1600.00,'2024-01-16 06:30:00','2026-02-19 18:16:59'),(241,'TXN012','ACC1010','ACC2002',2300.00,'2024-01-16 07:00:00','2026-02-19 18:16:59'),(242,'TXN013','ACC1011','ACC2002',1400.00,'2024-01-16 07:30:00','2026-02-19 18:16:59'),(243,'TXN014','ACC1012','ACC2002',2500.00,'2024-01-16 08:00:00','2026-02-19 18:16:59'),(244,'TXN015','ACC1013','ACC2002',1200.00,'2024-01-16 08:30:00','2026-02-19 18:16:59'),(245,'TXN016','ACC2002','ACC3002',8500.00,'2024-01-16 09:30:00','2026-02-19 18:16:59'),(246,'TXN017','ACC3002','ACC4001',4200.00,'2024-01-16 10:00:00','2026-02-19 18:16:59'),(247,'TXN018','ACC4001','ACC5001',3800.00,'2024-01-16 10:30:00','2026-02-19 18:16:59'),(248,'TXN019','ACC1014','ACC1015',3000.00,'2024-01-17 03:30:00','2026-02-19 18:16:59'),(249,'TXN020','ACC1015','ACC1016',3000.00,'2024-01-17 04:30:00','2026-02-19 18:16:59'),(250,'TXN021','ACC1016','ACC1014',3000.00,'2024-01-17 05:30:00','2026-02-19 18:16:59'),(251,'TXN022','ACC2003','ACC3003',4500.00,'2024-01-17 08:30:00','2026-02-19 18:16:59'),(252,'TXN023','ACC3003','ACC4002',4500.00,'2024-01-17 09:30:00','2026-02-19 18:16:59'),(253,'TXN024','ACC4002','ACC5002',4500.00,'2024-01-17 10:30:00','2026-02-19 18:16:59');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-19 23:55:56
