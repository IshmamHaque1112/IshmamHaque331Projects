---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 07 - Beyond the Fundamentals of Querying
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Window Functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Window Functions, Described
---------------------------------------------------------------------

USE Northwinds2020TSQLV6;
--1. Running total money value of employe orders handled.
SELECT employeeid, ordermonth,  totaldiscountedamount,
  SUM(totaldiscountedamount) OVER(PARTITION BY employeeid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runval
FROM Sales.uvw_EmployeeOrder;

---------------------------------------------------------------------
-- Ranking Window Functions
---------------------------------------------------------------------
--2. orders ordered by increased totaldiscountedamount rank and ntile.
SELECT orderid, customerid, totaldiscountedamount,
  ROW_NUMBER() OVER(ORDER BY totaldiscountedamount) AS rownum,
  RANK()       OVER(ORDER BY totaldiscountedamount) AS rank,
  DENSE_RANK() OVER(ORDER BY totaldiscountedamount) AS dense_rank,
  NTILE(10)    OVER(ORDER BY totaldiscountedamount) AS ntile
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
ORDER BY totaldiscountedamount;
--3. orders ordered by customerid and totaldiscountedamount
SELECT orderid, customerid, totaldiscountedamount,
  ROW_NUMBER() OVER(PARTITION BY customerid
                    ORDER BY totaldiscountedamount) AS rownum
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
ORDER BY customerid, totaldiscountedamount;
--4. Increasing totaldiscountedamount
SELECT DISTINCT totaldiscountedamount, ROW_NUMBER() OVER(ORDER BY totaldiscountedamount) AS rownum
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount;
--5 Increasing totaldiscountedamount with distincts only
SELECT totaldiscountedamount, ROW_NUMBER() OVER(ORDER BY totaldiscountedamount) AS rownum
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
GROUP BY totaldiscountedamount;

---------------------------------------------------------------------
-- Offset Window Functions
---------------------------------------------------------------------

-- LAG and LEAD
--6 totaldiscounted amount by increasing customerid and totaldiscounted amount, first and next
SELECT customerid, orderid, totaldiscountedamount,
  LAG(totaldiscountedamount)  OVER(PARTITION BY customerid
                 ORDER BY orderdate, orderid) AS prevval,
  LEAD(totaldiscountedamount) OVER(PARTITION BY customerid
                 ORDER BY orderdate, orderid) AS nextval
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
ORDER BY customerid, orderdate, orderid;

-- FIRST_VALUE and LAST_VALUE
-- 7 totaldiscounted amount by increasing customerid and totaldiscounted amount, first and next but no null lastval
SELECT customerid, orderid, totaldiscountedamount,
  FIRST_VALUE(totaldiscountedamount) OVER(PARTITION BY customerid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW) AS firstval,
  LAST_VALUE(totaldiscountedamount)  OVER(PARTITION BY customerid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
ORDER BY customerid, orderdate, orderid;

---------------------------------------------------------------------
-- Aggregate Window Functions
---------------------------------------------------------------------
--8 orders and amount with totalvalue and customertotalvalue
SELECT orderid, customerid, totaldiscountedamount,
  SUM(totaldiscountedamount) OVER() AS totalvalue,
  SUM(totaldiscountedamount) OVER(PARTITION BY customerid) AS custtotalvalue
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount;
--9 Percentage each order over total orders for all and each customer
SELECT orderid, customerid, totaldiscountedamount,
  100. * totaldiscountedamount / SUM(totaldiscountedamount) OVER() AS pctall,
  100. * totaldiscountedamount / SUM(totaldiscountedamount) OVER(PARTITION BY customerid) AS pctcust
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount;
--10 orders by employeeid cost and running total
SELECT employeeid, ordermonth, totaldiscountedamount,
  SUM(totaldiscountedamount) OVER(PARTITION BY employeeid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runval
FROM Sales.uvw_EmployeeOrder;

---------------------------------------------------------------------
-- Pivoting Data
---------------------------------------------------------------------

-- Listing 1: Code to Create and Populate the Orders Table
--11 Orders table created and populated
USE Northwinds2020TSQLV6;

DROP TABLE IF EXISTS dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL,
  orderdate DATE       NOT NULL,
  employeeid     INT        NOT NULL,
  customerid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, employeeid, customerid, qty)
VALUES
  (30001, '20140802', 3, 'A', 10),
  (10001, '20141224', 2, 'A', 12),
  (10005, '20141224', 1, 'B', 20),
  (40001, '20150109', 2, 'A', 40),
  (10006, '20150118', 1, 'C', 14),
  (20001, '20150212', 2, 'B', 12),
  (40005, '20160212', 3, 'A', 10),
  (20002, '20160216', 1, 'C', 20),
  (30003, '20160418', 2, 'B', 15),
  (30004, '20140418', 3, 'C', 22),
  (30007, '20160907', 3, 'D', 30);

SELECT * FROM dbo.Orders;

-- Query against Orders, grouping by employee and customer
--12 Query of orders and employee pairs with sum quantity in alphabetical order
SELECT employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY employeeid, customerid;

---------------------------------------------------------------------
-- Pivoting with a Grouped Query
---------------------------------------------------------------------

-- Query against Orders, grouping by employee, pivoting customers,
-- aggregating sum of quantity 
--13 each employee and how many orders they did for each customer
SELECT employeeid,
  SUM(CASE WHEN customerid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN customerid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN customerid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN customerid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY employeeid;

---------------------------------------------------------------------
-- Pivoting with the PIVOT Operator
---------------------------------------------------------------------

-- Logical equivalent of previous query using the native PIVOT operator
--14 Same as 14
SELECT employeeid, A, B, C, D
FROM (SELECT employeeid, customerid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR customerid IN(A, B, C, D)) AS P;

-- Query demonstrating the problem with implicit grouping
--15 For every customer employee relation new employeeid duplicate
SELECT employeeid, A, B, C, D
FROM dbo.Orders
  PIVOT(SUM(qty) FOR customerid IN(A, B, C, D)) AS P;

-- Logical equivalent of previous query
--16 Same as 15
SELECT employeeid,
  SUM(CASE WHEN customerid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN customerid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN customerid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN customerid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY orderid, orderdate, employeeid;

-- Query against Orders, grouping by customer, pivoting employees,
-- aggregating sum of quantity
--17 customers and orders from each emplyee
SELECT customerid, [1], [2], [3]
FROM (SELECT employeeid, customerid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR employeeid IN([1], [2], [3])) AS P;

---------------------------------------------------------------------
-- Unpivoting Data
---------------------------------------------------------------------

-- Code to create and populate the EmpCustOrders table

DROP TABLE IF EXISTS dbo.EmpCustOrders;

CREATE TABLE dbo.EmpCustOrders
(
  employeeid INT NOT NULL
    CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
  A VARCHAR(5) NULL,
  B VARCHAR(5) NULL,
  C VARCHAR(5) NULL,
  D VARCHAR(5) NULL
);

INSERT INTO dbo.EmpCustOrders(employeeid, A, B, C, D)
  SELECT employeeid, A, B, C, D
  FROM (SELECT employeeid, customerid, qty
        FROM dbo.Orders) AS D
    PIVOT(SUM(qty) FOR customerid IN(A, B, C, D)) AS P;
--18 employeeid with orders quantity for each customer
SELECT * FROM dbo.EmpCustOrders;

---------------------------------------------------------------------
-- Unpivoting with the APPLY Operator
---------------------------------------------------------------------
--19 table copied
-- Unpivot Step 1: generate copies
SELECT *
FROM dbo.EmpCustOrders
  CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS C(customerid);
  --20 Increasing employeeid with customerid and order quantity but structure changed
-- Unpivot Step 2: extract elements
/*
SELECT employeeid, customerid, qty
FROM dbo.EmpCustOrders
  CROSS JOIN (VALUES('A', A),('B', B),('C', C),('D', D)) AS C(customerid, qty);
*/

SELECT employeeid, customerid, qty
FROM dbo.EmpCustOrders
  CROSS APPLY (VALUES('A', A),('B', B),('C', C),('D', D)) AS C(customerid, qty);

-- Unpivot Step 3: eliminate NULLs
--21 same as 20 but nulls removed
SELECT employeeid, customerid, qty
FROM dbo.EmpCustOrders
  CROSS APPLY (VALUES('A', A),('B', B),('C', C),('D', D)) AS C(customerid, qty)
WHERE qty IS NOT NULL;

---------------------------------------------------------------------
-- Unpivoting with the UNPIVOT Operator
---------------------------------------------------------------------

-- Query using the native UNPIVOT operator
--22 same as 21
SELECT employeeid, customerid, qty
FROM dbo.EmpCustOrders
  UNPIVOT(qty FOR customerid IN(A, B, C, D)) AS U;
  
---------------------------------------------------------------------
-- Grouping Sets
---------------------------------------------------------------------
--23 same as 22 but with alphabetical order customerid
-- Four queries, each with a different grouping set
SELECT employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY employeeid, customerid;
--24 How many orders each employee did
SELECT employeeid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY employeeid;
--25 Customers and how many orders for each
SELECT customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY customerid;
--26 All orders in table
SELECT SUM(qty) AS sumqty
FROM dbo.Orders;

-- Unifying result sets of four queries
--27 Union all of four queries including nulls
SELECT employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY employeeid, customerid

UNION ALL

SELECT employeeid, NULL, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY employeeid

UNION ALL

SELECT NULL, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY customerid

UNION ALL

SELECT NULL, NULL, SUM(qty) AS sumqty
FROM dbo.Orders;

---------------------------------------------------------------------
-- GROUPING SETS Subclause
---------------------------------------------------------------------
--28 Same as 27 but different ordering
-- Using the GROUPING SETS subclause
SELECT employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
    (employeeid, customerid),
    (employeeid),
    (customerid),
    ()
  );
---------------------------------------------------------------------
-- CUBE Subclause
---------------------------------------------------------------------
-- Using the CUBE subclause
--29 Same as 28
SELECT employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(employeeid, customerid);
--------------------------------------------------------------------
-- ROLLUP Subclause
---------------------------------------------------------------------
-- Using the ROLLUP subclause
--30 Orders with dates and sum
SELECT 
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));
---------------------------------------------------------------------
-- GROUPING and GROUPING_ID Function
---------------------------------------------------------------------
--31 Grouping happens with sumqty in alphabetical
SELECT employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(employeeid, customerid);
--32 Groups of employees or customer (NULL employeeid employee, NULL customerid customer)
SELECT
  GROUPING(employeeid) AS grpemp,
  GROUPING(customerid) AS grpcust,
  employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(employeeid, customerid);
--33 Unique groups of customers and employees
SELECT
  GROUPING_ID(employeeid, customerid) AS groupingset,
  employeeid, customerid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(employeeid, customerid);
