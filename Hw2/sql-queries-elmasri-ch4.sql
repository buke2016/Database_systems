-- a. Retrieve the names of all senior students majoring in 'CS' (computer science).
SELECT Name
FROM STUDENT
WHERE Major = 'CS' AND Class = 4;

-- b. Retrieve the names of all courses taught by Professor King in 2007 and 2008.
SELECT DISTINCT C.Name
FROM COURSE C
JOIN SECTION S ON C.Course_number = S.Course_number
JOIN FACULTY F ON S.Instructor = F.SSN
WHERE F.Name = 'King' AND (S.Year = 2007 OR S.Year = 2008);

-- c. For each section taught by Professor King, retrieve the course number, semester, year, and number of students who took the section.
SELECT S.Course_number, S.Semester, S.Year, COUNT(G.Student_number) AS Number_of_Students
FROM SECTION S
JOIN FACULTY F ON S.Instructor = F.SSN
LEFT JOIN GRADE_REPORT G ON S.Section_identifier = G.Section_identifier
WHERE F.Name = 'King'
GROUP BY S.Section_identifier, S.Course_number, S.Semester, S.Year;

-- d. Retrieve the name and transcript of each senior student (Class = 4) majoring in CS.
SELECT S.Name, C.Name AS Course_Name, C.Course_number, C.Credit_hours, 
       SE.Semester, SE.Year, G.Grade
FROM STUDENT S
JOIN GRADE_REPORT G ON S.Student_number = G.Student_number
JOIN SECTION SE ON G.Section_identifier = SE.Section_identifier
JOIN COURSE C ON SE.Course_number = C.Course_number
WHERE S.Major = 'CS' AND S.Class = 4
ORDER BY S.Name, SE.Year, SE.Semester;
