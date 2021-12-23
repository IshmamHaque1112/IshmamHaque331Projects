---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 07 - Beyond the Fundamentals of Querying
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------
USE Northwinds2020TSQLV6;
-- All exercises for this chapter will involve querying the dbo.Orders
-- table in the TSQLV4 database that you created and populated 
-- earlier by running the code in Listing 7-1
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
-- 1
-- Write a query against the dbo.Orders table that computes for each
-- customer order, both a rank and a dense rank,
-- partitioned by customerid, ordered by qty 
--This selects from dboOrders with select variables using rank() and dense_rank()
SELECT customerid,orderid, qty,RANK() OVER(ORDER BY qty) AS rank,DENSE_RANK() OVER(ORDER BY qty) AS dense_rank
From dbo.Orders
-- 2
-- The following query against the Sales.OrderValues view returns
-- distinct values and their associated row numbers
SELECT TotalDiscountedAmount, ROW_NUMBER() OVER(ORDER BY TotalDiscountedAmount) AS rownum
FROM Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
GROUP BY TotalDiscountedAmount;
-- Can you think of an alternative way to achieve the same task?
-- Tables involved: TSQLV4 database, Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount view
--Used rank instead of row_number
Select distinct Totaldiscountedamount,RANK() OVER(ORDER BY totaldiscountedamount) AS rownum
From Sales.uvw_OrderTotalQuantityAndTotalDiscountedAmount
-- 3
-- Write a query against the dbo.Orders table that computes for each
-- customer order:
-- * the difference between the current order quantity
--   and the customer's previous order quantity
-- * the difference between the current order quantity
--   and the customer's next order quantity.
--Uses qty-LAG and qty-LEAD to find differences. 
Select customerid,orderid,qty,qty-LAG(qty) OVER(PARTITION BY customerid ORDER BY orderdate, orderid) AS diffprev,qty-LEAD(qty) OVER(PARTITION BY customerid ORDER BY orderdate, orderid) AS diffnext
From dbo.Orders
-- 4
-- Write a query against the dbo.Orders table that returns a row for each
-- employee, a column for each order year, and the count of orders
-- for each employee and order year
-- Tables involved: TSQLV4 database, dbo.Orders table
--Uses pivot function to pivot table around the year of ordering
SELECT employeeid,[2014] as cnt2014, [2015] as cnt2015, [2016]
FROM (SELECT employeeid, YEAR(orderdate) as orderyear
      FROM dbo.Orders) AS D
  PIVOT(COUNT(orderyear)
        FOR orderyear IN([2014], [2015], [2016])) AS P;
-- 5
-- Run the following code to create and populate the EmpYearOrders table:
DROP TABLE IF EXISTS dbo.EmpYearOrders;
CREATE TABLE dbo.EmpYearOrders
(
  employeeid INT NOT NULL
    CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
  cnt2014 INT NULL,
  cnt2015 INT NULL,
  cnt2016 INT NULL
);
INSERT INTO dbo.EmpYearOrders(employeeid, cnt2014, cnt2015, cnt2016)
  SELECT employeeid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
  FROM (SELECT employeeid, YEAR(orderdate) AS orderyear
        FROM dbo.Orders) AS D
    PIVOT(COUNT(orderyear)
          FOR orderyear IN([2014], [2015], [2016])) AS P;
SELECT * FROM dbo.EmpYearOrders;
-- Output:
-- Write a query against the EmpYearOrders table that unpivots
-- the data, returning a row for each employee and order year
-- with the number of orders
-- Exclude rows where the number of orders is 0
-- (in our example, employee 3 in year 2016)
-- Unpivots numorders per orderyear using unpivot function
SELECT employeeid,SUBSTRING(orderyear, 4, 8) as orderyear,numorders
FROM dbo.EmpYearOrders
  UNPIVOT(numorders FOR orderyear IN(cnt2014, cnt2015, cnt2016)) AS U
Where numorders <> 0
-- 6
-- Write a query against the dbo.Orders table that returns the 
-- total quantities for each:
-- employee, customer, and order year
-- employee and order year
-- customer and order year
-- Include a result column in the output that uniquely identifies 
-- the grouping set with which the current row is associated
-- Tables involved: TSQLV4 database, dbo.Orders table
--Groups by employee, customer and year
Select GROUPING_ID(employeeid, customerid,Year(orderdate)) AS groupingset,employeeid,customerid,Year(orderdate) as orderyear,SUM(qty) as sumqty
From dbo.Orders
Group By
 GROUPING SETS
  ((employeeid, customerid,Year(orderdate)),
    (employeeid,Year(orderdate)),
    (customerid,Year(orderdate)));
-- When you're done, run the following code for cleanup
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.EmpYearOrders;
DROP TABLE IF EXISTS dbo.EmpCustOrders;