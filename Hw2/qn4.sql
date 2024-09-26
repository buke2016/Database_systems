import pandas as pd 
import psycopg2


# Establish a connection to the database
-- conn = psycopg2.connect("dbname=hw2 user=postgres password=19881114$")
-- cur = conn.cursor()

connection = psycopg2.connect(
    host="localhost",
    database="hw2",
    user="postgres",
    password="19881114$",
    port="5432" 
)
# Create a table
-- STUDENT Table:
CREATE TABLE STUDENT(
  Name VARCHAR(50)
  Student_number INT PRIMARY KEY,
  Class INT,
  Major VARCHAR(50)
);

-- COURSE Table:
CREATE TABLE COURSE(
  Course_name VARCHAR(50)
  Course_number INT PRIMARY KEY,
  credit_hours INT,
  Instructor VARCHAR(50)
);

-- SECTION Table:
CREATE TABLE SECTION(
  Section_identifier INT PRIMARY KEY,
  Course_number VARCHAR(10),
  Semester VARCHAR(10),
  YEAR INT,
  Instructor VARCHAR(50),
  FOREIGN KEY (Course_number) REFERENCES COURSE(Course_number)
);

-- GRADE_REPORT Table:
CREATE TABLE GRADE_REPORT(
  Student_number INT,
  Section_identifier INT,
  Grade CHAR(1),
  PRIMARY KEY (Student_number, Section_identifier),
  FOREIGN KEY (Student_number) REFERENCES STUDENT(Student_number),
  FOREIGN KEY (Section_identifier) REFERENCES SECTION(Section_identifier)
);

-- PREREQUISITE Table:
CREATE TABLE PREREQUISITE(
  Course_number VARCHAR(10),
  Prerequisite_number VARCHAR(10),
  PRIMARY KEY (Course_number, Prerequisite_number),
  FOREIGN KEY (Course_number) REFERENCES COURSE(Course_number),
  FOREIGN KEY (Prerequisite_number) REFERENCES COURSE(Course_number)
);

-- Insert data into STUDENT Table:
INSERT into student(Name, Student_number, Class, Major) VALUES
('Smith', 17,1,'CS'),
('Brown',8,2,'CS');

-- Insert data into COURSE Table:
INSERT INTO COURSE (Section_identifier, Course_number, Semester,Year, Instructor) VALUES
(85,'MATH2410','Fall',07,'Anderson'),
(92, 'CS1310', 'Fall', 07, 'Anderson'),
(102, 'CS3320', 'Spring', 08, 'Knuth'),
(112, 'MATH2410', 'Fall', 08, 'Chang'),
(119, 'CS1310', 'Fall', 08, 'Anderson'),
(135, 'CS3380', 'Fall', 08, 'Knuth');

-- insert data into GRADE_REPORT table:
INSERT INTO GRADE_REPORT (Student_number,Section_identifier,Grade) VALUES
(17,85,'A'),
(17,92,'B'),
(8,102,'C'),
(8,112,'B'),
(17,119,'A'),
(8,135,'A');

-- insert data into PREREQUISITE table:
INSERT INTO PREREQUISITE (Course_number, Prerequisite_number) VALUES
('CS3320','CS1310'),
('CS3380','CS3320'),
('CS3380','MATH2410');

-- VERIFY DATA ENTRY:
SELECT * FROM STUDENT;
SELECT * FROM COURSE;
SELECT * FROM SECTION;
SELECT * FROM GRADE_REPORT;
SELECT * FROM PREREQUISITE;

-- query = "SELECT * FROM STUDENT;"
-- df = pd.read_sql_query(query, connection)
-- print(df)

-- query = "SELECT * FROM COURSE;"
-- df = pd.read_sql_query(query, connection)
-- print(df)

-- query = "SELECT * FROM SECTION;"
-- df = pd.read_sql_query(query, connection)
-- print(df)

-- query = "SELECT * FROM GRADE_REPORT;"
-- df = pd.read_sql_query(query, connection)
-- print(df)

-- query = "SELECT * FROM PREREQUISITE;"
-- df = pd.read_sql_query(query, connection)
-- print(df)
-- connection.close()


-- Question 4:
a. Retrieve the names of all senior students majoring in ‘CS’ (computer science).
Senior students are classified as Class = 4, but the image does not show any students in Class 4. Assuming we are still working with that classification, the query is as follows:
SELECT Name
FROM STUDENT
WHERE Class = 4 AND Major = 'CS';

b. Retrieve the names of all courses taught by Professor King in 2007 and 2008.
SELECT DISTINCT C.Course_name
FROM COURSE C
JOIN SECTION S ON C.Course_number = S.Course_number
WHERE S.Instructor = 'King' AND S.YEAR IN (2007 , 2008);

c. For each section taught by Professor King, retrieve the course number, semester, year, and number of students who took the section.
SELECT S.Course_number, S.Semester, S.YEAR, COUNT(G.Student_number) AS Number_of_students
FROM SECTION S
JOIN GRADE_REPORT G ON S.Section_identifier = G.Section_identifier
WHERE S.Instructor = 'King'
GROUP BY S.Course_number, S.Semester, S.YEAR;

d. Retrieve the name and transcript of each senior student (Class = 4) majoring in CS.
SELECT S.Name, G.Grade
FROM STUDENT S
JOIN GRADE_REPORT G ON S.Student_number = G.Student_number
WHERE S.Class = 4 AND S.Major = 'CS';