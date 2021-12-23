---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 06 - Set Operators
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

SET NOCOUNT ON
USE Northwinds2020TSQLV6;

---------------------------------------------------------------------
-- The UNION Operator
---------------------------------------------------------------------

-- The UNION ALL Multiset Operator 1 Results of customer region and city from both Employee and Customer combined
SELECT (employeecountry) as country, (employeeregion) as region,(employeecity) as city FROM HumanResources.Employee
UNION ALL
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer;

-- The UNION Distinct Set Operator 2 Results of customer region and city from both Employee and Customer combined but with duplicates removed
SELECT (employeecountry) as country, (employeeregion) as region,(employeecity) as city FROM HumanResources.Employee
UNION
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer;

---------------------------------------------------------------------
-- The INTERSECT Operator
---------------------------------------------------------------------

-- The INTERSECT Distinct Set Operator 3  All places where both an employee and customer come from
SELECT (employeecountry) as country, (employeeregion) as region,(employeecity) as city FROM HumanResources.Employee
INTERSECT
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer;

-- The INTERSECT ALL Multiset Operator (Optional, Advanced) 
--4 All places where both an employee and customer come from duplicates not removed
SELECT
  ROW_NUMBER() 
    OVER(PARTITION BY employeecountry, employeeregion, employeecity
         ORDER     BY (SELECT 0)) AS rownum,
  (employeecountry) as country, (employeeregion) as region, (employeecity) as city
FROM HumanResources.Employee

INTERSECT

SELECT
  ROW_NUMBER() 
    OVER(PARTITION BY customercountry, customerregion, customercity
         ORDER     BY (SELECT 0)),
  (customercountry) as country,(customerregion) as region,(customercity) as city
FROM Sales.Customer;

WITH INTERSECT_ALL --5 All places where both an employee and customer come from duplicates not removed
AS
(
  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY employeecountry, employeeregion, employeecity
           ORDER     BY (SELECT 0)) AS rownum,
  (employeecountry) as country, (employeeregion) as region, (employeecity) as city
  FROM HumanResources.Employee

  INTERSECT

  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY customercountry, customerregion, customercity
           ORDER     BY (SELECT 0)) AS rownum,
  (customercountry) as country,(customerregion) as region,(customercity) as city
  FROM Sales.Customer
)
SELECT country, region, city
FROM INTERSECT_ALL;

---------------------------------------------------------------------
-- The EXCEPT Operator
---------------------------------------------------------------------

-- The EXCEPT Distinct Set Operator

-- Employees EXCEPT Customers 6 Customer locations only
SELECT (employeecountry) as country, (employeeregion) as region,(employeecity) as city FROM HumanResources.Employee
EXCEPT
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer;

-- Customers EXCEPT Employees 7 Employee locations only
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer
EXCEPT
SELECT (employeecountry) as country, (employeeregion) as region,(employeecity) as city FROM HumanResources.Employee;

-- The EXCEPT ALL Multiset Operator (Optional, Advanced) 8 Employee only locations duplicates not removed
WITH EXCEPT_ALL
AS
(
  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY employeecountry, employeeregion, employeecity
           ORDER     BY (SELECT 0)) AS rownum,
  (employeecountry) as country, (employeeregion) as region, (employeecity) as city
  FROM HumanResources.Employee

  EXCEPT

  SELECT
    ROW_NUMBER() 
      OVER(PARTITION BY customercountry, customerregion, customercity
           ORDER     BY (SELECT 0)),
  (customercountry) as country,(customerregion) as region,(customercity) as city
  FROM Sales.Customer
)
SELECT country, region, city
FROM EXCEPT_ALL;

---------------------------------------------------------------------
-- Precedence
---------------------------------------------------------------------

-- INTERSECT Precedes EXCEPT 9 elements in Supplier but not intersect of employee and customer
SELECT (suppliercountry) as country,(supplierregion) as region,(suppliercity) as city FROM Production.Supplier
EXCEPT
SELECT (employeecountry) as country,(employeeregion) as region,(employeecity) as city FROM HumanResources.Employee
INTERSECT
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer;

-- Using Parenthesis 10 Elements in supplier but not employer intersected with customer
(SELECT (suppliercountry) as country,(supplierregion) as region,(suppliercity) as city FROM Production.Supplier
 EXCEPT
 SELECT (employeecountry) as country,(employeeregion) as region,(employeecity) as city FROM HumanResources.Employee)
INTERSECT
SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer;

---------------------------------------------------------------------
-- Circumventing Unsupported Logical Phases
-- (Optional, Advanced)
---------------------------------------------------------------------

-- Number of distinct locations 11
-- that are either employee or customer locations in each country Employee and customer locations
SELECT country, COUNT(*) AS numlocations
FROM (SELECT (employeecountry) as country, (employeeregion) as region,(employeecity) as city FROM HumanResources.Employee
      UNION
      SELECT (customercountry) as country,(customerregion) as region,(customercity) as city FROM Sales.Customer) AS U
GROUP BY country;

-- Two most recent orders for employees 3 and 5 12 The top two recent orders for 3 and 5
SELECT employeeid, orderid, orderdate
FROM (SELECT TOP (2) employeeid, orderid, orderdate
      FROM [Sales].[Order]
      WHERE employeeid = 3
      ORDER BY orderdate DESC, orderid DESC) AS D1

UNION ALL

SELECT employeeid, orderid, orderdate
FROM (SELECT TOP (2) employeeid, orderid, orderdate
      FROM [Sales].[Order]
      WHERE employeeid = 5
      ORDER BY orderdate DESC, orderid DESC) AS D2;
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
-- Tables involved: no table
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
-- Tables involved: TSQLV4 database, Orders table
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
-- Tables involved: TSQLV4 database, Orders table
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
-- but not in 2015
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