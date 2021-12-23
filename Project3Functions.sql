use QueensClassSchedule
GO
CREATE FUNCTION Department.GetDepartment () Returns Table
AS
Return
 Select *
 From Department.Department
GO
CREATE FUNCTION Instructor.GetInstructor () Returns Table
AS
Return
 Select *
 From Instructor.Instructor
GO