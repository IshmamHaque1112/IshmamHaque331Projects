use Northwinds2020TSQLV6
-- 1 
-- Return orders placed in June 2015
Select OrderId,orderdate,customerid,employeeid
From [Sales].[Order]
Where Datepart(yyyy,orderdate)=2015 and datepart(mm,orderdate)=06
-- 2 
-- Return orders placed on the last day of the month
-- Tables involved: Sales.Orders table
Select OrderId,orderdate,customerid,employeeid
From [Sales].[Order]
Where orderdate=EOMONTH(orderdate)
-- 3 
-- Return employees with last name containing the letter 'e' twice or more
-- Tables involved: HR.Employees table
Select employeeid, employeelastname,employeefirstname
From [HumanResources].[Employee]
Where LEN(EmployeeLastName) - LEN(REPLACE(EmployeeLastName, 'E', ''))>=2
-- 4 
-- Return orders with total value(qty*unitprice) greater than 10000
-- sorted by total value
-- Tables involved: Sales.OrderDetails table
Select orderid, SUM(unitprice*quantity) as totalvalue
From [Sales].[OrderDetail]
Group by OrderId
Having SUM(unitprice*Quantity)>10000
Order by totalvalue desc
-- 5
-- Write a query against the HR.Employees table that returns employees
-- with a last name that starts with a lower case letter.
-- Remember that the collation of the sample database
-- is case insensitive (Latin1_General_CI_AS).
-- For simplicity, you can assume that only English letters are used
-- in the employee last names.
-- Tables involved: Sales.OrderDetails table
Select employeeid, employeelastname
From [HumanResources].[Employee]
where EmployeeLastName collate Latin1_General_CS_AS like N'[abcdefghijklmnopqrstuvwxyz]%'
-- 6
-- Explain the difference between the following two queries

-- Query 1: The query returns how many total orders employees took before May 2016
SELECT employeeid, COUNT(*) AS numorders
FROM [Sales].[Order]
WHERE orderdate < '20160501'
GROUP BY EmployeeId
-- Query 2: The query returns total orders for those that worked before May 2016. Having max(orderdate) specifies only those that worked before May 2016
SELECT employeeid, COUNT(*) AS numorders
FROM [Sales].[Order]
GROUP BY EmployeeId
HAVING MAX(orderdate) < '20160501';
-- 7 
-- Return the three ship countries with the highest average freight for orders placed in 2015
-- Tables involved: Sales.Orders table
Select top (3) shiptocountry,AVG(freight) as average_freight
From [Sales].[Order]
Group by ShipToCountry
Order by average_freight DESC
-- 8 
-- Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table
SELECT CustomerId,orderdate, OrderId,ROW_NUMBER() OVER(PARTITION BY customerid order by orderdate) as rownum
FROM [Sales].[uvw_OrderTotalQuantityAndTotalDiscountedAmount]
Order by CustomerId
-- 9
-- Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HR.Employees table
Select employeeid, employeefirstname,employeelastname,employeetitleofcourtesy,
 Case employeetitleofcourtesy
  WHEN 'Mr.' THEN 'Male'
  WHEN 'Mrs.' THEN 'Female'
  WHEN 'Ms.' THEN 'Female'
 Else 'Unknown'
 End as gender
from [HumanResources].[Employee]
-- 10
-- Return for each customer the customer ID and region
-- sort the rows in the output by region
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULLs sort first
-- Tables involved: Sales.Customers table
Select customerid, CustomerRegion
From [Sales].[Customer]
order by 
 case when CustomerRegion is null then 1 else 0 end, 
 CustomerRegion
