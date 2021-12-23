---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 06 - Set Operators
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1
-- Explain the difference between the UNION ALL and UNION operators
-- In what cases are they equivalent?
-- When they are equivalent, which one should you use? -- The Union all includes duplicates, union does not. UNION should be used even if there are no duplicates.

-- 2
-- Write a query that generates a virtual auxiliary table of 10 numbers
-- in the range 1 through 10
-- Tables involved: no table-- Uses unions to join numbers together.
Select  1 as n
Union 
Select 2
Union 
Select 3
Union 
Select 4
Union 
Select 5
Union 
Select 6
Union 
Select 7
Union 
Select 8
Union 
Select 9
Union 
Select 10

--Desired output
-- 3
-- Write a query that returns customer and employee pairs 
-- that had order activity in January 2016 but not in February 2016
-- Tables involved: TSQLV4 database, Orders table-- First part before except is January 2016, the second part after is February 2016
Select customerid,employeeid
From [Sales].[Order]
Where month(orderdate)=1 and year(orderdate)=2016
EXCEPT
Select customerid,employeeid
From [Sales].[Order]
Where month(orderdate)=2 and year(orderdate)=2016;
-- 4
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2016 and February 2016
-- Tables involved: TSQLV4 database, Orders table--- Structure changed by replacing except with intersect 
Select customerid,employeeid
From [Sales].[Order]
Where month(orderdate)=1 and year(orderdate)=2016
Intersect 
Select customerid,employeeid
From [Sales].[Order]
Where month(orderdate)=2 and year(orderdate)=2016;
-- 5
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2016 and February 2016
-- but not in 2015: Query from question 4 is in parantheses and except part (with year 2015) is outside to prevent following of order of operations for SQL
(Select customerid,employeeid
From [Sales].[Order]
Where month(orderdate)=1 and year(orderdate)=2016
Intersect 
Select customerid,employeeid
From [Sales].[Order]
Where month(orderdate)=2 and year(orderdate)=2016)
EXCEPT
Select customerid,employeeid
From [Sales].[Order]
Where year(orderdate)=2015