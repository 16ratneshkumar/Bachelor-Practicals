# *Creating a Practical Component*

## **Database Creation**  
The database `Student-Society` is created to store student enrollment details in various societies.  

```sql
CREATE DATABASE Student_Society;
```
> Note: MySQL does not allow hyphens (`-`) in database names, so it is replaced with an underscore (`_`) or removed.  

Switch to the created database:  

```sql
USE Student_Society;
```

---

## **Table Structures**  

### **1. STUDENT Table**  
Stores student-related details like roll number, name, course, and date of birth.
```sql
CREATE TABLE STUDENT (
    RollNo CHAR(6) PRIMARY KEY,
    StudentName VARCHAR(20) NOT NULL,
    Course VARCHAR(10) NOT NULL,
    DOB DATE NOT NULL
    );
```

- `RollNo`: Unique identifier for each student (e.g., `S1001`, `X1002`).  
- `StudentName`: Full name of the student.  
- `Course`: Course in which the student is enrolled (e.g., `Computer Science`, `Biotechnology`).  
- `DOB`: Date of birth of the student.  

---

### **2. SOCIETY Table**  
Stores information about societies in the institution.  

```sql
CREATE TABLE SOCIETY (
    SocID CHAR(6) PRIMARY KEY,
    SocName VARCHAR(20) NOT NULL,
    MentorName VARCHAR(15) NOT NULL,
    TotalSeats INT UNSIGNED NOT NULL
    );
```

- `SocID`: Unique identifier for each society (e.g., `SOC001`).  
- `SocName`: Name of the society (e.g., `NCC`, `Debating Club`).  
- `MentorName`: Faculty mentor overseeing the society.  
- `TotalSeats`: Maximum capacity of the society. 

---

### **3. ENROLLMENT Table**  
Maintains the relationship between students and societies, storing their enrollment date.  

```sql
CREATE TABLE ENROLLMENT (
    RollNo CHAR(6) NOT NULL,
    SID CHAR(6) NOT NULL,
    DateOfEnrollment DATE,
    PRIMARY KEY (RollNo, SID),
    FOREIGN KEY (RollNo) REFERENCES STUDENT(RollNo) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (SID) REFERENCES SOCIETY(SocID) ON DELETE CASCADE ON UPDATE CASCADE
    );
```

- `RollNo`: Foreign key referencing `STUDENT(RollNo)`, ensuring every enrollment links to a valid student.  
- `SID`: Foreign key referencing `SOCIETY(SocID)`, ensuring enrollment is associated with an existing society.  
- `DateOfEnrollment`: The date on which the student joined the society.  
- `ON DELETE CASCADE`: If a student or society is removed, related enrollments are automatically deleted.  
- `ON UPDATE CASCADE`: Ensures that if a student's RollNo or a Society's ID changes, it is updated in all related records.  

---

## **Data Insertion**  

### **1. Insert Student Data** 
```sql
INSERT INTO STUDENT (RollNo, StudentName, Course, DOB) VALUES
('S1001', 'ISHIKA PURAKAYASTHA', 'Statistics', '1999-01-15'),
('S1002', 'Arun Kumar', 'Statistics', '1999-03-22'),
('S1003', 'NISHANT SINGH', 'Statistics', '1999-05-10'),
('S1004', 'RENUKA', 'Statistics', '1999-07-08'),
('X1001', 'Priyanka Saini', 'Statistics', '1999-09-25'),
('X1002', 'Aditya Chaturvedi', 'Statistics', '2000-02-18'),
('Z1001', 'AHSANA FATHIMA', 'Statistics', '2000-04-05'),
('Z1002', 'AKSHAT GUPTA', 'Statistics', '2000-06-30'),
('Z1003', 'Bhumika Yadav', 'Statistics', '2000-08-12'),
('S1005', 'Geetanshu', 'Chemistry', '2000-11-27'),
('S1006', 'Kohana Bhalla', 'Chemistry', '2001-01-19'),
('S1007', 'Nitisha Agrawal', 'Chemistry', '2001-03-15'),
('X1003', 'Rashmi Bisht', 'Chemistry', '2001-05-25'),
('X1004', 'Ajay', 'Chemistry', '2001-07-21'),
('Z1004', 'YOGESH JAISWAL', 'Chemistry', '2001-10-10'),
('Z1005', 'Aditya Bisht', 'Chemistry', '2002-02-05'),
('S1008', 'KSHITIZ SADH', 'Comp Sci', '2002-04-22'),
('S1009', 'PIYUSH KUSHWAHA', 'Comp Sci', '2002-06-15'),
('S1010', 'Priyanshu Sisodiya', 'Comp Sci', '2002-08-30'),
('S1011', 'RAHUL BANSAL', 'Comp Sci', '2002-11-02'),
('S1012', 'RATNESH KUMAR', 'Comp Sci', '2003-01-28'),
('S1013', 'SHIV KUMAR', 'Comp Sci', '2003-03-19'),
('S1014', 'SOURABH KUMAR', 'Comp Sci', '2003-05-14'),
('X1005', 'Sujal Singh', 'Comp Sci', '2003-07-29'),
('X1006', 'Sumit Kumar', 'Comp Sci', '2003-09-10'),
('X1007', 'Avnish Rana', 'Comp Sci', '2004-02-14'),
('Z1006', 'Shubham Kapoor', 'Comp Sci', '2004-04-09'),
('Z1007', 'Arjun Pahariya', 'Comp Sci', '2004-06-23'),
('Z1008', 'RAJ SINGH', 'Comp Sci', '2004-08-05'),
('Z1009', 'VISHNU', 'Comp Sci', '2004-10-31'),
('S1015', 'Panchika Agrawal', 'Biotech', '2005-01-05'),
('X1008', 'ANANYA', 'Biotech', '2005-03-12'),
('Z1010', 'ANSHUL KASANA', 'Biotech', '2005-05-20'),
('S1016', 'JAGRIT GUPTA', 'Electronic', '2005-07-25'),
('S1017', 'Kanishka Saini', 'Electronic', '2005-09-18'),
('S1018', 'LOVISH JAIN', 'Electronic', '2006-02-08'),
('S1019', 'NIKUNJ AGRAWAL', 'Electronic', '2006-04-30'),
('X1009', 'PARTH BUDHIRAJA', 'Electronic', '2006-06-11'),
('X1010', 'SUNNY', 'Electronic', '2006-08-24'),
('X1011', 'Ujjwal Dhama', 'Electronic', '2006-10-15'),
('X1017', 'Ujjawal Tyagi', 'Electronic', '2007-01-07'),
('X1018', 'YAMINI', 'Physics', '2007-03-22'),
('S1020', 'YOGITA GUPTA', 'Maths', '2007-05-19'),
('S1021', 'Vansh Banderwal', 'Maths', '2007-07-09'),
('S1022', 'Suryash Vaibhav', 'Maths', '2007-09-28'),
('X1012', 'Mr. Rahul', 'Maths', '2008-02-02'),
('Z1011', 'HARSH DUBEY', 'Maths', '2008-04-11'),
('Z1012', 'RISHABH GUPTA', 'Maths', '2008-06-17'),
('S1023', 'RUPESH KUMAR', 'Physics', '2008-08-29'),
('S1024', 'VIKASH KUMAR', 'Physics', '2008-10-14'),
('S1025', 'AYUSH TIWARI', 'Physics', '2009-01-21'),
('S1026', 'Amit Pal', 'Physics', '2009-03-05'),
('S1027', 'Deepa', 'Physics', '2009-05-27'),
('X1013', 'KESHAV KHANDELWAL', 'Physics', '2009-07-31'),
('X1014', 'Mridul Gupta', 'Physics', '2009-09-19'),
('X1015', 'MUKUL ARORA', 'Physics', '2010-02-11'),
('X1016', 'SUJIT KUMAR YADAV', 'Physics', '2010-04-15'),
('Z1013', 'Prachi Kumari', 'Physics', '2010-06-28'),
('Z1014', 'Vishal', 'Physics', '2010-08-17'),
('Z1015', 'Prayag Kaushik', 'Physics', '2010-10-30'),
('Z1016', 'Avantika', 'Physics', '1999-09-25');
```
> More students can be added similarly.

---
### **2. Insert Society Data** 
```sql
INSERT INTO SOCIETY VALUES
('S1', 'NCC', 'Dr. Sharma', 20),
('S2', 'NSS', 'Dr. Gupta', 15),
('S3', 'Debating', 'Mr. Mehta', 10),
('S4', 'Dancing', 'Ms. Singh', 20),
('S5', 'Sashakt', 'Dr. Yadav', 10),
('S6', 'Tech Club', 'Ms. Verma', 20),
('S7', 'Photography', 'Ms. Kapoor', 5),
('S8', 'Neev', 'Dr. Kumar', 20);
```
> This ensures multiple societies are available for students.

---

### **3. Insert Enrollment Data**  
```sql
INSERT INTO ENROLLMENT VALUES
('S1001', 'S1', '2023-08-21'),
('S1001', 'S8', '2023-07-25'),
('S1002', 'S2', '2024-08-28'),
('S1003', 'S3', '2024-10-14'),
('X1001', 'S5', '2024-10-05'),
('X1002', 'S1', '2024-09-11'),
('S1001', 'S7', '2023-05-12'),
('Z1002', 'S1', '2024-02-01'),
('S1005', 'S3', '2024-06-03'),
('S1006', 'S2', '2023-09-16'),
('S1007', 'S1', '2023-05-26'),
('X1003', 'S6', '2023-12-03'),
('X1004', 'S1', '2024-06-11'),
('Z1004', 'S1', '2024-06-22'),
('S1008', 'S3', '2023-08-17'),
('S1009', 'S1', '2025-02-03'),
('S1010', 'S2', '2023-08-04'),
('S1001', 'S6', '2023-05-23'),
('S1012', 'S1', '2023-09-11'),
('S1013', 'S1', '2024-04-06'),
('X1005', 'S3', '2023-04-07'),
('X1006', 'S1', '2024-05-18'),
('X1007', 'S5', '2025-01-08'),
('Z1006', 'S6', '2023-08-05'),
('Z1007', 'S7', '2023-12-07'),
('Z1008', 'S1', '2024-12-31'),
('Z1009', 'S2', '2023-09-01'),
('S1015', 'S3', '2023-03-24'),
('S1001', 'S4', '2023-08-04'),
('S1001', 'S5', '2023-10-19'),
('S1002', 'S6', '2024-11-09'),
('S1002', 'S7', '2024-04-30'),
('S1018', 'S1', '2024-07-02'),
('S1019', 'S2', '2024-03-04'),
('X1009', 'S3', '2025-01-07'),
('X1011', 'S5', '2023-09-04'),
('X1017', 'S6', '2024-06-14'),
('X1018', 'S7', '2023-06-22'),
('S1020', 'S1', '2024-09-30'),
('S1022', 'S3', '2024-11-14'),
('X1012', 'S4', '2024-09-18'),
('Z1011', 'S5', '2023-11-03'),
('Z1012', 'S2', '2024-10-22'),
('S1024', 'S1', '2023-11-14'),
('S1001', 'S3', '2023-07-15'),
('S1001', 'S2', '2023-09-30'),
('X1013', 'S5', '2023-12-15'),
('X1014', 'S6', '2023-09-09'),
('X1015', 'S7', '2023-12-29');
```
> Each entry represents a student's membership in a society.

---