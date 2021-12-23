---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 04 - Subqueries
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------
USE Northwinds2020TSQlv6
-- 1 
-- Write a query that returns all orders placed on the last day of
-- activity that can be found in the Orders table
-- Tables involved: TSQLV4 database, Orders table
Declare @maxdate as Date =((SELECT MAX(O.orderdate) FROM [Sales].[Order] as O))
SELECT orderid, orderdate, employeeid, customerid
FROM [Sales].[Order]
WHERE orderdate = @maxdate
Order by orderid
GO
-- 3
-- Write a query that returns employees
-- who did not place orders on or after May 1st, 2016
-- Tables involved: TSQLV4 database, Employees and Orders tables
Select employeeid,employeefirstname,employeelastname
From [HumanResources].[Employee] 
Where employeeid not in (Select O.employeeid from [Sales].[Order] as O where orderdate>='20160501')
Order by employeeid
GO
-- 4
-- Write a query that returns
-- countries where there are customers but not employees
-- Tables involved: TSQLV4 database, Customers and Employees tables
Select Distinct customercountry
From [Sales].[Customer] 
Where customercountry not in (Select E.employeecountry from [HumanResources].[Employee] as E)
Go
-- 5
-- Write a query that returns for each customer
-- all orders placed on the customer's last day of activity
-- Tables involved: TSQLV4 database, Orders table
Select O.orderid,O.orderdate,O.customerid
From [Sales].[Order] as O
Where O.orderdate=(Select MAX(B.orderdate) from [Sales].[Order] as B where B.customerid=O.customerid)
order by O.customerid
GO
-- 6
-- Write a query that returns customers
-- who placed orders in 2015 but not in 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables
Select Distinct C.customerid,C.customercompanyname
From [Sales].[Customer] as C
Where exists (Select * from [Sales].[Order] as O where O.customerid=C.customerid and O.orderdate>='20150101' and O.orderdate<='20161231')  and not exists (Select * from [Sales].[Order] as O where O.customerid=C.customerid and O.orderdate>='20160101' and O.orderdate<='20161231')
-- 9
-- Explain the difference between IN and EXISTS: The exist predicate searches for rows that match input requirements
--The in predicate takes an input variable and searches for same variable in rows that fits requirements specified. In needs variable, exists does not
---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 05 - Table Expressions
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------
-- 1
-- The following query attempts to filter orders placed on the last day of the year.
USE Northwinds2020TSQlv6;
GO
--SELECT orderid, orderdate, customerid, employeeid,
  --DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
--FROM [Sales].[Order]
--WHERE orderdate <> endofyear; (Commented out to prevent stopping code error)

-- When you try to run this query you get the following error.
/*
Msg 207, Level 16, State 1, Line 233
Invalid column name 'endofyear'.
*/
-- Explain what the problem is and suggest a valid solution.
--Column endofyear was not initially part of the original table and thus cannot be evaluated. You have to create a new table with endofyear as a column with a CTE
WITH C AS (SELECT *, DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear FROM [Sales].[Order])
SELECT orderid, orderdate, customerid, employeeid, endofyear
FROM C
WHERE orderdate <> endofyear;
-- 2-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: TSQLV4 database, Sales.Orders table
Select O.orderid,O.orderdate,O.employeeid
From [Sales].[Order] as O
Where O.orderdate=(Select MAX(B.orderdate) from [Sales].[Order] as B where B.employeeid=O.employeeid)
order by O.employeeid
GO
-- 2-2
-- Encapsulate the query from exercise 2-1 in a derived table
-- Write a join query between the derived table and the Sales.Orders
-- table to return the Sales.Orders with the maximum order date for 
-- each employee
-- Tables involved: Sales.Orders



-- 3-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.Orders



-- 3-2
-- Write a query that returns rows with row numbers 11 through 20
-- based on the row number definition in exercise 3-1
-- Use a CTE to encapsulate the code from exercise 3-1
-- Tables involved: Sales.Orders



-- 5-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.Orders and Sales.OrderDetails

-- Desired output when running:
-- SELECT * FROM  Sales.VEmpOrders ORDER BY empid, orderyear


-- 6-1
-- Create an inline function that accepts as inputs
-- a supplier id (@supid AS INT), 
-- and a requested number of products (@n AS INT)
-- The function should return @n products with the highest unit prices
-- that are supplied by the given supplier id
-- Tables involved: Production.Products

-- Desired output when issuing the following query:
-- SELECT * FROM Production.TopProducts(5, 2)


-- 6-2
-- Using the CROSS APPLY operator
-- and the function you created in exercise 6-1,
-- return, for each supplier, the two most expensive products



-- When you’re done, run the following code for cleanup:
DROP VIEW IF EXISTS Sales.VEmpOrders;
DROP FUNCTION IF EXISTS Production.TopProducts;