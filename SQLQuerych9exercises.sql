---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 09 - Temporal Tables
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1
-- In this exercise you create a system-versioned temporal table and
-- identify it in SSMS.

-- 1-1
-- Create a system-versioned temporal table called Departments with
-- an associated history table called DepartmentsHistory in the
-- database TSQLV4. The table should have the following columns:
-- deptid INT, deptname VARCHAR(25) and mgrid INT, all disallowing NULLs.
-- Also include columns called validfrom and validto that define the
-- validity period of the row. Define those with precision zero (1 second)
-- and make them hidden.
CREATE TABLE dbo.Departments
(
  deptid      INT                         NOT NULL
    CONSTRAINT PK_Departments PRIMARY KEY NONCLUSTERED,
  deptname    VARCHAR(25)                 NOT NULL,
  mgrid      INT                    NOT NULL,
  validfrom   DATETIME2(0)
    GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
  validto     DATETIME2(0)
    GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
  PERIOD FOR SYSTEM_TIME (validfrom, validto),
)
WITH ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.DepartmentsHistory ) );
GO
-- 1-2
-- Browse the object tree in Object Explorer in SSMS and identify the
-- Departments table and its associated history table.

-- 2
-- In this exercise you will modify data in the table Departments.
-- Make a note of the point in time in UTC when you submit each
-- statement, and mark those as P1, P2, and so on. You can do so by
-- invoking the SYSUTCDATETIME function in the same batch that you
-- submit the modification. Another option is to query the Departments
-- table and its associated history table and to obtain the point in time
-- from the validfrom and validto columns.

-- 2-1
-- Insert four rows to the table Departments with the following details
-- and make a note of the time when you apply this insert (call it P1).
-- deptid: 1, deptname: HR, mgrid: 7
-- deptid: 2, deptname: IT, mgrid: 5
-- deptid: 3, deptname: Sales, mgrid: 11
-- deptid: 4, deptname: Marketing, mgrid: 13
Select Cast(Sysutcdatetime() as datetime2(0)) as P1; --Records P1
INSERT INTO dbo.Departments(deptid,deptname, mgrid)
  VALUES(1, 'HR', 7),
        (2, 'IT' , 5),
        (3, 'Sales', 11),
        (4, 'Marketing', 13)
-- 2-2
-- In one transaction, update the name of department 3 to Sales and Marketing
-- and delete department 4. Call the point in time when the transaction starts P2.
Select Cast(Sysutcdatetime() as datetime2(0)) as P2;  --Records P2
Begin TRAN;
UPDATE dbo.Departments
  SET deptname = 'Sales and Marketing'
WHERE deptid = 3;
GO
-- Run the following next
Delete From  dbo.Departments
WHERE deptid = 4;
COMMIT TRAN;

-- 2-3
-- Update the manager ID of department 3 to 13. Call the point in time
-- when you apply this update P2.
Select Cast(Sysutcdatetime() as datetime2(0)) as P3; --Records P3
UPDATE dbo.Departments
  SET mgrid=13
WHERE deptid = 3;
GO
-- 3
-- In this exercise you will query data from the table Departments.

-- 3-1
-- Query the current state of the table Departments.

-- Desired output:
Select * 
from dbo.Departments;
-- 3-2
-- Query the state of the table Departments at a point in time after P2
-- and before P3. P1 P2 and P3 are equal thus why both queries look same.
Select * --Queries Departments after P2
from dbo.Departments
  FOR SYSTEM_TIME as of '2021-12-10 19:34:00';
-- Desired output:

-- 3-3
-- Query the state of the table Departments in the period between P2 and P3.
-- Be explicit about the column names in the SELECT list,
-- and include the validfrom and validto columns).
Select deptid,deptname,mgrid,validfrom,validto --Queries Departments including validfrom and validto
from dbo.Departments
  FOR SYSTEM_TIME BETWEEN '2021-12-10 19:32:00' AND '2021-12-10 19:35:00';
-- Desired output (with validfrom and validto reflecting your modification times):


-- 4
-- Drop the table Departments and its associated history table.
ALTER TABLE dbo.Departments SET ( SYSTEM_VERSIONING = OFF );
DROP TABLE IF EXISTS dbo.DepartmentsHistory, dbo.Departments;