---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 04 - Subqueries
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Self-Contained Subqueries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Scalar Subqueries
---------------------------------------------------------------------

-- Order with the maximum order ID 1: prints the order with the highest orderid
USE Northwinds2020TSQlv6
DECLARE @maxid AS INT = (SELECT MAX(orderid)
                         FROM [Sales].[Order]);

SELECT orderid, orderdate, employeeid, customerid
FROM [Sales].[Order]
WHERE orderid = @maxid;
GO
--2:Same as 1, prints order with highest orderid
SELECT orderid, orderdate, employeeid, customerid
FROM [Sales].[Order]
WHERE orderid = (SELECT MAX(O.orderid)
                 FROM [Sales].[Order] AS O);

-- Scalar subquery expected to return one value 3: Returns orderid where employee last name begins with C
SELECT orderid
FROM [Sales].[Order]
WHERE employeeid = 
  (SELECT E.employeeid
   FROM [HumanResources].[Employee] AS E
   WHERE E.employeelastname LIKE N'C%');
GO
--4: Returns orderid where employee last name begins with D (None returned because =)
SELECT orderid
FROM [Sales].[Order]
WHERE employeeid = 
  (SELECT E.employeeid
   FROM [HumanResources].[Employee] AS E
   WHERE E.employeelastname LIKE N'D%');
GO
--5: Returns orderid where employee last name begins with A (None returned because =)
SELECT orderid
FROM [Sales].[Order]
WHERE employeeid = 
  (SELECT E.employeeid
   FROM [HumanResources].[Employee] AS E
   WHERE E.employeelastname LIKE N'A%');

---------------------------------------------------------------------
-- Multi-Valued Subqueries
---------------------------------------------------------------------
--6: Returns orderid where employee last name begins with D (returned because in)
SELECT orderid
FROM [Sales].[Order]
WHERE employeeid IN
  (SELECT E.employeeid
   FROM [HumanResources].[Employee] AS E
   WHERE E.employeelastname LIKE N'D%');
--7: Returns orderid where employee last name begins with D 
SELECT O.orderid
FROM [HumanResources].[Employee] AS E
  INNER JOIN [Sales].[Order] AS O
    ON E.employeeid = O.employeeid
WHERE E.employeelastname LIKE N'D%';

-- Orders placed by US customers 8: Orders from the USA
SELECT customerid, orderid, orderdate, employeeid
FROM [Sales].[Order]
WHERE customerid IN
  (SELECT C.customerid
   FROM [Sales].[Customer] AS C
   WHERE C.customercountry = N'USA');

-- Customers who placed no orders 9:Customers with no orders
SELECT customerid, customercompanyname
FROM [Sales].[Customer]
WHERE customerid NOT IN
  (SELECT O.customerid
   FROM [Sales].[Order] AS O);

-- Missing order IDs 10: All odd order numbers 
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);

INSERT INTO dbo.Orders(orderid)
  SELECT orderid --Even order numbers in table
  FROM [Sales].[Order]
  WHERE orderid % 2 = 0;

SELECT n --Odd orders
FROM dbo.Nums
WHERE n BETWEEN (SELECT MIN(O.orderid) FROM dbo.Orders AS O)
            AND (SELECT MAX(O.orderid) FROM dbo.Orders AS O)
  AND n NOT IN (SELECT O.orderid FROM dbo.Orders AS O);

-- CLeanup
DROP TABLE IF EXISTS dbo.Orders;

---------------------------------------------------------------------
-- Correlated Subqueries
---------------------------------------------------------------------

-- Orders with maximum order ID for each customer
-- Listing 4-1: Correlated Subquery
--11: This is the maximum order for each customer
SELECT customerid, orderid, orderdate, employeeid
FROM [Sales].[Order] AS O1
WHERE orderid =
  (SELECT MAX(O2.orderid)
   FROM [Sales].[Order] AS O2
   WHERE O2.customerid = O1.customerid);
--12 Max orderid of customer 85
SELECT MAX(O2.orderid)
FROM [Sales].[Order] AS O2
WHERE O2.customerid = 85;

-- Percentage of customer total 13: Percent this purchase is of customer total
SELECT orderid, customerid, totaldiscountedamount,
  CAST(100. * totaldiscountedamount / (SELECT SUM(O2.totaldiscountedamount)
                     FROM [Sales].[uvw_OrderTotalQuantityandtotaldiscountedamount] AS O2
                     WHERE O2.customerid = O1.customerid)
       AS NUMERIC(5,2)) AS pct
FROM [Sales].[uvw_OrderTotalQuantityandtotaldiscountedamount] AS O1
ORDER BY customerid, orderid;

---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

-- Customers from Spain who placed orders 14: Returns customers from spain who have ordered using exist
SELECT customerid, customercompanyname
FROM [Sales].[Customer] AS C
WHERE customercountry = N'Spain'
  AND EXISTS
    (SELECT * FROM [Sales].[Order] AS O
     WHERE O.customerid = C.customerid);

-- Customers from Spain who didn't place Orders 15:Returns customers from spain who aren't orderers using not exist
SELECT customerid, customercompanyname
FROM [Sales].[Customer] AS C
WHERE customercountry = N'Spain'
  AND NOT EXISTS
    (SELECT * FROM [Sales].[Order] AS O
     WHERE O.customerid = C.customerid);

---------------------------------------------------------------------
-- Beyond the Fundamentals of Subqueries
-- (Optional, Advanced)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Returning "Previous" or "Next" Value
---------------------------------------------------------------------
--16: Returns the id of the previous order
SELECT orderid, orderdate, employeeid, customerid,
  (SELECT MAX(O2.orderid)
   FROM [Sales].[Order] AS O2
   WHERE O2.orderid < O1.orderid) AS prevorderid
FROM [Sales].[Order] AS O1;
--17  Returns the id of the next order
SELECT orderid, orderdate, employeeid, customerid,
  (SELECT MIN(O2.orderid)
   FROM [Sales].[Order] AS O2
   WHERE O2.orderid > O1.orderid) AS nextorderid
FROM [Sales].[Order] AS O1;

---------------------------------------------------------------------
-- Running Aggregates
---------------------------------------------------------------------
--18:Total quantity of orders from all years
SELECT orderyear, totalquantity
FROM Sales.uvw_OrderTotalQuantityByYear;
--19:Total quantity of orders from all years with running total
SELECT orderyear, totalquantity,
  (SELECT SUM(O2.totalquantity)
   FROM Sales.uvw_OrderTotalQuantityByYear AS O2
   WHERE O2.orderyear <= O1.orderyear) AS runqty
FROM Sales.uvw_OrderTotalQuantityByYear AS O1
ORDER BY orderyear;

---------------------------------------------------------------------
-- Misbehaving Subqueries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- NULL Trouble
---------------------------------------------------------------------

-- Customers who didn't place orders

-- Using NOT IN 20: Customers with null orders
SELECT customerid, customercompanyname
FROM [Sales].[Customer]
WHERE customerid NOT IN(SELECT O.customerid
                    FROM [Sales].[Order] AS O);

-- Add a row to the Orders table with a NULL custid 
INSERT INTO [Sales].[Order]
  (customerid, employeeid, orderdate, requireddate, shiptodate, shipperid,
   freight, shiptoname, shiptoaddress, shiptocity, shiptoregion,
   shiptopostalcode, shiptocountry)
  VALUES(NULL, 1, '20160212', '20160212',
         '20160212', 1, 123.00, N'abc', N'abc', N'abc',
         N'abc', N'abc', N'abc');

-- Following returns an empty set 21: Customer with null id
SELECT customerid, customercompanyname
FROM [Sales].[Customer]
WHERE customerid NOT IN(SELECT O.customerid
                    FROM [Sales].[Order] AS O);

-- Exclude NULLs explicitly 22: returns customers with null orders
SELECT customerid, customercompanyname
FROM [Sales].[Customer]
WHERE customerid NOT IN(SELECT O.customerid 
                    FROM [Sales].[Order] AS O
                    WHERE O.customerid IS NOT NULL);

-- Using NOT EXISTS 23: returns customers with null orders
SELECT customerid, customercompanyname
FROM [Sales].[Customer] AS C
WHERE NOT EXISTS
  (SELECT * 
   FROM [Sales].[Order] AS O
   WHERE O.customerid = C.customerid);

-- Cleanup
DELETE FROM [Sales].[Order] WHERE customerid IS NULL;
GO

---------------------------------------------------------------------
-- Substitution Error in a Subquery Column Name
---------------------------------------------------------------------

-- Create and populate table Sales.MyShippers
DROP TABLE IF EXISTS Sales.MyShippers;

CREATE TABLE Sales.MyShippers
(
  shipper_id  INT          NOT NULL,
  companyname NVARCHAR(40) NOT NULL,
  phone       NVARCHAR(24) NOT NULL,
  CONSTRAINT PK_MyShippers PRIMARY KEY(shipper_id)
);

INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
  VALUES(1, N'Shipper GVSUA', N'(503) 555-0137'),
	      (2, N'Shipper ETYNR', N'(425) 555-0136'),
				(3, N'Shipper ZHISN', N'(415) 555-0138');
GO

-- Shippers who shipped orders to customer 43

-- Bug 24: companies that 43 ordered from with bug
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT shipper_id
   FROM [Sales].[Order]
   WHERE customerid = 43);
GO

-- The safe way using aliases, bug identified 25: companies that 43 ordered from with bug fixed
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.shipperid
   FROM [Sales].[Order] AS O
   WHERE O.customerid = 43);
GO

-- Bug corrected 26: companies that 43 ordered from with bug fixed
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.shipperid
   FROM [Sales].[Order] AS O
   WHERE O.customerid = 43);

-- Cleanup
DROP TABLE IF EXISTS Sales.MyShippers;
---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 05 - Table Expressions
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Derived Tables
---------------------------------------------------------------------

--27: Customers from USA
SELECT *
FROM (SELECT customerid, customercompanyname
      FROM [Sales].[Customer]
      WHERE customercountry = N'USA') AS USACusts;

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------
-- Following fails
/*
SELECT
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;
*/
GO
--28: Number of customers by year
-- Listing 5-1 Query with a Derived Table using Inline Aliasing Form
SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, customerid
      FROM [Sales].[Order]) AS D
GROUP BY orderyear;
--29: Number of customers by year
SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM [Sales].[Order]
GROUP BY YEAR(orderdate);

-- External column aliasing 30: Number of customers by year
SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM (SELECT YEAR(orderdate), customerid
      FROM [Sales].[Order]) AS D(orderyear, customerid)
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

-- Yearly Count of Customers handled by Employee 3 31: Returns number of customers per year handled by Employee 3
DECLARE @empid AS INT = 3;

SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, customerid
      FROM [Sales].[Order]
      WHERE employeeid = @empid) AS D
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Nesting
---------------------------------------------------------------------

-- Listing 5-2 Query with Nested Derived Tables 32: Returns years where numcusts more than 70
SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
      FROM (SELECT YEAR(orderdate) AS orderyear, customerid
            FROM [Sales].[Order]) AS D1
      GROUP BY orderyear) AS D2
WHERE numcusts > 70;
--33: Returns years where numcusts more than 70
SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM [Sales].[Order]
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT customerid) > 70;
---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------
--34 Returns number of customers per year, previous year customers, and growth
-- Listing 5-3 Multiple Derived Tables Based on the Same Query
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT customerid) AS numcusts
      FROM [Sales].[Order]
      GROUP BY YEAR(orderdate)) AS Cur
  LEFT OUTER JOIN
     (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT customerid) AS numcusts
      FROM [Sales].[Order]
      GROUP BY YEAR(orderdate)) AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;
---------------------------------------------------------------------
-- Common Table Expressions
---------------------------------------------------------------------
--35 USA customers from table
WITH USACusts AS
(
  SELECT customerid, customercompanyname
  FROM [Sales].[Customer]
  WHERE customercountry = N'USA'
)
SELECT * FROM USACusts;
---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------
-- Inline column aliasing
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, customerid
  FROM [Sales].[Order]
)
--36 All customers per year
SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM C
GROUP BY orderyear;

-- External column aliasing
WITH C(orderyear, custid) AS
(
  SELECT YEAR(orderdate), customerid
  FROM [Sales].[Order]
)
--37 All customers per year
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

DECLARE @empid AS INT = 3;
--38 Customers per year who ordered with employee 3
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, customerid
  FROM [Sales].[Order]
  WHERE employeeid = @empid
)
SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Defining Multiple CTEs
---------------------------------------------------------------------
--39 Years when customer number more than 70 with CTES
WITH C1 AS
(
  SELECT YEAR(orderdate) AS orderyear, customerid
  FROM [Sales].[Order]
),
C2 AS
(
  SELECT orderyear, COUNT(DISTINCT customerid) AS numcusts
  FROM C1
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------
--40 Number of customers per year, previous customer number per year, and growth using CTEs
WITH YearlyCount AS
(
  SELECT YEAR(orderdate) AS orderyear,
    COUNT(DISTINCT customerid) AS numcusts
  FROM [Sales].[Order]
  GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
  LEFT OUTER JOIN YearlyCount AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

---------------------------------------------------------------------
-- Recursive CTEs (Optional, Advanced)
---------------------------------------------------------------------
--41 First prints employee with id 2, then all employees thanks to union all
WITH EmpsCTE AS
(
  SELECT employeeid, employeemanagerid, employeefirstname, employeelastname
  FROM [HumanResources].[Employee]
  WHERE employeeid = 2
  
  UNION ALL
  
  SELECT C.employeeid, C.employeemanagerid, C.employeefirstname, C.employeelastname
  FROM EmpsCTE AS P
    INNER JOIN [HumanResources].[Employee] AS C
      ON C.employeemanagerid = P.employeeid
)
SELECT employeeid, employeemanagerid, employeefirstname, employeelastname
FROM EmpsCTE;

---------------------------------------------------------------------
-- Views
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Views Described
---------------------------------------------------------------------

-- Creating USACusts View 42: using tableview, find all USA customers
DROP VIEW IF EXISTS Sales.USACusts;
GO
CREATE VIEW Sales.USACusts
AS

SELECT
  customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA';
GO

SELECT customerid, customercompanyname
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- Views and ORDER BY
---------------------------------------------------------------------

-- ORDER BY in a View is not Allowed
/*
ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO
*/

-- Instead, use ORDER BY in Outer Query 43: USA customers by alphabetical state
SELECT customerid, customercompanyname, customerregion
FROM Sales.USACusts
ORDER BY customerregion;
GO

-- Do not Rely on TOP 
ALTER VIEW Sales.USACusts
AS

SELECT TOP (100) PERCENT --USA Table using 100 percent top
   customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA'
ORDER BY customerregion;
GO

-- Query USACusts 44: Customers of US by customerid
SELECT customerid, customercompanyname, customerregion
FROM Sales.USACusts;
GO

-- DO NOT rely on OFFSET-FETCH, even if for now the engine does return rows in rder
ALTER VIEW Sales.USACusts
AS

SELECT --USA Table with 0 offset
  customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA'
ORDER BY customerregion
OFFSET 0 ROWS;
GO

-- Query USACusts : 45 customers of US by alphabetical region
SELECT customerid, customercompanyname, customerregion
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- View Options
---------------------------------------------------------------------

---------------------------------------------------------------------
-- ENCRYPTION
---------------------------------------------------------------------

ALTER VIEW Sales.USACusts
AS

SELECT --US Table
  customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA';
GO
--46 Definition of Sales.USACusts
SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));
GO

ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS

SELECT
   customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA';
GO
--47 Encrypted table prevents definition
SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

EXEC sp_helptext 'Sales.USACusts';
GO

---------------------------------------------------------------------
-- SCHEMABINDING
---------------------------------------------------------------------

ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT  --US TABle made with schemabinding added to allow proper changes
   customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA';
GO

-- Try a schema change
/*
ALTER TABLE Sales.Customers DROP COLUMN address;
*/
GO

---------------------------------------------------------------------
-- CHECK OPTION
---------------------------------------------------------------------

-- Notice that you can insert a row through the view
INSERT INTO Sales.USACusts(
  customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber)
 VALUES(
  N'Customer ABCDE', N'Contact ABCDE', N'Title ABCDE', N'Address ABCDE',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

-- But when you query the view, you won't see it  48:There is no result printed even though it should print customer by specific customercompanyname 
SELECT customerid, customercompanyname, customercountry
FROM [Sales].[USACusts]
WHERE customercompanyname = N'Customer ABCDE';

-- You can see it in the table, though 49: No result printed by it should print specified customer by company name
SELECT customerid, customercompanyname, customercountry
FROM [Sales].[Customer]
WHERE customercompanyname = N'Customer ABCDE';
GO

-- Add CHECK OPTION to the View
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT --US Table from customer database
   customerid, customercompanyname, customercontactname, customercontacttitle, customeraddress,
  customercity, customerregion, customerpostalcode, customercountry, customerphonenumber, customerfaxnumber
FROM [Sales].[Customer]
WHERE customercountry = N'USA'
WITH CHECK OPTION;
GO

-- Notice that you can't insert a row through the view
/*
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
 VALUES(
  N'Customer FGHIJ', N'Contact FGHIJ', N'Title FGHIJ', N'Address FGHIJ',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');
*/
GO

-- Cleanup
DELETE FROM [Sales].[Customer]
WHERE customerid > 91;

DROP VIEW IF EXISTS Sales.USACusts;
GO

---------------------------------------------------------------------
-- Inline User Defined Functions
---------------------------------------------------------------------

-- Creating GetCustOrders function
DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO
CREATE FUNCTION dbo.GetCustOrders
  (@cid AS INT) RETURNS TABLE
AS
RETURN --Function created that returns orders of a customer id
  SELECT orderid,customerid, employeeid, orderdate, requireddate, shiptodate, shipperid,
   freight, shiptoname, shiptoaddress, shiptocity, shiptoregion,
   shiptopostalcode, shiptocountry
  FROM [Sales].[Order]
  WHERE customerid = @cid;
GO

-- Test Function 50: Orders of customer 1
SELECT orderid, customerid
FROM dbo.GetCustOrders(1) AS O;
--51: Orders of customer 1 with added customerid, productid, and quantity
SELECT O.orderid, O.customerid, OD.productid, OD.quantity
FROM dbo.GetCustOrders(1) AS O
  INNER JOIN [Sales].[OrderDetail] AS OD
    ON O.orderid = OD.orderid;
GO

-- Cleanup
DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO

---------------------------------------------------------------------
-- APPLY
---------------------------------------------------------------------

SELECT S.shipperid, E.employeeid --52: Cross join shipper id to employeeid, each iteration gets all employees
FROM [Sales].[Shipper] AS S
  CROSS JOIN [HumanResources].[Employee] AS E;

SELECT S.shipperid, E.employeeid --53: Cross join shipper id to employeeid, each iteration gets all employees
FROM [Sales].[Shipper] AS S
  CROSS APPLY [HumanResources].[Employee] AS E;

-- 3 most recent orders for each customer 54: Top 3 orders of each customer
SELECT C.customerid, A.orderid, A.orderdate
FROM [Sales].[Customer] AS C
  CROSS APPLY
    (SELECT TOP (3) orderid, employeeid, orderdate, requireddate 
     FROM [Sales].[Order] AS O
     WHERE O.customerid = C.customerid
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- With OFFSET-FETCH 55: Top 3 orders of each customer using offset
SELECT C.customerid, A.orderid, A.orderdate
FROM [Sales].[Customer] AS C
  CROSS APPLY
    (SELECT orderid, employeeid, orderdate, requireddate 
     FROM [Sales].[Order] AS O
     WHERE O.customerid = C.customerid
     ORDER BY orderdate DESC, orderid DESC
     OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) AS A;

-- 3 most recent orders for each customer, preserve customers 56: 3 most recent orders of each customer, using outer apply so C can be used in subquery
SELECT C.customerid, A.orderid, A.orderdate
FROM [Sales].[Customer] AS C
  OUTER APPLY
    (SELECT TOP (3) orderid, employeeid, orderdate, requireddate 
     FROM [Sales].[Order] AS O
     WHERE O.customerid = C.customerid
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- Creation Script for the Function TopOrders
DROP FUNCTION IF EXISTS dbo.TopOrders;
GO
CREATE FUNCTION dbo.TopOrders --function allows finding of a certain amount (n) of top orders for customer (custid)
  (@custid AS INT, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, employeeid, orderdate, requireddate 
  FROM [Sales].[Order]
  WHERE customerid = @custid
  ORDER BY orderdate DESC, orderid DESC;
GO

SELECT --57: 3 top orders for each customer using a function
  C.customerid, C.customercompanyname,
  A.orderid, A.employeeid, A.orderdate, A.requireddate 
FROM [Sales].[Customer] AS C
  CROSS APPLY dbo.TopOrders(C.customerid, 3) AS A;
