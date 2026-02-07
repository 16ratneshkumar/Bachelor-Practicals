# DSC-11 Database Management Systems

![Course](https://img.shields.io/badge/Course-DSC--11-blue.svg?style=for-the-badge)

Welcome to the collection of practical assignments for the **Database Management Systems** course.

---

## 📅 List of Practical

1) [Retrieve names of students enrolled in any society.](./Practical.md#L3-L8)
2) [Retrieve all society names.](./Practical.md#L10-L13)
3) [Retrieve student's names starting with the letter ‘A’.](./Practical.md#L15-L19)
4) [Retrieve student's details studying in courses ‘computer science’ or ‘chemistry’.](./Practical.md#L21-L25)
5) [Retrieve student's names whose roll number either starts with ‘X’ or ‘Z’ and ends with ‘9’.](./Practical.md#L27-L31)
6) [Find society details with more than **N** TotalSeats where **N** is to be input by the user.](./Practical.md#L33-L37)
7) [Update society table for the mentor name of a specific society.](./Practical.md#L39-L43)
8) [Find society names in which more than five students have enrolled.](./Practical.md#L45-L52)
9) [Find the name of the youngest student enrolled in society ‘NSS’.](./Practical.md#L54-L64)
10) [Find the name of the most popular society (on the basis of enrolled students).](./Practical.md#L66-L74)
11) [Find the name of two least popular societies (on the basis of enrolled students).](./Practical.md#L76-L84)
12) [Find the students names who are not enrolled in any society.](./Practical.md#L86-L92)
13) [Find the students names enrolled in at least two societies.](./Practical.md#L94-L100)
14) [Find society names in which maximum students are enrolled.](./Practical.md#L102-L109)
15) [Find names of all students who have enrolled in any society and society names in which at least one student has enrolled.](./Practical.md#L111-L120)
16) [Find names of students who are enrolled in any of the three societies ‘Debating’, ‘Dancing’, and ‘Sashakt’.](./Practical.md#L122-L128)
17) [Find society names such that its mentor has a name with ‘Gupta’ in it.](./Practical.md#L130-L133)
18) [Find the society names in which the number of enrolled students is only 10% of its capacity.](./Practical.md#L135-L141)
19) [Display the vacant seats for each society.](./Practical.md#L143-L149)
20) [Increment Total Seats of each society by 10%.](./Practical.md#L151-L155)
21) [Add the enrollment fees paid (‘yes’/’No’) field in the enrollment table.](./Practical.md#L157-L161)
22) [Update date of enrollment of society id ‘s1’ to ‘2018-01-15’, ‘s2’ to the current date, and ‘s3’ to ‘2018-01-02’.](./Practical.md#L163-L175)
23) [Create a view to keep track of society names with the total number of students enrolled in it.](./Practical.md#L177-L184)
24) [Find student names enrolled in all the societies.](./Practical.md#L186-L192)
25) [Count the number of societies with more than 5 students enrolled in it.](./Practical.md#L194-L198)
26) [Add column **Mobile number** in student table with default value **‘9999999999’**.](./Practical.md#L200-L204)
27) [Find the total number of students whose age is > 20 years.](./Practical.md#L206-L210)
28) [Find names of students who were born in 2001 and are enrolled in at least one society.](./Practical.md#L212-L217)
29) [Count all societies whose name starts with ‘S’ and ends with ‘t’ and at least 5 students are enrolled in the society.](./Practical.md#L219-L225)
30) [Display society name, mentor name, total capacity, total enrolled, and unfilled seats.](./Practical.md#L227-L241)

---

## 🛠️ Database Administration Commands

- [Create user](./Database%20Administration%20Commands.md#L3-L10)
- [Create role](./Database%20Administration%20Commands.md#L23-L29)
- [Grant privileges to a role](./Database%20Administration%20Commands.md#L42-L48)
- [Revoke privileges from a role](./Database%20Administration%20Commands.md#L55-L60)
- [Create index](./Database%20Administration%20Commands.md#L61-L67)

---

## 📊 Database Schema

### STUDENT  
| **Roll No** | **StudentName** | **Course** | **DOB** |
|------------|---------------|------------|--------|
| *Char(6)*  | *Varchar(20)* | *Varchar(10)* | *Date* |

### SOCIETY  
| **SocID**  | **SocName**   | **MentorName**  | **TotalSeats**  |
|-----------|-------------|---------------|--------------|
| *Char(6)*  | *Varchar(20)* | *Varchar(15)* | *Unsigned int* |

### ENROLLMENT  
| **Roll No** | **SID**   | **DateOfEnrollment** |
|------------|---------|--------------------|
| *Char(6)*  | *Char(6)* | *Date*            |


> ***NOTE***: **RollNo** (ENROLLMENT) and **SID** (ENROLLMENT) are foreign keys referencing STUDENT and SOCIETY tables respectively.

---

<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>


