USE Northwinds2020TSQLV6
-- 1
-- 1-1
-- Write a query that generates 5 copies out of each employee row
-- Tables involved: TSQLV4 database, Employees and Nums tables
DROP TABLE IF EXISTS dbo.Digits;
CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);
INSERT INTO dbo.Digits(digit)
  VALUES (1),(2),(3),(4),(5);
SELECT B.digit,A.employeeid, A.employeefirstname, A.employeelastname
FROM [HumanResources].[Employee] as A
 Cross Join dbo.Digits as B
-- 1-2 (Optional, Advanced)
-- Write a query that returns a row for each employee and day 
-- in the range June 12, 2016 – June 16 2016.
-- Tables involved: TSQLV4 database, Employees and Nums tables
SELECT H.EmployeeId, DATEADD(day, A.n-1, CAST('20160612' AS DATE)) as gamer
FROM [HumanResources].[Employee] AS H
  Cross JOIN dbo.Nums AS A
WHERE n <= DATEDIFF(day, '20160612', '20160616') + 1
Order by employeeid
-- 2
-- Explain what’s wrong in the following query and provide a correct alternative
SELECT C.customerid, C.customercompanyname, O.orderid, O.orderdate
FROM [Sales].[Customer] AS C
  INNER JOIN [Sales].[Order] AS O
    ON C.CustomerId = O.CustomerId;
-- 3
-- Return US customers, and for each customer the total number of orders 
-- and total quantities.
-- Tables involved: TSQLV4 database, Customers, Orders and OrderDetails tables
SELECT C.customerid, COUNT(Distinct O.orderid) as ordernumber, SUM(Z.Quantity) as quantitysum
FROM [Sales].[Customer] AS C
  INNER JOIN [Sales].[Order] AS O
    ON C.CustomerId = O.CustomerId
  INNER JOIN [Sales].[OrderDetail] AS Z
   ON O.orderid = Z.OrderId
Where C.CustomerCountry = N'USA'
Group by C.CustomerId
-- 4
-- Return customers and their orders including customers who placed no orders
-- Tables involved: TSQLV4 database, Customers and Orders tables
SELECT O.customerid,C.customercompanyname, O.orderid, O.OrderDate
FROM [Sales].[Customer] as C
  LEFT OUTER JOIN [Sales].[Order] AS O
    ON C.customerid = O.CustomerId
-- 5
-- Return customers who placed no orders
-- Tables involved: TSQLV4 database, Customers and Orders tables
SELECT C.customerid,C.customercompanyname
FROM [Sales].[Customer] as C
  Left outer join [Sales].[Order] as O
   ON C.CustomerId = O.CustomerId
Where O.OrderDate is NUll
-- 6
-- Return customers with orders placed on Feb 12, 2016 along with their orders
-- Tables involved: TSQLV4 database, Customers and Orders tables
SELECT O.customerid,C.customercompanyname, O.orderid, O.OrderDate
FROM [Sales].[Customer] as C
  LEFT OUTER JOIN [Sales].[Order] AS O
    ON C.customerid = O.CustomerId
Where O.OrderDate = '20160212'
-- 7 (Optional, Advanced)
-- Write a query that returns all customers in the output, but matches
-- them with their respective orders only if they were placed on February 12, 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables
SELECT O.customerid,C.customercompanyname, O.orderid, O.OrderDate
FROM [Sales].[Customer] as C
  LEFT OUTER JOIN [Sales].[Order] AS O
    ON C.customerid = O.CustomerId AND O.OrderDate = '20160212'
-- 8 (Optional, Advanced)
-- Explain why the following query isn’t a correct solution query for exercise 7.
SELECT C.customerid, C.customercompanyname, O.orderid, O.orderdate
FROM [Sales].[Customer] AS C
  LEFT OUTER JOIN [Sales].[Order] AS O
    ON O.customerid = C.customerid
WHERE O.orderdate = '20160212'
   OR O.orderid IS NULL;
-- 9 (Optional, Advanced)
-- Return all customers, and for each return a Yes/No value
-- depending on whether the customer placed an order on Feb 12, 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables
Select distinct C.customerid, C.customercompanyname,
 CASE
    WHEN O.orderdate is Null THEN 'No'
    ELSE 'Yes'
END AS isfeb12016
FROM [Sales].[Customer] as C
  LEFT OUTER JOIN [Sales].[Order] AS O
    ON C.customerid = O.CustomerId AND O.OrderDate = '20160212'