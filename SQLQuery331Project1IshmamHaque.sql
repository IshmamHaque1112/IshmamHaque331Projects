--Easy Query 1 -- All orders from male per geographykey
USE AdventureWorksDW2017
Select A.geographykey, COUNT(*) as maleorders
From dbo.dimCustomer as A
Where (A.Gender='M') 
Group by A.geographykey
Order by geographykey asc
-- Easy Query 2 --Customer ids that are products of 100, transaction types and amount, tax amount, and amountexcludingtax 
USE WideWorldImporters
SELECT CT.customerid,B.customername,CT.transactiontypeid, CT.transactiondate, CT.transactionamount, CT.taxamount, CT.amountexcludingtax,B.BilltoCustomerId
FROM Sales.CustomerTransactions AS CT
 INNER JOIN Sales.Customers as B
  ON B.customerid = CT.customerid
WHERE (CT.customerid%100=0)
ORDER BY CT.customerid desc, B.customername desc, CT.transactiondate desc, CT.transactiontypeid desc, CT.amountexcludingtax desc
--Easy Query 3  USA Customers that ordered between Valentines 2014 and 2016 and came from cities with first letter A, and overall price
USE TSQLV4
Select OD.orderid, O.custid,O.orderdate, (OD.unitprice*OD.qty*(1-OD.discount)) as overall_price,O.shipcountry,O.shipcity,OD.productid
From Sales.Orders as O
 Inner Join Sales.OrderDetails as OD
  ON O.orderid = OD.orderid
Where (O.shipcountry = 'USA') AND (O.orderdate Between '20140214' and '20160214') AND (O.shipcity Like N'A%')
Order by O.custid, OD.orderid, O.orderdate
--Easy Query 4 Orders and customerid, with date, required and shipped dates, and differences between dates
USE TSQLV4
Select SO.orderid,SO.custid,SO.orderdate,SO.requireddate,SO.shippeddate,DateDiff(day,SO.requireddate,SO.orderdate) AS daysorderedtorequired,
Datediff(day,SO.requireddate,SO.shippeddate) AS daysshippedtorequired,Datediff(day,SO.shippeddate,SO.orderdate) AS daysorderedtoshipped
From Sales.Orders as SO
 LEFT Outer Join Sales.OrderDetails as O
  On O.orderid=SO.orderid
Group BY SO.orderid,SO.custid,SO.orderdate,SO.requireddate,SO.shippeddate
Order BY SO.orderid desc, SO.orderdate desc
--Easy Query 5 Determines which airplane company to ship by using country variable
USE Northwinds2020TSQLV6
Select customerid, customercompanyname, customercontactname, customercity, customercountry, 
CASE customercountry
    When 'Argentina'	Then 'Latin American Airlines' 
    When 'Austria'	    Then 'European Airlines'
    When 'Belgium'	    Then 'European Airlines'
    When 'Brazil'	    Then 'Latin American Airlines'
    When 'Canada'	    Then 'North American Airlines'
    When 'Denmark'	    Then 'European Airlines'
    When 'Finland'	    Then 'European Airlines'
    When 'France'	    Then 'European Airlines'
    When 'Germany'	    Then 'European Airlines'
    When 'Ireland'	    Then 'European Airlines'
    When 'Italy'	    Then 'European Airlines'
    When 'Mexico'	    Then 'Latin American Airlines'
    When 'Norway'	    Then 'European Airlines'
    When 'Poland'	    Then 'European Airlines'
    When 'Portugal'	    Then 'European Airlines'
    When 'Spain'	    Then 'European Airlines'
    When 'Sweden'	    Then 'European Airlines'
    When 'Switzerland'	Then 'European Airlines'
    When 'UK'	        Then 'European Airlines'
    When 'USA'	        Then 'North American Airlines'
    When 'Venezuela'	Then 'Latin American Airlines'
    ELSE 'Unknown Company'
  END AS airplanecompanytoshipby
From Sales.Customer;
--Easy Query 6 Cities named less than 4 characters
use WideWorldImportersDW
Select Distinct city,country,continent,region
From Dimension.City
Where city <> 'Unknown' and len(city)<4
--Medium Query 1--  suppliers from countries beginning with S with the least products and suppliercontactname is less than 20 characters
USE Northwinds2020TSQLV6
DROP TABLE IF EXISTS Sales.totalnumberofsupplierproducts;
Select S.supplierid, S.suppliercompanyname, S.suppliercontactname, S.suppliercountry, COUNT(*) as totalproducts
INTO Sales.totalnumberofsupplierproducts
From Production.Supplier as S
 Left Outer Join Production.Product as P
   ON S.supplierid = P.supplierid
Group BY S.supplierid,S.suppliercompanyname, S.suppliercontactname, S.suppliercountry;
Select S.supplierid,S.suppliercompanyname, S.suppliercontactname, S.suppliercountry, S.totalproducts
From Sales.totalnumberofsupplierproducts as S
Where S.totalproducts IN (SELECT MIN(O.totalproducts) FROM Sales.totalnumberofsupplierproducts as O WHERE O.suppliercountry like N'S%' ) 
and S.suppliercontactname in (SELECT O.suppliercontactname FROM Sales.totalnumberofsupplierproducts AS O WHERE LEN(O.suppliercontactname)<20) and S.suppliercountry like N'S%'
Order by S.totalproducts
DROP TABLE IF EXISTS Sales.totalnumberofsupplierproducts
--Medium Query 2 Businesses,People with address type 3, their respective info, and how many contacts does each business have with address type 3
Use AdventureWorks2017
Select C.BusinessEntityID, C.PersonID, A.addressid, A.addresstypeid,C.Contacttypeid,ROW_NUMBER() OVER(PARTITION BY C.BusinessEntityId
                    ORDER BY C.PersonID) AS numberofuniquecontactsfrombusiness, A.modifieddate
from Person.BusinessEntityContact as C
 Inner join Person.BusinessEntityAddress as A
  On A.businessentityid=C.businessentityid 
Where Contacttypeid in (Select MIN(ContacttypeID) from Person.BusinessEntityContact) 
and addresstypeid in(SELECT O.addresstypeid FROM Person.BusinessEntityAddress AS O WHERE O.addresstypeid%2=1)
Group BY C.BusinessEntityID, C.PersonID, A.addressid, A.addresstypeid,C.Contacttypeid,A.modifieddate
Order BY C.BusinessEntityID, C.PersonID
-- Medium Query 3 Orders from May and June 2015 with orderdate, requireddate,shippeddate and differences between dates, original and discounted price, 
--and what percent is discount vs original)
USE TSQLV4
Select SO.orderid,SO.custid,SO.orderdate,SO.requireddate,SO.shippeddate,DateDiff(day,SO.requireddate,SO.orderdate) AS daysorderedtorequired,
Datediff(day,SO.requireddate,SO.shippeddate) AS daysshippedtorequired,Datediff(day,SO.shippeddate,SO.orderdate) AS daysorderedtoshipped
,O.unitprice,O.qty,O.discount,(O.unitprice*O.qty) as originalprice, (O.unitprice*O.qty)*(1-O.discount) as discountprice
,100*(((O.unitprice*O.qty)*(1-O.discount))/(O.unitprice*O.qty)) as originalvsdiscountpercent
From Sales.Orders as SO
 LEFT Outer Join Sales.OrderDetails as O
  On O.orderid=SO.orderid
Where SO.orderdate in (Select orderdate from Sales.Orders Where month(orderdate)=5 and year(orderdate)=2015) and SO.requireddate in (Select requireddate from Sales.Orders Where month(requireddate)=6 and day(requireddate)%4=0)
Group BY SO.orderid,SO.custid,SO.orderdate,SO.requireddate,SO.shippeddate,O.unitprice,O.qty,O.discount
Order BY SO.orderid desc, SO.orderdate desc;
--Medium Query 4 Create employee CTE of info of employees who shipped to France that were hired before December 12 2015 and birthdate less than 1990
With EmployeeCTE AS(
Select H.empid,H.title,H.firstname, H.lastname, H.birthdate, H.hiredate, H.phone,
ABS(DateDiff(year,H.hiredate,H.birthdate)) as ageofhire,ABS(Datediff(year,O.orderdate,H.hiredate)) as yearofworkdonewhenorderdone, 
O.orderid,O.orderdate,O.custid,(OD.unitprice*OD.qty*(1-OD.discount)) as overall_price
From HR.Employees as H
 Left Outer Join Sales.Orders as O
  ON O.empid = H.empid
 Left Outer Join Sales.OrderDetails as OD
  ON O.orderid = OD.orderid
Where O.shipcountry in (Select shipcountry from Sales.Orders where shipcountry = 'France') AND H.hiredate in(Select MIN(hiredate) from HR.Employees where hiredate < '20151212') 
AND H.birthdate in (Select birthdate from HR.Employees where birthdate < '19900101')
Group By H.empid,H.title,H.firstname, H.lastname, H.birthdate, H.hiredate, H.phone,O.orderid,O.orderdate,O.custid,OD.unitprice,OD.qty,OD.discount
)
Select empid,title,firstname,lastname,birthdate,hiredate,phone,COUNT(*) as totalorders, SUM(overall_price) as totalpricesofallorders
From EmployeeCTE
Group BY empid,title,firstname,lastname,birthdate,hiredate,phone
--Medium Query 5 Changes salaries based on organization level, then choose employee from top department id whose new payrate is less than 50 
use AdventureWorks2017
Declare @money1 float =1.1, @money2 float=1.3, @money3 float=1.5, @money4 float=1.7, @money0 float=1.0
DROP TABLE IF EXISTS HumanResources.loggedinbusinessmembers;
Select E.BusinessEntityID, E.NationalIDNumber, E.LoginID,E.OrganizationNode, E.OrganizationLevel, E.JobTitle,EDH.DepartmentID,EDH.Shiftid, EPH.ratechangedate,
CAST(EPH.rate as float) as floatrate,EPH.payfrequency
INTO HumanResources.loggedinbusinessmembers
From HumanResources.Employee as E
 Left Outer Join HumanResources.EmployeeDepartmentHistory as EDH
  ON E.BusinessEntityID=EDH.BusinessEntityID
 Left Outer Join HumanResources.EmployeePayHistory as EPH
  ON E.BusinessEntityID=EPH.BusinessEntityID
Group BY E.BusinessEntityID, E.NationalIDNumber, E.LoginID,E.OrganizationNode, E.OrganizationLevel, E.JobTitle,EDH.DepartmentID,EDH.Shiftid, EPH.ratechangedate, EPH.rate,EPH.payfrequency;
WITH BusinessCTE as 
(
SELECT B.BusinessEntityID, B.NationalIDNumber, B.LoginID,B.OrganizationNode, B.OrganizationLevel, B.JobTitle,B.DepartmentID,B.Shiftid, B.ratechangedate,B.floatrate,B.payfrequency,
CASE B.OrganizationLevel
 When 1 THEN B.floatrate*1.1
 When 2 THEN B.floatrate*1.3
 When 3 THEN B.floatrate*1.5
 When 4 THEN B.floatrate*1.7 
 Else B.floatrate*1.0
END AS raisedpayrate,SYSDATETIME()  as newratechangedate
From HumanResources.loggedinbusinessmembers as B)
Select *
From BusinessCTE
Where departmentid in (Select MAX(DepartmentID) from BusinessCTE) and  raisedpayrate<50

--Medium Query 6 All orders of customers, discounted price and percent of total freight, quantity, and price order is
USE TSQLV4
Drop table if exists IdentityInsert.customerquer; 
Select Distinct IO.custid,IO.orderidentitykey, IO.empid, IO.orderdate,IO.freight,IO.shipname,IO.shipaddress,IO.shipcity,IO.shipregion,Io.shippostalcode,IO.shipcountry,IOD.unitprice,IOD.qty,IOD.discount,(IOD.unitprice*IOD.qty*(1-IOD.discount)) as overall_price
INTO IdentityInsert.customerquer
From IdentityInsert.Orders as IO
 Inner join IdentityInsert.OrderDetails as IOD
  On IO.OrderIdentityKey=IOD.OrderIdentityKey;
With identityCTE AS(
 Select Distinct C.custid,CAST(sum(c.freight) as float) as sumofcustomerfreight,CAST(sum(c.qty) as float) as sumofcustomerquantity,CAST(sum(c.overall_price) as float) as sumofcustomerprice
 From IdentityInsert.customerquer as C
 Group By C.custid
)
Select distinct I.custid,I.orderidentitykey, I.empid, I.orderdate,I.freight,I.shipname,I.shipaddress,I.shipcity,I.shipregion,I.shippostalcode,I.shipcountry,I.unitprice,I.qty,I.discount,I.overall_price,
100*(I.freight/J.sumofcustomerfreight) as percentoftotalfreight,100*(I.qty/J.sumofcustomerquantity) as percentoftotalquantity,100*(I.unitprice/J.sumofcustomerprice) as percentoftotalprice
From IdentityInsert.customerquer as I
 Inner join identityCTE as J
  On I.custid=J.custid
Where I.empid in (Select AVG(empid) from IdentityInsert.customerquer)
Order by I.custid
--Medium Query 7 : For each category, max and min non- discontinued project prices
Use Northwinds2020TSQLV6;
With CategoryandProduct AS(
Select C.categoryid,C.categoryname,C.description,P.productid,P.productname,P.unitprice, P.discontinued
From Production.Category as C
 Left outer join Production.Product as P
  On C.categoryid=P.categoryid
Group By C.categoryid,C.categoryname,C.description,P.productid,P.productname,P.unitprice, P.discontinued
)
Select A.categoryid,A.categoryname,A.description,
(Select Max(B.unitprice) from categoryandproduct as B where B.categoryid=A.categoryid and B.discontinued=0) as maxpossibleprice,
(Select MIN(B.unitprice) from categoryandproduct as B where B.categoryid=A.categoryid and B.discontinued=0) as minpossibleprice
FROM categoryandproduct as A
Group by A.categoryid,A.categoryname,A.description
Order BY categoryid
--Hard Query 1 Allow to search for order by customer id, possible order id, and added range, then 1000 element range around 10000
--chose orders from 2016
USE TSQLV4;
DROP FUNCTION IF EXISTS Sales.Searchfororderbycustandorderid;
GO
CREATE FUNCTION Sales.Searchfororderbycustandorderid
  (@cust as INT,@order as Int,@searchnum as Int) Returns Table
AS
RETURN
  SELECT Distinct O.orderid,O.custid,O.empid,O.orderdate,O.requireddate,O.shippeddate,O.shipperid,O.freight,O.shipname,O.shipaddress,O.shipcity,O.shipregion,O.shippostalcode,O.shipcountry
  FROM Sales.Orders as O
  Where ((O.custid=@cust) and (O.orderid between @order-@searchnum and @order+@searchnum));
GO
Select Distinct  O.orderid,O.custid,O.empid,O.orderdate,O.requireddate,O.shippeddate,O.shipperid,O.freight,O.shipname,O.shipaddress,O.shipcity,O.shipregion,O.shippostalcode,
O.shipcountry,C.companyname,Upper(C.contactname) as customername, Lower(H.FULLNAME) as employeename
From Sales.Searchfororderbycustandorderid(1,10000,1000) as O
 Inner join Sales.Customers as C
  ON C.custid=O.custid
 Inner Join HR.Employees as H
  ON H.empid=O.empid
Where year(orderdate) in (Select Max(year(orderdate)) from Sales.Orders)
GO
--Hard Query 2 Orders from April in View, function created returns employee from country, and uses to April return orders (and customer info) in which employee came from USA
DROP VIEW IF EXISTS Sales.OrdersfromApril;
GO
CREATE VIEW Sales.OrdersfromApril
AS
SELECT Distinct orderid,custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry
FROM Sales.Orders
WHERE month(orderdate)=4
Group BY orderid,custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry;
GO
Drop function if Exists Sales.employeesbycountry
GO
CREATE FUNCTION Sales.employeesbycountry (@country as nvarchar(15)) Returns Table
AS
Return
 Select *
 From HR.employees
 Where country=@country;
GO
Select O.orderid,A.custid,A.companyname,A.city, O.orderdate,B.empid,B.firstname,B.lastname,B.title,B.birthdate
From Sales.OrdersfromApril as O
 Inner join Sales.Customers as A
  ON A.custid=O.custid
 Inner join Sales.employeesbyCountry('USA') as B
  ON B.empid=O.empid
Where B.lastname in (Select lastname from HR.employees where lastname not like N'[FGT]%') 
Group BY O.orderid,A.custid,A.companyname,A.city, O.orderdate,B.empid,B.firstname,B.lastname,B.title,B.birthdate
Order by B.empid,O.orderid
GO
--Hard Query 3 Function created that filters by if entered number makes productid have remainder of 0. Returns order routings that have product id that are factors of 13,
-- and routing dates that are not 2011, cost, and cost of manufacturing per hour
USE AdventureWorks2017;
Drop function if Exists Production.filterproductidbyremainder
GO
CREATE FUNCTION Production.filterproductidbyremainder (@filterint as int) Returns Table
AS
Return
 Select WorKOrderID,Productid,OrderQTY,StockedQTY,ScrappedQty,startdate,enddate,duedate,scrapreasonid,modifieddate
 From Production.workorder
 Where productid%@filterint=0;
GO
WITH OrderRoutingstarting2012andup AS
(
  SELECT workorderid,productid,operationsequence,locationid,scheduledstartdate,scheduledenddate,actualstartdate,actualenddate,actualresourcehrs,plannedcost,actualcost,modifieddate,
  (actualcost/actualresourcehrs) as costofmanufperhour
  FROM Production.workorderrouting
  Where year(actualstartdate) <> 2011
  Group BY workorderid,productid,operationsequence,locationid,scheduledstartdate,scheduledenddate,actualstartdate,actualenddate,actualresourcehrs,plannedcost,actualcost,modifieddate,actualcost,actualresourcehrs
)
Select P.productid,P.productnumber,P.name,P.color,P.weight,P.weightunitmeasurecode,
O.workorderid,O.operationsequence,O.locationid,O.actualstartdate,O.actualenddate,O.actualresourcehrs,O.plannedcost,O.actualcost,O.costofmanufperhour,
F.OrderQTY,F.StockedQTY,F.ScrappedQty,F.startdate,F.enddate,F.duedate,F.scrapreasonid,F.modifieddate
From Production.Product as P
 Inner join OrderRoutingstarting2012andup as O
  ON O.productid=P.productid
 Inner join Production.filterproductidbyremainder(13) as F
  On F.workorderid=O.workorderid and F.productid=O.productid
Group by P.productid,P.productnumber,P.name,P.color,P.weight,P.weightunitmeasurecode,
O.workorderid,O.operationsequence,O.locationid,O.actualstartdate,O.actualenddate,O.actualresourcehrs,O.plannedcost,O.actualcost,O.costofmanufperhour,
F.OrderQTY,F.StockedQTY,F.ScrappedQty,F.startdate,F.enddate,F.duedate,F.scrapreasonid,F.modifieddate
order by P.productid
GO
--Hard query 4 Function to search for transaction by id and product and date, filter view of transactions of color black for those made in July 2013 id 793
Drop function if Exists Production.searchtransactionbyidandproductanddate
GO
CREATE FUNCTION Production.searchtransactionbyidandproductanddate (@product as int, @dateyear as int,@datemonth as int) Returns Table
AS
Return
 Select TransactionID,ProductID,ReferenceOrderID,ReferenceOrderLineId,TransactionDate,TransactionType,Quantity,ActualCost,ModifiedDate,Year(transactiondate) as transactionyear, Month(modifieddate) as transactionmonth
 From Production.TransactionHistory
 Where @product=productid and (month(transactiondate)=@datemonth) and (Year(transactiondate)=@dateyear)
 Group By TransactionID,ProductID,ReferenceOrderID,ReferenceOrderLineId,TransactionDate,TransactionType,Quantity,ActualCost,ModifiedDate;
GO
DROP VIEW IF EXISTS Production.ProductsofBlack;
GO
CREATE VIEW Production.ProductsofBlack
AS
Select Productid,name,Productnumber,color,size
From Production.Product
Where color='Black'
Go
Select A.transactionid,A.productid,A.transactiondate,A.transactiontype,A.quantity,A.actualcost,B.name,B.color, C.startdate,C.enddate,C.standardcost
From Production.searchtransactionbyidandproductanddate(793,2013,07) as A
 Inner join Production.ProductsofBlack as B
  ON A.productid=B.productid
 Inner join Production.ProductCostHistory as C
  ON C.productid=A.productid
GO
--Hard query 5 Function which filters customers whose id are products of integer and include range, Filters products between 11000 and 30118 of products of 4, and pick those with
--- territory id
Drop function if Exists Sales.CustomersBetweenIDsandfilter
GO
CREATE FUNCTION Sales.CustomersBetweenIDsandfilter (@filterint1 as int,@filterint2 as int,@filterint3 as int) Returns Table
AS
Return
Select customerid,personid,storeid,territoryid,accountnumber,rowguid,modifieddate
From Sales.Customer
Where (customerid between @filterint1 and @filterint2) and customerid%@filterint3=0;
GO
Select B.customerid,B.personid,B.storeid,B.territoryid,B.accountnumber,
A.SalesOrderID,A.productid,A.CarrierTrackingNumber,A.OrderQty,A.specialofferid,A.unitprice,A.unitpricediscount,A.Linetotal,
C.orderdate,C.salespersonid,C.duedate,C.shipdate,C.subtotal,C.taxamt, CAST(C.subtotal-C.taxamt as float) as totalprice
From Sales.CustomersBetweenIDsandfilter(11000,30118,4) as B
 Inner join Sales.SalesOrderHeader as C
  On B.customerid=C.customerid
 Inner join Sales.SalesOrderDetail as A
  On A.salesorderid=C.salesorderid
Where B.territoryid in (Select MAX(territoryid) from Sales.CustomersBetweenIDsandfilter(11000,30118,4) where territoryid%3=0)
Order by B.customerid
GO
--Hard query 6 Returns orders if either customer and employee id are factors of the other (in this case 3 and 3) and info of customer, employee,and order, and next order with both
--same customer and employee
Use Northwinds2020TSQLV6
Drop function if Exists Sales.Orderifeithercustomerandemployeesarefactorsoftheother
GO
CREATE FUNCTION Sales.Orderifeithercustomerandemployeesarefactorsoftheother (@empid as int,@custid as int) Returns Table
AS
Return
Select orderid,customerid,employeeid,shipperid,orderdate,requireddate,shiptodate,freight,shiptoname,shiptoaddress,shiptocity,shiptoregion,shiptopostalcode,shiptocountry,userauthenticationid,
dateadded,dateoflastupdate
from [Sales].[Order]
Where (@empid%@custid=0 or @custid%@empid=0) and @empid=employeeid and @custid=customerid;
Go
Select O.orderid,O.customerid,O.employeeid,O.shipperid,O.orderdate,D.unitprice,D.quantity,D.discountpercentage,
(Select MIN(A.orderid) From Sales.Orderifeithercustomerandemployeesarefactorsoftheother(3,3) as A where A.orderid>O.orderid) as Nextorderwithsamecustandemp, C.customercontactname,C.customercompanyname,
H.Employeefirstname,H.employeelastname
From Sales.Orderifeithercustomerandemployeesarefactorsoftheother(3,3) as O
 Inner join Sales.OrderDetail as D
  ON D.orderid=O.orderid
 Inner join Sales.Customer as C
  ON O.customerid=C.customerid
 Inner join HumanResources.Employee as H
  ON H.employeeid=O.employeeid
Group BY O.orderid,O.customerid,O.employeeid,O.shipperid,O.orderdate,D.unitprice,D.quantity,D.discountpercentage,
C.customercontactname,C.customercompanyname,H.Employeefirstname,H.employeelastname
GO
--Hard Query 7 Search products by supplier (in this case 20), and view includes numbering in which for each supplier, for each category within the numbering of product is to category
Drop function if Exists Production.SearchProductsbySupplier
GO
Create function Production.SearchProductsbySupplier(@supplierint as INt) returns Table
as 
return 
select S.supplierid,S.suppliercompanyname,S.suppliercontactname,S.supplieraddress,S.suppliercity,S.Suppliercountry,C.categoryid,C.categoryname,C.description,
P.productid,P.productname,P.unitprice,P.discontinued
From Production.Supplier as S
 Inner join Production.Product as P
  ON P.supplierid=S.supplierid
 Inner join Production.Category as C
  ON P.categoryid=C.categoryid
Where @supplierint=S.supplierid;
Go
DROP VIEW IF EXISTS Production.ProductsofSupplier;
GO
CREATE VIEW Production.ProductsofSupplier
AS
Select supplierid,suppliercompanyname,suppliercontactname,supplieraddress,suppliercity,Suppliercountry,categoryid,categoryname,description,
productid,productname,unitprice,discontinued,Row_Number() Over(partition BY categoryid Order by productid) as productnumbercategoryforsupplier
From Production.SearchProductsbySupplier(20)
Group BY supplierid,suppliercompanyname,suppliercontactname,supplieraddress,suppliercity,Suppliercountry,categoryid,categoryname,description,
productid,productname,unitprice,discontinued;
Go
Select supplierid,suppliercompanyname,suppliercontactname,supplieraddress,suppliercity,Suppliercountry,categoryid,categoryname,description,
productid,productname,unitprice,discontinued,productnumbercategoryforsupplier
From Production.ProductsofSupplier 
Where discontinued in (Select MIN(Cast(discontinued as int)) from Production.ProductsofSupplier)
DROP VIEW IF EXISTS Production.ProductsofSupplier;
GO
GO
--Hard query 8 Returns Business entity addresses by address type id in function, and within view finds those with max stateprovinceid from function
Use Adventureworks2017
Drop function if Exists Person.Searchaddressandbusinessbytypeid
GO
Create function Person.Searchaddressandbusinessbytypeid(@typeid as INt) returns Table
as 
return 
select AT.addresstypeid,AT.name,
A.addressid,A.addressline1,A.addressline2,A.city,A.stateprovinceid,A.postalcode
From Person.BusinessEntityAddress as BEA
 Inner join Person.AddressType as AT
  On AT.addresstypeid=BEA.addresstypeid
 Inner join Person.Address as A
  On A.addressid=BEA.addressid
Where @typeid=AT.addresstypeid;
GO
DROP VIEW IF EXISTS Person.Personsearchbytype20;
GO
CREATE VIEW Person.Personsearchbytype20
AS
Select O.addresstypeid,O.name, O.addressid,O.addressline1,O.addressline2,O.city,O.stateprovinceid,O.postalcode,
Row_Number() Over(partition BY O.stateprovinceid Order by O.postalcode) as numpostalcodeperaddress
from Person.Searchaddressandbusinessbytypeid(5) as O
Where O.stateprovinceid in (Select Max(stateprovinceid) from Person.Searchaddressandbusinessbytypeid(5))
Group BY O.addresstypeid,O.name, O.addressid,O.addressline1,O.addressline2,O.city,O.stateprovinceid,O.postalcode
Go
Select O.addresstypeid,O.name, O.addressid,O.addressline1,O.addressline2,O.city,O.stateprovinceid,O.postalcode,O.numpostalcodeperaddress
From Person.Personsearchbytype20 as O
Order by O.postalcode
GO
GO