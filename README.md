## 1. Overview
EduNetwork uses **MySQL** as its relational database management system. The database is designed using MySQL Workbench to support a centralized, scalable and multi-college educational management platform.

The database aims to maintain structured academic and administrative information while ensuring data consistency, integrity and secure access across multiple educational institutions.

**Database Name:** `college_management`

**Database Management System:** MySQL

**Database Design Tool:** MySQL Workbench

**Database Type:** Relational Database (RDBMS)

---

## 2. Database Objectives

The primary objectives of the EduNetwork database are:

- Maintain information for multiple educational institutions.
- Organize institutional, academic and administrative records.
- Maintain relationships between colleges, departments and courses.
- Support role-based user access.
- Ensure data integrity through primary keys and foreign keys.
- Prevent duplicate records using unique constraints.
- Maintain historical information through Active/Inactive status management.
- Provide a scalable structure for future modules.

---

## 3. Database Architecture

EduNetwork follows a relational database structure.

The database is designed to support multiple colleges within a single database while keeping their respective information logically separated.

### Main Database Modules

| Module | Purpose |
|---|---|
| College Management | Stores institutional information |
| Department Management | Maintains college departments |
| Course Management | Maintains courses offered by departments |
| User Management | Stores user account information |
| Role Management | Defines administrative roles |
| Access Management | Controls college-specific user access |
| Academic Management | Supports academic sessions, semesters and subjects |
| Student Management | Designed for student-related information |
| Examination Management | Designed for examination and result records |

*Some modules are planned for future development.*

---

## 4. Database Relationships

The database uses primary keys and foreign keys to establish relationships between tables.

The core institutional relationship is:

**College → Department → Course**

- One college can have multiple departments.
- Each department belongs to a specific college.
- One department can offer multiple courses.
- Course records are associated with their respective college and department.

The database also supports user, role and college access relationships to manage administrative permissions.

---

## 5. Database Design Principles

The following principles are considered during database development:

### Primary Keys (PK)
Primary keys uniquely identify records within their respective tables.

### Foreign Keys (FK)
Foreign keys establish relationships between related tables and help maintain referential integrity.

### Composite Primary Keys
Composite primary keys are used where a record's identity depends on more than one column.

For example, department identification is based on:

`(college_id, dept_id)`

### Unique Constraints
Unique constraints prevent duplicate values where uniqueness is required.

### ENUM Data Types
ENUM columns are used for predefined status values, such as:

- Active
- Inactive
- Pending
- Approved
- Rejected

### Data Integrity
NOT NULL constraints, unique constraints, primary keys and foreign keys help maintain reliable and consistent data.

---

## 6. Database File

This repository contains the MySQL database structure exported from MySQL Workbench.

| File | Description |
|---|---|
| `college_management_schema.sql` | Contains SQL statements for creating the database tables, relationships, constraints and indexes. |

**Note:** The exported schema file contains database structure only and does not include actual college, student or user records.

---

## 7. How to Import the Database Using MySQL Workbench

Follow these steps to recreate the EduNetwork database.

### Step 1: Open MySQL Workbench

Open MySQL Workbench and connect to your local MySQL server.

### Step 2: Open the SQL File

Go to:

`File → Open SQL Script`

Select:

`college_management_schema.sql`

### Step 3: Execute the SQL Script

Click the Execute button (lightning icon) to run the SQL statements.

### Step 4: Refresh the Schema List

In the Navigator panel:

1. Locate the Schemas section.
2. Right-click and select Refresh All.
3. Find `college_management`.

### Step 5: Verify Tables

Expand the database and open the Tables section to view the created tables.

---

## 8. Database Visualization Using MySQL Workbench

MySQL Workbench can be used to visualize database relationships through an Entity Relationship Diagram (ERD).

To create an ER diagram:

1. Open MySQL Workbench.
2. Select `Database → Reverse Engineer`.
3. Select your MySQL connection.
4. Choose the `college_management` schema.
5. Complete the wizard.
6. View the generated EER Diagram.

The diagram helps visualize tables, primary keys, foreign keys and relationships.

---

## 9. Future Database Enhancements

The database will be expanded to support additional educational and administrative modules, including:

- Student Admission and Enrollment
- Student and Teacher Management
- Academic Session Management
- Subject and Curriculum Management
- Semester Management
- Fee and Payment Management
- Attendance Management
- Examination and Result Management
- Document Management
- Reports and Analytics
- Advanced User Roles and Permissions

---

## 10. Project Status

**Database Development Status: Ongoing**

The EduNetwork database is being developed incrementally. New tables, relationships and constraints will be introduced as additional modules are implemented.

---

## 11. Technology

- MySQL
- MySQL Workbench
- SQL
- Relational Database Design
- Entity Relationship Diagrams (ERD)

---

**EduNetwork – Connecting Institutions, Simplifying Education.**
