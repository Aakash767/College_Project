-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: college_management
-- ------------------------------------------------------
-- Server version	8.0.41

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
-- Table structure for table `academic_session_details`
--

DROP TABLE IF EXISTS `academic_session_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `academic_session_details` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `session_status` enum('Upcoming','Active','Completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Upcoming',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `uq_college_session_name` (`college_id`,`session_name`),
  UNIQUE KEY `uq_session_college` (`session_id`,`college_id`),
  CONSTRAINT `fk_session_college` FOREIGN KEY (`college_id`) REFERENCES `college_details` (`college_id`),
  CONSTRAINT `academic_session_details_chk_1` CHECK ((`end_date` > `start_date`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `academic_session_details`
--

LOCK TABLES `academic_session_details` WRITE;
/*!40000 ALTER TABLE `academic_session_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `academic_session_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_details`
--

DROP TABLE IF EXISTS `attendance_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_details` (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `class_session_id` int NOT NULL,
  `curriculum_id` int NOT NULL,
  `course_subject_id` int NOT NULL,
  `selection_id` int NOT NULL,
  `semester_enrollment_id` int NOT NULL,
  `attendance_status` enum('Present','Absent','Late','Excused') COLLATE utf8mb4_unicode_ci NOT NULL,
  `marked_by` int DEFAULT NULL,
  `marked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attendance_id`),
  UNIQUE KEY `uq_class_student_selection` (`class_session_id`,`selection_id`),
  KEY `fk_attendance_class` (`class_session_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_attendance_selection` (`selection_id`,`semester_enrollment_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_attendance_marker` (`marked_by`),
  KEY `idx_attendance_status` (`attendance_status`),
  CONSTRAINT `fk_attendance_class` FOREIGN KEY (`class_session_id`, `curriculum_id`, `course_subject_id`) REFERENCES `class_session_details` (`class_session_id`, `curriculum_id`, `course_subject_id`),
  CONSTRAINT `fk_attendance_marker` FOREIGN KEY (`marked_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fk_attendance_selection` FOREIGN KEY (`selection_id`, `semester_enrollment_id`, `curriculum_id`, `course_subject_id`) REFERENCES `student_subject_selection_details` (`selection_id`, `semester_enrollment_id`, `curriculum_id`, `course_subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_details`
--

LOCK TABLES `attendance_details` WRITE;
/*!40000 ALTER TABLE `attendance_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_session_details`
--

DROP TABLE IF EXISTS `class_session_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_session_details` (
  `class_session_id` int NOT NULL AUTO_INCREMENT,
  `curriculum_id` int NOT NULL,
  `course_subject_id` int NOT NULL,
  `class_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `class_type` enum('Lecture','Practical','Tutorial','Other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Lecture',
  `conducted_by` int DEFAULT NULL,
  `class_status` enum('Scheduled','Completed','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Scheduled',
  PRIMARY KEY (`class_session_id`),
  UNIQUE KEY `uq_class_session_context` (`class_session_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_class_session_subject` (`course_subject_id`,`curriculum_id`),
  KEY `fk_class_conducted_by` (`conducted_by`),
  KEY `idx_class_date_subject` (`class_date`,`course_subject_id`),
  CONSTRAINT `fk_class_conducted_by` FOREIGN KEY (`conducted_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fk_class_session_subject` FOREIGN KEY (`course_subject_id`, `curriculum_id`) REFERENCES `course_subject_details` (`course_subject_id`, `curriculum_id`),
  CONSTRAINT `class_session_details_chk_1` CHECK (((`end_time` is null) or (`start_time` is null) or (`end_time` > `start_time`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_session_details`
--

LOCK TABLES `class_session_details` WRITE;
/*!40000 ALTER TABLE `class_session_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `class_session_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `college_details`
--

DROP TABLE IF EXISTS `college_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `college_details` (
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `college_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `college_code` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_aishe_code` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_address` text COLLATE utf8mb4_unicode_ci,
  `college_city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_district` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_pincode` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college_phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `registration_status` enum('Pending','Approved','Rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Approved',
  `college_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Inactive',
  PRIMARY KEY (`college_id`),
  UNIQUE KEY `college_code` (`college_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `college_details`
--

LOCK TABLES `college_details` WRITE;
/*!40000 ALTER TABLE `college_details` DISABLE KEYS */;
INSERT INTO `college_details` VALUES ('COL001','Government College of Arts and Science','GCAS001','C-12345','Station Road, Near Central Bus Stand','Chhatrapati Sambhajinagar','Chhatrapati Sambhajinagar','Maharashtra','431001','info@gcas-demo.edu.in','9876543210','2026-11-09 11:12:38','Approved','Active'),('COL002','Modern College of Social Work','MCSW001','C-23456','University Road, Near Main Campus','Pune','Pune','Maharashtra','411007','info@mcsw-demo.edu.in','9876543211','2026-11-09 11:12:38','Approved','Active'),('COL003','Shivaji College of Commerce','SCC001','C-34567','College Road, Near Market Area','Kolhapur','Kolhapur','Maharashtra','416003','info@scc-demo.edu.in','9876543212','2026-11-09 11:12:38','Approved','Active'),('COL1f7621cc0cce406a','ABC College','ABC001','	C-12345','Main Road','Pune','Pune','Maharashtra','411001','abc.college@example.com','9876543210','2026-11-09 16:42:26','Approved','Active'),('COL306b050518bd4b9d','ABC','dummy','dummy','NA','NA','NA','NA','NA','NA@gmail.com','NA','2026-11-10 06:06:26','Rejected','Inactive'),('COLea329bdca58d4537','Aakash_College','Aakash301','Aakash301','NA','Jalgaon','Jalgaon','Maharashtra','425001','aakashclg876@gmail.com','+91 1234567899','2026-11-10 05:28:26','Approved','Active');
/*!40000 ALTER TABLE `college_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_curriculum_details`
--

DROP TABLE IF EXISTS `course_curriculum_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_curriculum_details` (
  `curriculum_id` int NOT NULL AUTO_INCREMENT,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `semester_id` int NOT NULL,
  `academic_year_no` int NOT NULL,
  `session_id` int NOT NULL,
  `curriculum_status` enum('Draft','Active','Archived') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Draft',
  PRIMARY KEY (`curriculum_id`),
  UNIQUE KEY `uq_semester_session` (`semester_id`,`session_id`),
  UNIQUE KEY `uq_curriculum_context` (`curriculum_id`,`college_id`,`dept_id`,`course_id`,`session_id`,`semester_id`,`academic_year_no`),
  KEY `fk_curriculum_semester` (`semester_id`,`college_id`,`dept_id`,`course_id`,`academic_year_no`),
  KEY `fk_curriculum_session` (`session_id`,`college_id`),
  CONSTRAINT `fk_curriculum_semester` FOREIGN KEY (`semester_id`, `college_id`, `dept_id`, `course_id`, `academic_year_no`) REFERENCES `course_semester_details` (`semester_id`, `college_id`, `dept_id`, `course_id`, `academic_year_no`),
  CONSTRAINT `fk_curriculum_session` FOREIGN KEY (`session_id`, `college_id`) REFERENCES `academic_session_details` (`session_id`, `college_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_curriculum_details`
--

LOCK TABLES `course_curriculum_details` WRITE;
/*!40000 ALTER TABLE `course_curriculum_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_curriculum_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_details`
--

DROP TABLE IF EXISTS `course_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_details` (
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_years` int NOT NULL,
  `semesters_per_year` int NOT NULL DEFAULT '2',
  `course_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `course_level` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_mode` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_description` text COLLATE utf8mb4_unicode_ci,
  `course_start_year` year DEFAULT NULL,
  PRIMARY KEY (`college_id`,`dept_id`,`course_id`),
  UNIQUE KEY `uq_course_code` (`college_id`,`dept_id`,`course_code`),
  CONSTRAINT `fk_course_department` FOREIGN KEY (`college_id`, `dept_id`) REFERENCES `department_details` (`college_id`, `dept_id`),
  CONSTRAINT `course_details_chk_1` CHECK ((`duration_years` > 0)),
  CONSTRAINT `course_details_chk_2` CHECK ((`semesters_per_year` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_details`
--

LOCK TABLES `course_details` WRITE;
/*!40000 ALTER TABLE `course_details` DISABLE KEYS */;
INSERT INTO `course_details` VALUES ('COL001','DEPT001','CRS001','Bachelor of Social Work','BSW',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL001','DEPT001','CRS002','Master of Social Work','MSW',2,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL001','DEPT002','CRS001','Bachelor of Arts in Sociology','BA-SOC',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL001','DEPT003','CRS001','Bachelor of Arts in Psychology','BA-PSY',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL001','DEPT004','CRS001','Bachelor of Arts in Political Science','BA-PS',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL002','DEPT001','CRS001','Bachelor of Social Work','BSW',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL002','DEPT001','CRS002','Master of Social Work','MSW',2,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL002','DEPT002','CRS001','Bachelor of Arts in Sociology','BA-SOC',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL002','DEPT003','CRS001','Bachelor of Arts in Psychology','BA-PSY',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL003','DEPT001','CRS001','Bachelor of Commerce','BCOM',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL003','DEPT002','CRS001','Bachelor of Business Administration','BBA',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL003','DEPT002','CRS002','Master of Business Administration','MBA',2,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL003','DEPT003','CRS001','Bachelor of Arts in Economics','BA-ECO',3,2,'Active',NULL,NULL,NULL,NULL,NULL),('COL1f7621cc0cce406a','DEPabe9d36ea35e4aed','CRS30AB8BDA7DE4','Social Work','BSW-101',3,2,'Active','UG','Degree','Regular',NULL,2026),('COLea329bdca58d4537','Did_101','CRSB55D5EED9650','Bachelor in Social Work','BSW',3,2,'Active','Undergraduate','Regular','Regular','NA',2026);
/*!40000 ALTER TABLE `course_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_semester_details`
--

DROP TABLE IF EXISTS `course_semester_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_semester_details` (
  `semester_id` int NOT NULL AUTO_INCREMENT,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `academic_year_no` int NOT NULL,
  `semester_number` int NOT NULL,
  `semester_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`semester_id`),
  UNIQUE KEY `uq_course_semester_number` (`college_id`,`dept_id`,`course_id`,`semester_number`),
  UNIQUE KEY `uq_semester_course_year` (`semester_id`,`college_id`,`dept_id`,`course_id`,`academic_year_no`),
  CONSTRAINT `fk_semester_course` FOREIGN KEY (`college_id`, `dept_id`, `course_id`) REFERENCES `course_details` (`college_id`, `dept_id`, `course_id`),
  CONSTRAINT `course_semester_details_chk_1` CHECK ((`academic_year_no` > 0)),
  CONSTRAINT `course_semester_details_chk_2` CHECK ((`semester_number` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_semester_details`
--

LOCK TABLES `course_semester_details` WRITE;
/*!40000 ALTER TABLE `course_semester_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_semester_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_subject_details`
--

DROP TABLE IF EXISTS `course_subject_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_subject_details` (
  `course_subject_id` int NOT NULL AUTO_INCREMENT,
  `curriculum_id` int NOT NULL,
  `group_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `maximum_marks` decimal(7,2) DEFAULT NULL,
  `passing_marks` decimal(7,2) DEFAULT NULL,
  `subject_order` int DEFAULT NULL,
  PRIMARY KEY (`course_subject_id`),
  UNIQUE KEY `uq_group_subject` (`group_id`,`subject_id`),
  UNIQUE KEY `uq_course_subject_curriculum` (`course_subject_id`,`curriculum_id`),
  UNIQUE KEY `uq_course_subject_context` (`course_subject_id`,`curriculum_id`,`subject_id`),
  KEY `fk_course_subject_group` (`group_id`,`curriculum_id`),
  KEY `fk_course_subject_master` (`subject_id`),
  CONSTRAINT `fk_course_subject_group` FOREIGN KEY (`group_id`, `curriculum_id`) REFERENCES `subject_group_details` (`group_id`, `curriculum_id`),
  CONSTRAINT `fk_course_subject_master` FOREIGN KEY (`subject_id`) REFERENCES `subject_details` (`subject_id`),
  CONSTRAINT `course_subject_details_chk_1` CHECK (((`maximum_marks` is null) or (`maximum_marks` > 0))),
  CONSTRAINT `course_subject_details_chk_2` CHECK (((`passing_marks` is null) or (`passing_marks` >= 0))),
  CONSTRAINT `course_subject_details_chk_3` CHECK (((`maximum_marks` is null) or (`passing_marks` is null) or (`passing_marks` <= `maximum_marks`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_subject_details`
--

LOCK TABLES `course_subject_details` WRITE;
/*!40000 ALTER TABLE `course_subject_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_subject_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `department_details`
--

DROP TABLE IF EXISTS `department_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department_details` (
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`college_id`,`dept_id`),
  UNIQUE KEY `uq_department_name` (`college_id`,`dept_name`),
  CONSTRAINT `fk_department_college` FOREIGN KEY (`college_id`) REFERENCES `college_details` (`college_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `department_details`
--

LOCK TABLES `department_details` WRITE;
/*!40000 ALTER TABLE `department_details` DISABLE KEYS */;
INSERT INTO `department_details` VALUES ('COL001','DEPT001','Social Work','Active'),('COL001','DEPT002','Sociology','Active'),('COL001','DEPT003','Psychology','Active'),('COL001','DEPT004','Political Science','Active'),('COL002','DEPT001','Social Work','Active'),('COL002','DEPT002','Sociology','Active'),('COL002','DEPT003','Psychology','Active'),('COL003','DEPT001','Commerce','Active'),('COL003','DEPT002','Management','Active'),('COL003','DEPT003','Economics','Active'),('COL1f7621cc0cce406a','DEP0A4EAA34EDCE','MSW','Active'),('COL1f7621cc0cce406a','DEPabe9d36ea35e4aed','BSW','Active'),('COLea329bdca58d4537','Did_101','Social Work','Active');
/*!40000 ALTER TABLE `department_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_type_details`
--

DROP TABLE IF EXISTS `document_type_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_type_details` (
  `document_type_id` int NOT NULL AUTO_INCREMENT,
  `document_type_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_mandatory` tinyint(1) NOT NULL DEFAULT '0',
  `document_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `document_type_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`document_type_id`),
  UNIQUE KEY `document_type_name` (`document_type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_type_details`
--

LOCK TABLES `document_type_details` WRITE;
/*!40000 ALTER TABLE `document_type_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_type_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollment_details`
--

DROP TABLE IF EXISTS `enrollment_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollment_details` (
  `enrollment_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_id` int NOT NULL,
  `enrollment_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `academic_year_no` int NOT NULL,
  `previous_enrollment_id` int DEFAULT NULL,
  `enrollment_date` date DEFAULT NULL,
  `enrollment_status` enum('Active','Promoted','Completed','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uq_college_enrollment_number` (`college_id`,`enrollment_number`),
  UNIQUE KEY `uq_student_session` (`student_id`,`session_id`),
  UNIQUE KEY `uq_enrollment_student` (`enrollment_id`,`student_id`),
  UNIQUE KEY `uq_enrollment_context` (`enrollment_id`,`student_id`,`college_id`,`dept_id`,`course_id`,`session_id`,`academic_year_no`),
  KEY `fk_enrollment_student` (`college_id`,`student_id`),
  KEY `fk_enrollment_course` (`college_id`,`dept_id`,`course_id`),
  KEY `fk_enrollment_session` (`session_id`,`college_id`),
  KEY `fk_previous_enrollment_same_student` (`previous_enrollment_id`,`student_id`),
  KEY `idx_enrollment_session_course` (`college_id`,`session_id`,`dept_id`,`course_id`),
  CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`college_id`, `dept_id`, `course_id`) REFERENCES `course_details` (`college_id`, `dept_id`, `course_id`),
  CONSTRAINT `fk_enrollment_session` FOREIGN KEY (`session_id`, `college_id`) REFERENCES `academic_session_details` (`session_id`, `college_id`),
  CONSTRAINT `fk_enrollment_student` FOREIGN KEY (`college_id`, `student_id`) REFERENCES `student_details` (`college_id`, `student_id`),
  CONSTRAINT `fk_previous_enrollment_same_student` FOREIGN KEY (`previous_enrollment_id`, `student_id`) REFERENCES `enrollment_details` (`enrollment_id`, `student_id`),
  CONSTRAINT `enrollment_details_chk_1` CHECK ((`academic_year_no` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollment_details`
--

LOCK TABLES `enrollment_details` WRITE;
/*!40000 ALTER TABLE `enrollment_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `enrollment_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_assessment_details`
--

DROP TABLE IF EXISTS `exam_assessment_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_assessment_details` (
  `assessment_id` int NOT NULL AUTO_INCREMENT,
  `exam_id` int NOT NULL,
  `exam_subject_id` int NOT NULL,
  `assessment_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `maximum_marks` decimal(7,2) NOT NULL,
  `passing_marks` decimal(7,2) NOT NULL DEFAULT '0.00',
  `assessment_order` int DEFAULT NULL,
  PRIMARY KEY (`assessment_id`),
  UNIQUE KEY `uq_subject_assessment_name` (`exam_subject_id`,`assessment_name`),
  UNIQUE KEY `uq_assessment_exam_subject` (`assessment_id`,`exam_id`,`exam_subject_id`),
  KEY `fk_assessment_exam_subject` (`exam_subject_id`,`exam_id`),
  CONSTRAINT `fk_assessment_exam_subject` FOREIGN KEY (`exam_subject_id`, `exam_id`) REFERENCES `exam_subject_details` (`exam_subject_id`, `exam_id`),
  CONSTRAINT `exam_assessment_details_chk_1` CHECK ((`maximum_marks` > 0)),
  CONSTRAINT `exam_assessment_details_chk_2` CHECK (((`passing_marks` >= 0) and (`passing_marks` <= `maximum_marks`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_assessment_details`
--

LOCK TABLES `exam_assessment_details` WRITE;
/*!40000 ALTER TABLE `exam_assessment_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_assessment_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_details`
--

DROP TABLE IF EXISTS `exam_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_details` (
  `exam_id` int NOT NULL AUTO_INCREMENT,
  `curriculum_id` int NOT NULL,
  `exam_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `exam_type` enum('Regular','ATKT','Supplementary','Reassessment') COLLATE utf8mb4_unicode_ci NOT NULL,
  `exam_start_date` date DEFAULT NULL,
  `exam_end_date` date DEFAULT NULL,
  `exam_status` enum('Draft','Scheduled','Ongoing','Completed','Result_Published','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Draft',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`exam_id`),
  UNIQUE KEY `uq_exam_curriculum` (`exam_id`,`curriculum_id`),
  KEY `fk_exam_curriculum` (`curriculum_id`),
  KEY `fk_exam_creator` (`created_by`),
  KEY `idx_exam_status` (`exam_status`,`exam_type`),
  CONSTRAINT `fk_exam_creator` FOREIGN KEY (`created_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fk_exam_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `course_curriculum_details` (`curriculum_id`),
  CONSTRAINT `exam_details_chk_1` CHECK (((`exam_end_date` is null) or (`exam_start_date` is null) or (`exam_end_date` >= `exam_start_date`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_details`
--

LOCK TABLES `exam_details` WRITE;
/*!40000 ALTER TABLE `exam_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_subject_details`
--

DROP TABLE IF EXISTS `exam_subject_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_subject_details` (
  `exam_subject_id` int NOT NULL AUTO_INCREMENT,
  `exam_id` int NOT NULL,
  `curriculum_id` int NOT NULL,
  `course_subject_id` int NOT NULL,
  `maximum_marks` decimal(7,2) NOT NULL,
  `passing_marks` decimal(7,2) NOT NULL,
  `subject_order` int DEFAULT NULL,
  PRIMARY KEY (`exam_subject_id`),
  UNIQUE KEY `uq_exam_course_subject` (`exam_id`,`course_subject_id`),
  UNIQUE KEY `uq_exam_subject_exam` (`exam_subject_id`,`exam_id`),
  UNIQUE KEY `uq_exam_subject_context` (`exam_subject_id`,`exam_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_exam_subject_exam` (`exam_id`,`curriculum_id`),
  KEY `fk_exam_subject_curriculum_subject` (`course_subject_id`,`curriculum_id`),
  CONSTRAINT `fk_exam_subject_curriculum_subject` FOREIGN KEY (`course_subject_id`, `curriculum_id`) REFERENCES `course_subject_details` (`course_subject_id`, `curriculum_id`),
  CONSTRAINT `fk_exam_subject_exam` FOREIGN KEY (`exam_id`, `curriculum_id`) REFERENCES `exam_details` (`exam_id`, `curriculum_id`),
  CONSTRAINT `exam_subject_details_chk_1` CHECK ((`maximum_marks` > 0)),
  CONSTRAINT `exam_subject_details_chk_2` CHECK (((`passing_marks` >= 0) and (`passing_marks` <= `maximum_marks`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_subject_details`
--

LOCK TABLES `exam_subject_details` WRITE;
/*!40000 ALTER TABLE `exam_subject_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_subject_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_installment_details`
--

DROP TABLE IF EXISTS `fee_installment_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_installment_details` (
  `installment_id` int NOT NULL AUTO_INCREMENT,
  `enrollment_id` int NOT NULL,
  `installment_number` int NOT NULL,
  `fee_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_fee` decimal(10,2) NOT NULL,
  `due_date` date DEFAULT NULL,
  `installment_status` enum('Open','Closed','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Open',
  PRIMARY KEY (`installment_id`),
  UNIQUE KEY `uq_enrollment_installment` (`enrollment_id`,`installment_number`),
  CONSTRAINT `fk_installment_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollment_details` (`enrollment_id`),
  CONSTRAINT `fee_installment_details_chk_1` CHECK ((`installment_number` > 0)),
  CONSTRAINT `fee_installment_details_chk_2` CHECK ((`total_fee` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_installment_details`
--

LOCK TABLES `fee_installment_details` WRITE;
/*!40000 ALTER TABLE `fee_installment_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_installment_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_transaction_details`
--

DROP TABLE IF EXISTS `fee_transaction_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_transaction_details` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `installment_id` int NOT NULL,
  `paid_amount` decimal(10,2) NOT NULL,
  `payment_date` datetime NOT NULL,
  `payment_mode` enum('Cash','Online','Cheque','DD','Other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_reference` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_status` enum('Successful','Failed','Reversed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Successful',
  `received_by` int DEFAULT NULL,
  `remarks` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `fk_transaction_installment` (`installment_id`),
  KEY `fk_transaction_receiver` (`received_by`),
  KEY `idx_fee_transaction_date` (`payment_date`,`transaction_status`),
  CONSTRAINT `fk_transaction_installment` FOREIGN KEY (`installment_id`) REFERENCES `fee_installment_details` (`installment_id`),
  CONSTRAINT `fk_transaction_receiver` FOREIGN KEY (`received_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fee_transaction_details_chk_1` CHECK ((`paid_amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_transaction_details`
--

LOCK TABLES `fee_transaction_details` WRITE;
/*!40000 ALTER TABLE `fee_transaction_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_transaction_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission_details`
--

DROP TABLE IF EXISTS `permission_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_details` (
  `permission_id` int NOT NULL AUTO_INCREMENT,
  `permission_code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permission_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `module_name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permission_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `permission_code` (`permission_code`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission_details`
--

LOCK TABLES `permission_details` WRITE;
/*!40000 ALTER TABLE `permission_details` DISABLE KEYS */;
INSERT INTO `permission_details` VALUES (1,'COLLEGE_VIEW','View college information','College',NULL),(2,'COLLEGE_MANAGE','Manage college information','College',NULL),(3,'STUDENT_VIEW','View student information','Student',NULL),(4,'STUDENT_ADD','Add students','Student',NULL),(5,'STUDENT_EDIT','Edit students','Student',NULL),(6,'ENROLLMENT_MANAGE','Manage annual enrollment','Enrollment',NULL),(7,'PROMOTION_APPROVE','Approve student promotion','Enrollment',NULL),(8,'FEE_VIEW','View fees','Fees',NULL),(9,'FEE_MANAGE','Manage fees and payments','Fees',NULL),(10,'EXAM_MANAGE','Manage examinations','Examination',NULL),(11,'MARKS_ENTER','Enter examination marks','Examination',NULL),(12,'RESULT_PUBLISH','Approve and publish results','Examination',NULL),(13,'ATTENDANCE_MARK','Mark student attendance','Attendance',NULL),(14,'ATTENDANCE_VIEW','View attendance reports','Attendance',NULL),(15,'DOCUMENT_VIEW','View student documents','Documents',NULL),(16,'DOCUMENT_MANAGE','Upload and verify student documents','Documents',NULL),(17,'USER_MANAGE','Manage users and roles','Security',NULL);
/*!40000 ALTER TABLE `permission_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_admin_details`
--

DROP TABLE IF EXISTS `platform_admin_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_admin_details` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  `admin_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_platform_admin_role` (`user_id`,`role_id`),
  KEY `fk_platform_admin_role` (`role_id`),
  CONSTRAINT `fk_platform_admin_role` FOREIGN KEY (`role_id`) REFERENCES `role_details` (`role_id`),
  CONSTRAINT `fk_platform_admin_user` FOREIGN KEY (`user_id`) REFERENCES `user_details` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_admin_details`
--

LOCK TABLES `platform_admin_details` WRITE;
/*!40000 ALTER TABLE `platform_admin_details` DISABLE KEYS */;
INSERT INTO `platform_admin_details` VALUES (1,1,'Active','2026-11-09 15:46:11');
/*!40000 ALTER TABLE `platform_admin_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_details`
--

DROP TABLE IF EXISTS `role_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_details` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_details`
--

LOCK TABLES `role_details` WRITE;
/*!40000 ALTER TABLE `role_details` DISABLE KEYS */;
INSERT INTO `role_details` VALUES (1,'Super Admin','System-wide administrator'),(2,'College Admin','Administrator for an assigned college'),(3,'Admission Clerk','Manages student admission and enrollment'),(4,'Accountant','Manages fee installments and payments'),(5,'Examination Clerk','Manages examinations and marks entry'),(6,'Teacher','Manages assigned class attendance'),(7,'Student','Views own academic information');
/*!40000 ALTER TABLE `role_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission_details`
--

DROP TABLE IF EXISTS `role_permission_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission_details` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `fk_role_permission_permission` (`permission_id`),
  CONSTRAINT `fk_role_permission_permission` FOREIGN KEY (`permission_id`) REFERENCES `permission_details` (`permission_id`),
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `role_details` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission_details`
--

LOCK TABLES `role_permission_details` WRITE;
/*!40000 ALTER TABLE `role_permission_details` DISABLE KEYS */;
INSERT INTO `role_permission_details` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17);
/*!40000 ALTER TABLE `role_permission_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_details`
--

DROP TABLE IF EXISTS `student_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_details` (
  `student_id` int NOT NULL AUTO_INCREMENT,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `admission_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mother_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marital_status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `has_disability` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `caste` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `caste_category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `religion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `aadhaar_no` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `aadhaar_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `student_full_name_lfm` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `student_abc_id` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `curr_address` text COLLATE utf8mb4_unicode_ci,
  `curr_city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `curr_district` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `curr_state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `curr_city_pincode` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `per_address` text COLLATE utf8mb4_unicode_ci,
  `per_city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `per_district` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `per_state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `per_city_pincode` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `student_status` enum('Active','Inactive','Alumni') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `uq_college_admission` (`college_id`,`admission_number`),
  UNIQUE KEY `uq_college_student` (`college_id`,`student_id`),
  KEY `idx_student_name` (`college_id`,`last_name`,`first_name`),
  CONSTRAINT `fk_student_college` FOREIGN KEY (`college_id`) REFERENCES `college_details` (`college_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_details`
--

LOCK TABLES `student_details` WRITE;
/*!40000 ALTER TABLE `student_details` DISABLE KEYS */;
INSERT INTO `student_details` VALUES (1,'COL001','ADM2026001','Amit','Rajesh','Patil',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2002-06-14','Male','amit@example.com','9876543210',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Active','2026-11-09 11:28:08'),(2,'COL001','ADM2026003','Rahul','Kumar','Sharma','Sunita Sharma','Unmarried','No','Example Caste','General','Hindu','123456789012','Rahul Kumar Sharma','Sharma Rahul Kumar','ABC123456','2001-05-15','Male','rahul.updated@example.com','9876543212','Pune','Pune','Pune','Maharashtra','411001','Nashik','Nashik','Nashik','Maharashtra','422001','Inactive','2026-11-09 11:48:45');
/*!40000 ALTER TABLE `student_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_document_details`
--

DROP TABLE IF EXISTS `student_document_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_document_details` (
  `document_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type_id` int NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `storage_key` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uploaded_by` int DEFAULT NULL,
  `verification_status` enum('Pending','Verified','Rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `verified_by` int DEFAULT NULL,
  `verification_date` datetime DEFAULT NULL,
  `remarks` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  KEY `fk_student_document_type` (`document_type_id`),
  KEY `fk_student_document_uploader` (`uploaded_by`),
  KEY `fk_student_document_verifier` (`verified_by`),
  KEY `idx_document_student` (`college_id`,`student_id`,`document_type_id`),
  CONSTRAINT `fk_student_document_student` FOREIGN KEY (`college_id`, `student_id`) REFERENCES `student_details` (`college_id`, `student_id`),
  CONSTRAINT `fk_student_document_type` FOREIGN KEY (`document_type_id`) REFERENCES `document_type_details` (`document_type_id`),
  CONSTRAINT `fk_student_document_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fk_student_document_verifier` FOREIGN KEY (`verified_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `student_document_details_chk_1` CHECK (((`file_size_bytes` is null) or (`file_size_bytes` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_document_details`
--

LOCK TABLES `student_document_details` WRITE;
/*!40000 ALTER TABLE `student_document_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_document_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_exam_registration_details`
--

DROP TABLE IF EXISTS `student_exam_registration_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_exam_registration_details` (
  `registration_id` int NOT NULL AUTO_INCREMENT,
  `exam_id` int NOT NULL,
  `curriculum_id` int NOT NULL,
  `semester_enrollment_id` int NOT NULL,
  `registration_date` date DEFAULT NULL,
  `registration_status` enum('Registered','Eligible','Not_Eligible','Withdrawn') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Registered',
  PRIMARY KEY (`registration_id`),
  UNIQUE KEY `uq_exam_semester_enrollment` (`exam_id`,`semester_enrollment_id`),
  UNIQUE KEY `uq_registration_exam_curriculum` (`registration_id`,`exam_id`,`curriculum_id`),
  UNIQUE KEY `uq_registration_exam` (`registration_id`,`exam_id`),
  KEY `fk_registration_exam` (`exam_id`,`curriculum_id`),
  KEY `fk_registration_semester` (`semester_enrollment_id`,`curriculum_id`),
  CONSTRAINT `fk_registration_exam` FOREIGN KEY (`exam_id`, `curriculum_id`) REFERENCES `exam_details` (`exam_id`, `curriculum_id`),
  CONSTRAINT `fk_registration_semester` FOREIGN KEY (`semester_enrollment_id`, `curriculum_id`) REFERENCES `student_semester_enrollment_details` (`semester_enrollment_id`, `curriculum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_exam_registration_details`
--

LOCK TABLES `student_exam_registration_details` WRITE;
/*!40000 ALTER TABLE `student_exam_registration_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_exam_registration_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_exam_subject_registration_details`
--

DROP TABLE IF EXISTS `student_exam_subject_registration_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_exam_subject_registration_details` (
  `exam_subject_registration_id` int NOT NULL AUTO_INCREMENT,
  `registration_id` int NOT NULL,
  `exam_id` int NOT NULL,
  `curriculum_id` int NOT NULL,
  `semester_enrollment_id` int NOT NULL,
  `exam_subject_id` int NOT NULL,
  `course_subject_id` int NOT NULL,
  `selection_id` int NOT NULL,
  PRIMARY KEY (`exam_subject_registration_id`),
  UNIQUE KEY `uq_registration_exam_subject` (`registration_id`,`exam_subject_id`),
  UNIQUE KEY `uq_exam_subject_registration_context` (`exam_subject_registration_id`,`exam_id`,`exam_subject_id`),
  KEY `fk_student_exam_registration` (`registration_id`,`exam_id`,`curriculum_id`),
  KEY `fk_student_exam_subject` (`exam_subject_id`,`exam_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_student_exam_selection` (`selection_id`,`semester_enrollment_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_student_exam_semester` (`semester_enrollment_id`,`curriculum_id`),
  CONSTRAINT `fk_student_exam_registration` FOREIGN KEY (`registration_id`, `exam_id`, `curriculum_id`) REFERENCES `student_exam_registration_details` (`registration_id`, `exam_id`, `curriculum_id`),
  CONSTRAINT `fk_student_exam_selection` FOREIGN KEY (`selection_id`, `semester_enrollment_id`, `curriculum_id`, `course_subject_id`) REFERENCES `student_subject_selection_details` (`selection_id`, `semester_enrollment_id`, `curriculum_id`, `course_subject_id`),
  CONSTRAINT `fk_student_exam_semester` FOREIGN KEY (`semester_enrollment_id`, `curriculum_id`) REFERENCES `student_semester_enrollment_details` (`semester_enrollment_id`, `curriculum_id`),
  CONSTRAINT `fk_student_exam_subject` FOREIGN KEY (`exam_subject_id`, `exam_id`, `curriculum_id`, `course_subject_id`) REFERENCES `exam_subject_details` (`exam_subject_id`, `exam_id`, `curriculum_id`, `course_subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_exam_subject_registration_details`
--

LOCK TABLES `student_exam_subject_registration_details` WRITE;
/*!40000 ALTER TABLE `student_exam_subject_registration_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_exam_subject_registration_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_marks_details`
--

DROP TABLE IF EXISTS `student_marks_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_marks_details` (
  `marks_id` int NOT NULL AUTO_INCREMENT,
  `exam_subject_registration_id` int NOT NULL,
  `exam_id` int NOT NULL,
  `exam_subject_id` int NOT NULL,
  `assessment_id` int NOT NULL,
  `obtained_marks` decimal(7,2) DEFAULT NULL,
  `is_absent` tinyint(1) NOT NULL DEFAULT '0',
  `remarks` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entered_by` int DEFAULT NULL,
  `entered_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`marks_id`),
  UNIQUE KEY `uq_student_assessment` (`exam_subject_registration_id`,`assessment_id`),
  KEY `fk_marks_student_exam_subject` (`exam_subject_registration_id`,`exam_id`,`exam_subject_id`),
  KEY `fk_marks_assessment` (`assessment_id`,`exam_id`,`exam_subject_id`),
  KEY `fk_marks_entered_by` (`entered_by`),
  KEY `idx_marks_entered_at` (`entered_at`),
  CONSTRAINT `fk_marks_assessment` FOREIGN KEY (`assessment_id`, `exam_id`, `exam_subject_id`) REFERENCES `exam_assessment_details` (`assessment_id`, `exam_id`, `exam_subject_id`),
  CONSTRAINT `fk_marks_entered_by` FOREIGN KEY (`entered_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fk_marks_student_exam_subject` FOREIGN KEY (`exam_subject_registration_id`, `exam_id`, `exam_subject_id`) REFERENCES `student_exam_subject_registration_details` (`exam_subject_registration_id`, `exam_id`, `exam_subject_id`),
  CONSTRAINT `student_marks_details_chk_1` CHECK ((((`is_absent` = true) and (`obtained_marks` is null)) or ((`is_absent` = false) and (`obtained_marks` is not null) and (`obtained_marks` >= 0))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_marks_details`
--

LOCK TABLES `student_marks_details` WRITE;
/*!40000 ALTER TABLE `student_marks_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_marks_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_promotion_details`
--

DROP TABLE IF EXISTS `student_promotion_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_promotion_details` (
  `promotion_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `previous_enrollment_id` int NOT NULL,
  `new_enrollment_id` int DEFAULT NULL,
  `promotion_status` enum('Pending','Approved','Rejected','On_Hold') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `decision_date` date DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `remarks` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`promotion_id`),
  UNIQUE KEY `uq_promotion_new_enrollment` (`new_enrollment_id`),
  KEY `fk_promotion_previous` (`previous_enrollment_id`,`student_id`),
  KEY `fk_promotion_new` (`new_enrollment_id`,`student_id`),
  KEY `fk_promotion_approver` (`approved_by`),
  CONSTRAINT `fk_promotion_approver` FOREIGN KEY (`approved_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `fk_promotion_new` FOREIGN KEY (`new_enrollment_id`, `student_id`) REFERENCES `enrollment_details` (`enrollment_id`, `student_id`),
  CONSTRAINT `fk_promotion_previous` FOREIGN KEY (`previous_enrollment_id`, `student_id`) REFERENCES `enrollment_details` (`enrollment_id`, `student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_promotion_details`
--

LOCK TABLES `student_promotion_details` WRITE;
/*!40000 ALTER TABLE `student_promotion_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_promotion_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_result_details`
--

DROP TABLE IF EXISTS `student_result_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_result_details` (
  `result_id` int NOT NULL AUTO_INCREMENT,
  `registration_id` int NOT NULL,
  `exam_id` int NOT NULL,
  `total_marks` decimal(9,2) DEFAULT NULL,
  `maximum_marks` decimal(9,2) DEFAULT NULL,
  `percentage` decimal(6,2) DEFAULT NULL,
  `grade` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `result_status` enum('Pass','Fail','ATKT','Absent','Withheld','Pending') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `result_declaration_date` date DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  PRIMARY KEY (`result_id`),
  UNIQUE KEY `uq_registration_result` (`registration_id`),
  KEY `fk_overall_result_registration` (`registration_id`,`exam_id`),
  KEY `fk_result_approver` (`approved_by`),
  CONSTRAINT `fk_overall_result_registration` FOREIGN KEY (`registration_id`, `exam_id`) REFERENCES `student_exam_registration_details` (`registration_id`, `exam_id`),
  CONSTRAINT `fk_result_approver` FOREIGN KEY (`approved_by`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `student_result_details_chk_1` CHECK (((`total_marks` is null) or (`total_marks` >= 0))),
  CONSTRAINT `student_result_details_chk_2` CHECK (((`maximum_marks` is null) or (`maximum_marks` > 0))),
  CONSTRAINT `student_result_details_chk_3` CHECK (((`total_marks` is null) or (`maximum_marks` is null) or (`total_marks` <= `maximum_marks`))),
  CONSTRAINT `student_result_details_chk_4` CHECK (((`percentage` is null) or ((`percentage` >= 0) and (`percentage` <= 100))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_result_details`
--

LOCK TABLES `student_result_details` WRITE;
/*!40000 ALTER TABLE `student_result_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_result_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_semester_enrollment_details`
--

DROP TABLE IF EXISTS `student_semester_enrollment_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_semester_enrollment_details` (
  `semester_enrollment_id` int NOT NULL AUTO_INCREMENT,
  `enrollment_id` int NOT NULL,
  `student_id` int NOT NULL,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_id` int NOT NULL,
  `academic_year_no` int NOT NULL,
  `semester_id` int NOT NULL,
  `curriculum_id` int NOT NULL,
  `semester_enrollment_status` enum('Active','Completed','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`semester_enrollment_id`),
  UNIQUE KEY `uq_enrollment_semester` (`enrollment_id`,`semester_id`),
  UNIQUE KEY `uq_semester_enrollment_context` (`semester_enrollment_id`,`curriculum_id`),
  KEY `fk_sse_enrollment` (`enrollment_id`,`student_id`,`college_id`,`dept_id`,`course_id`,`session_id`,`academic_year_no`),
  KEY `fk_sse_curriculum` (`curriculum_id`,`college_id`,`dept_id`,`course_id`,`session_id`,`semester_id`,`academic_year_no`),
  CONSTRAINT `fk_sse_curriculum` FOREIGN KEY (`curriculum_id`, `college_id`, `dept_id`, `course_id`, `session_id`, `semester_id`, `academic_year_no`) REFERENCES `course_curriculum_details` (`curriculum_id`, `college_id`, `dept_id`, `course_id`, `session_id`, `semester_id`, `academic_year_no`),
  CONSTRAINT `fk_sse_enrollment` FOREIGN KEY (`enrollment_id`, `student_id`, `college_id`, `dept_id`, `course_id`, `session_id`, `academic_year_no`) REFERENCES `enrollment_details` (`enrollment_id`, `student_id`, `college_id`, `dept_id`, `course_id`, `session_id`, `academic_year_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_semester_enrollment_details`
--

LOCK TABLES `student_semester_enrollment_details` WRITE;
/*!40000 ALTER TABLE `student_semester_enrollment_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_semester_enrollment_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_subject_result_details`
--

DROP TABLE IF EXISTS `student_subject_result_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_subject_result_details` (
  `subject_result_id` int NOT NULL AUTO_INCREMENT,
  `exam_subject_registration_id` int NOT NULL,
  `exam_id` int NOT NULL,
  `exam_subject_id` int NOT NULL,
  `obtained_marks` decimal(8,2) DEFAULT NULL,
  `maximum_marks` decimal(8,2) DEFAULT NULL,
  `result_status` enum('Pass','Fail','Absent','Withheld','Pending') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `grade` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `calculated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`subject_result_id`),
  UNIQUE KEY `uq_subject_result_registration` (`exam_subject_registration_id`),
  KEY `fk_subject_result_exam_subject` (`exam_subject_registration_id`,`exam_id`,`exam_subject_id`),
  CONSTRAINT `fk_subject_result_exam_subject` FOREIGN KEY (`exam_subject_registration_id`, `exam_id`, `exam_subject_id`) REFERENCES `student_exam_subject_registration_details` (`exam_subject_registration_id`, `exam_id`, `exam_subject_id`),
  CONSTRAINT `student_subject_result_details_chk_1` CHECK (((`obtained_marks` is null) or (`obtained_marks` >= 0))),
  CONSTRAINT `student_subject_result_details_chk_2` CHECK (((`maximum_marks` is null) or (`maximum_marks` > 0))),
  CONSTRAINT `student_subject_result_details_chk_3` CHECK (((`obtained_marks` is null) or (`maximum_marks` is null) or (`obtained_marks` <= `maximum_marks`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_subject_result_details`
--

LOCK TABLES `student_subject_result_details` WRITE;
/*!40000 ALTER TABLE `student_subject_result_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_subject_result_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_subject_selection_details`
--

DROP TABLE IF EXISTS `student_subject_selection_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_subject_selection_details` (
  `selection_id` int NOT NULL AUTO_INCREMENT,
  `semester_enrollment_id` int NOT NULL,
  `curriculum_id` int NOT NULL,
  `course_subject_id` int NOT NULL,
  `selection_date` date DEFAULT NULL,
  `selection_status` enum('Selected','Dropped') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Selected',
  PRIMARY KEY (`selection_id`),
  UNIQUE KEY `uq_enrollment_course_subject` (`semester_enrollment_id`,`course_subject_id`),
  UNIQUE KEY `uq_selection_context` (`selection_id`,`semester_enrollment_id`,`curriculum_id`,`course_subject_id`),
  KEY `fk_selection_semester_enrollment` (`semester_enrollment_id`,`curriculum_id`),
  KEY `fk_selection_course_subject` (`course_subject_id`,`curriculum_id`),
  CONSTRAINT `fk_selection_course_subject` FOREIGN KEY (`course_subject_id`, `curriculum_id`) REFERENCES `course_subject_details` (`course_subject_id`, `curriculum_id`),
  CONSTRAINT `fk_selection_semester_enrollment` FOREIGN KEY (`semester_enrollment_id`, `curriculum_id`) REFERENCES `student_semester_enrollment_details` (`semester_enrollment_id`, `curriculum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_subject_selection_details`
--

LOCK TABLES `student_subject_selection_details` WRITE;
/*!40000 ALTER TABLE `student_subject_selection_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_subject_selection_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject_details`
--

DROP TABLE IF EXISTS `subject_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_details` (
  `subject_id` int NOT NULL AUTO_INCREMENT,
  `subject_code` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_description` text COLLATE utf8mb4_unicode_ci,
  `credits` decimal(5,2) NOT NULL DEFAULT '0.00',
  `subject_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`subject_id`),
  CONSTRAINT `subject_details_chk_1` CHECK ((`credits` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject_details`
--

LOCK TABLES `subject_details` WRITE;
/*!40000 ALTER TABLE `subject_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject_group_details`
--

DROP TABLE IF EXISTS `subject_group_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_group_details` (
  `group_id` int NOT NULL AUTO_INCREMENT,
  `curriculum_id` int NOT NULL,
  `group_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_type` enum('Compulsory','Elective') COLLATE utf8mb4_unicode_ci NOT NULL,
  `minimum_selection` int NOT NULL DEFAULT '1',
  `maximum_selection` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `uq_curriculum_group_name` (`curriculum_id`,`group_name`),
  UNIQUE KEY `uq_group_curriculum` (`group_id`,`curriculum_id`),
  CONSTRAINT `fk_group_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `course_curriculum_details` (`curriculum_id`),
  CONSTRAINT `subject_group_details_chk_1` CHECK ((`minimum_selection` >= 0)),
  CONSTRAINT `subject_group_details_chk_2` CHECK ((`maximum_selection` >= `minimum_selection`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject_group_details`
--

LOCK TABLES `subject_group_details` WRITE;
/*!40000 ALTER TABLE `subject_group_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_group_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_college_access_details`
--

DROP TABLE IF EXISTS `user_college_access_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_college_access_details` (
  `user_id` int NOT NULL,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `granted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`college_id`),
  KEY `fk_user_access_college` (`college_id`),
  CONSTRAINT `fk_user_access_college` FOREIGN KEY (`college_id`) REFERENCES `college_details` (`college_id`),
  CONSTRAINT `fk_user_access_user` FOREIGN KEY (`user_id`) REFERENCES `user_details` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_college_access_details`
--

LOCK TABLES `user_college_access_details` WRITE;
/*!40000 ALTER TABLE `user_college_access_details` DISABLE KEYS */;
INSERT INTO `user_college_access_details` VALUES (2,'COL1f7621cc0cce406a','Active','2026-11-09 16:42:26'),(3,'COLea329bdca58d4537','Active','2026-11-10 05:28:26'),(4,'COL306b050518bd4b9d','Inactive','2026-11-10 06:06:26');
/*!40000 ALTER TABLE `user_college_access_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_details`
--

DROP TABLE IF EXISTS `user_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_details` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mobile_number` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_status` enum('Active','Inactive','Locked') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_details`
--

LOCK TABLES `user_details` WRITE;
/*!40000 ALTER TABLE `user_details` DISABLE KEYS */;
INSERT INTO `user_details` VALUES (1,'Super_Admin','aakashclg876@gmail.com','scrypt:32768:8:1$LG6PE0ym3fd5YDzH$e0ad2922a450b1ae5ca09a9e18b7545439b72e74870480902c2666dce3e776599ddae18733064e03f514843db2d3158b68bca8325acc2621a3dab9c9b7d3e1d9','Neha Bendale',NULL,'Active','2026-11-09 15:46:11','2026-11-10 14:32:17'),(2,'ABC_Admin','rahul.admin@example.com','scrypt:32768:8:1$FhvYXreZKDFaxqrk$8fb20f8c240cc02db15d0b0f85a3354bebc43443b89eb5cce0cf4d0df5c1c75e88e7c4e247bdc465e0388d9456142733a9a5722831624d4cf0a4d53d812198d0','Rahul Sharma','9876543211','Active','2026-11-09 16:42:26','2026-11-10 09:34:46'),(3,'Aakash_college','akashbendale767@gmail.com','scrypt:32768:8:1$hFljXBxupuAhJtpV$734a1fd6976d305913b655d03f22d9838210308e0557f64d280a9f006327d849fb852f5ea67a6d22915fad0d1f9f0fdf3a71b6d99cff127adad7c5571ec44a22','Aakash Bendale','+91 1234567891','Active','2026-11-10 05:28:26','2026-11-10 14:01:18'),(4,'NA','NA@gmail.com','scrypt:32768:8:1$344pRzzlFg73EbLp$2fcd252a73afddd06f09791278b6102f5b8c7ab8ad4161772c908dc6fd930ce568ed434f52a1bbd5cf713a0a14f121ce94cc2b9a4a5de22ac0915eb06714a8be','NA','NA','Inactive','2026-11-10 06:06:26',NULL);
/*!40000 ALTER TABLE `user_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role_assignment_details`
--

DROP TABLE IF EXISTS `user_role_assignment_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_role_assignment_details` (
  `user_role_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `college_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int NOT NULL,
  `assigned_date` date NOT NULL,
  `assignment_status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`user_role_id`),
  UNIQUE KEY `uq_user_college_role` (`user_id`,`college_id`,`role_id`),
  KEY `fk_user_role_role` (`role_id`),
  CONSTRAINT `fk_user_role_access` FOREIGN KEY (`user_id`, `college_id`) REFERENCES `user_college_access_details` (`user_id`, `college_id`),
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `role_details` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role_assignment_details`
--

LOCK TABLES `user_role_assignment_details` WRITE;
/*!40000 ALTER TABLE `user_role_assignment_details` DISABLE KEYS */;
INSERT INTO `user_role_assignment_details` VALUES (1,2,'COL1f7621cc0cce406a',2,'2026-11-09','Active'),(2,3,'COLea329bdca58d4537',2,'2026-11-10','Active'),(3,4,'COL306b050518bd4b9d',2,'2026-11-10','Inactive');
/*!40000 ALTER TABLE `user_role_assignment_details` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-10 15:16:23
