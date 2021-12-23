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