## Solution For Practicals In MySQL Server.

1. Retrieve names of students enrolled in any society.
```sql
SELECT DISTINCT StudentName FROM STUDENT
INNER JOIN ENROLLMENT
ON STUDENT.RollNo = ENROLLMENT.RollNo;
```

2. Retrieve all society names.
```sql
SELECT SocName FROM SOCIETY;
```

3. Retrieve student's names starting with the letter ‘A’.
```sql
SELECT StudentName FROM STUDENT
WHERE StudentName LIKE "A%";
```

4. Retrieve student's details studying in courses ‘computer science’ or ‘chemistry’.
```sql
SELECT * FROM STUDENT
WHERE Course IN ('Comp Sci','Chemistry');
```

5. Retrieve student's names whose roll number either starts with ‘X’ or ‘Z’ and ends with ‘9’.
```sql
SELECT StudentName FROM STUDENT
WHERE RollNo LIKE 'X%9' OR RollNo LIKE 'Z%9';
```

6. Find society details with more than **N** TotalSeats where **N** is to be input by the user.
```sql
SET @N =15;
SELECT * FROM SOCIETY WHERE Totalseats > @N;
```

7. Update society table for the mentor name of a specific society.
```sql
UPDATE SOCIETY SET MentorName = 'Mr. Sonu' 
WHERE SocName = 'NCC';
```

8. Find society names in which more than five students have enrolled.
```sql
SELECT SocName FROM SOCIETY
INNER JOIN ENROLLMENT
ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY ENROLLMENT.SID
HAVING COUNT(ENROLLMENT.SID)>5;
```

9. Find the name of the youngest student enrolled in society ‘NSS’.
```sql
SELECT StudentName FROM STUDENT
INNER JOIN ENROLLMENT
ON STUDENT.RollNo = ENROLLMENT.RollNo
INNER JOIN SOCIETY
ON SOCIETY.SocID = ENROLLMENT.SID
WHERE SOCIETY.SocName = 'NSS'
ORDER BY STUDENT.DOB DESC
LIMIT 1;
```

10. Find the name of the most popular society (on the basis of enrolled students).
```sql
SELECT SocName FROM SOCIETY
INNER JOIN ENROLLMENT
ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY SOCIETY.SocID
ORDER BY COUNT(SOCIETY.SocID) DESC
LIMIT 1;
```

11. Find the name of two least popular societies (on the basis of enrolled students).
```sql
SELECT SocName FROM SOCIETY
INNER JOIN ENROLLMENT
ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY SOCIETY.SocID
ORDER BY COUNT(SOCIETY.SocID) ASC
LIMIT 2;
```

12. Find the students names who are not enrolled in any society.
```sql
SELECT StudentName FROM STUDENT
LEFT JOIN ENROLLMENT
ON STUDENT.RollNo = ENROLLMENT.RollNo
WHERE ENROLLMENT.RollNo IS NULL;
```

13. Find the students names enrolled in at least two societies.
```sql
SELECT StudentName FROM STUDENT
LEFT JOIN ENROLLMENT ON STUDENT.RollNo=ENROLLMENT.RollNo
GROUP BY STUDENT.StudentName
HAVING COUNT(STUDENT.RollNo) >= 2;
```

14. Find society names in which maximum students are enrolled.
```sql
SELECT SocName FROM SOCIETY
LEFT JOIN ENROLLMENT ON SOCIETY.SocID=ENROLLMENT.SID
GROUP BY SOCIETY.SocID
order BY COUNT(SOCIETY.SocID) DESC
LIMIT 1;
```

15. Find names of all students who have enrolled in any society and society names in which at least one student has enrolled.
```sql
(SELECT DISTINCT STUDENT.StudentName AS StudentSocietyName
FROM STUDENT
INNER JOIN ENROLLMENT ON STUDENT.RollNo = ENROLLMENT.RollNo)
UNION
(SELECT DISTINCT SOCIETY.SocName AS StudentSocietyName
FROM SOCIETY
INNER JOIN ENROLLMENT ON SOCIETY.SocID = ENROLLMENT.SID);
```

16. Find names of students who are enrolled in any of the three societies ‘Debating’, ‘Dancing’, and ‘Sashakt’.
```sql
SELECT DISTINCT STUDENT.StudentName FROM STUDENT
INNER JOIN ENROLLMENT ON ENROLLMENT.RollNo = STUDENT.RollNo
INNER JOIN SOCIETY ON SOCIETY.SocID = ENROLLMENT.SID
WHERE SOCIETY.SocName IN ('Debating','Dancing','Sashakt');
```

17. Find society names such that its mentor has a name with ‘Gupta’ in it.
```sql
SELECT SocName FROM SOCIETY WHERE MentorName LIKE '%Gupta%';
```

18. Find the society names in which the number of enrolled students is only 10% of its capacity.
```sql
SELECT SocName FROM SOCIETY
INNER JOIN ENROLLMENT ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY SOCIETY.SocID, SOCIETY.SocName, SOCIETY.TotalSeats
HAVING COUNT(ENROLLMENT.RollNo) = (SOCIETY.TotalSeats * 0.1);
```

19. Display the vacant seats for each society.
```sql
SELECT SocName,TotalSeats - COUNT(ENROLLMENT.SID) AS VacantSeats 
FROM SOCIETY
LEFT JOIN ENROLLMENT ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY SOCIETY.SocID, SOCIETY.SocName, SOCIETY.TotalSeats;
```

20. Increment Total Seats of each society by 10%.
```sql
UPDATE SOCIETY SET Totalseats = CEIL(Totalseats * 1.1);
SELECT SocName AS 'Society Name',Totalseats AS 'Total Seat' FROM SOCIETY;
```

21. Add the enrollment fees paid (‘yes’/’No’) field in the enrollment table.
```sql
ALTER TABLE ENROLLMENT ADD COLUMN FeesPaid ENUM('Yes', 'No') DEFAULT 'No';
DESC ENROLLMENT;
```

22. Update date of enrollment of society id ‘s1’ to ‘2018-01-15’, ‘s2’ to the current date, and ‘s3’ to ‘2018-01-02’.
```sql
UPDATE ENROLLMENT
SET DateOfEnrollment = CASE 
    WHEN SID = 's1' THEN '2018-01-15'
    WHEN SID = 's2' THEN CURDATE()
    WHEN SID = 's3' THEN '2018-01-02'
END
WHERE SID IN ('s1', 's2', 's3');
SELECT SID,DateOfEnrollment FROM ENROLLMENT
WHERE SID IN ('S1','S2','S3')
GROUP BY SID,DateOfEnrollment;
```

23. Create a view to keep track of society names with the total number of students enrolled in it.
```sql
CREATE VIEW EnrollmentOfSociety AS
SELECT SOCIETY.SocName, COUNT(ENROLLMENT.RollNo) AS TotalStudents FROM SOCIETY
LEFT JOIN ENROLLMENT ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY SOCIETY.SocID;
SELECT * FROM EnrollmentOfSociety;
```

24. Find student names enrolled in all the societies.
```sql
SELECT StudentName FROM STUDENT
INNER JOIN ENROLLMENT ON STUDENT.RollNo = ENROLLMENT.RollNo
GROUP BY ENROLLMENT.RollNo
HAVING COUNT(ENROLLMENT.SID) > (SELECT COUNT(*) FROM SOCIETY);
```

25. Count the number of societies with more than 5 students enrolled in it.
```sql
SELECT COUNT(*)  AS 'Number Of Society' FROM (SELECT SID FROM ENROLLMENT
GROUP BY SID HAVING COUNT(RollNo)> 5) AS SOCIETY;
```

26. Add column **Mobile number** in student table with default value **‘9999999999’**.
```sql
ALTER TABLE STUDENT ADD COLUMN MobileNumber VARCHAR(10) DEFAULT '9999999999';
DESC STUDENT;
```

27. Find the total number of students whose age is > 20 years.
```sql
SELECT COUNT(*) AS Students FROM STUDENT
WHERE TIMESTAMPDIFF(YEAR, DOB, CURDATE()) > 20;
```

28. Find names of students who were born in 2001 and are enrolled in at least one society.
```sql
SELECT DISTINCT StudentName FROM STUDENT
JOIN ENROLLMENT ON STUDENT.RollNo = ENROLLMENT.RollNo
WHERE YEAR(STUDENT.DOB) = 2001;
```

29. Count all societies whose name starts with ‘S’ and ends with ‘t’ and at least 5 students are enrolled in the society.
```sql
SELECT SocName FROM SOCIETY
INNER JOIN ENROLLMENT ON SOCIETY.SocID = ENROLLMENT.SID
WHERE SocName LIKE 'S%T'
GROUP BY ENROLLMENT.SID HAVING COUNT(ENROLLMENT.SID)>= 5;
```

30. **Display the following information:**
    - Society name
    - Mentor name
    - Total Capacity
    - Total Enrolled
    - Unfilled Seats
```sql
SELECT SocName AS "Society Name",
MentorName AS "Mentor Name",
Totalseats AS "Total Capacity",
COUNT(ENROLLMENT.RollNo) AS "Total Enrolled",
TotalSeats - COUNT(ENROLLMENT.RollNo) AS "Unfilled Seats" FROM SOCIETY
LEFT JOIN ENROLLMENT ON SOCIETY.SocID = ENROLLMENT.SID
GROUP BY SOCIETY.SocID;
```