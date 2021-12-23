USE [OldCars];
Declare @tablefordate Table(thedate date)
Declare @mindate date
Declare @maxdate date
Set @mindate = (SELECT MIN(A.DateBought) FROM [Data].[Stock] as A where Year(A.DateBought)=2015)
Set @maxdate = (SELECT MAX(DateBought) FROM [Data].[Stock])
while(@mindate<=@maxdate)
Begin
 Insert Into @tablefordate
 Select @mindate
 Select @mindate=DateADD(day,1,@mindate)
END
Drop Table if Exists [Data].[Calendar2015to2018]
Select A.thedate
Into [Data].[Calendar2015to2018]
From @tablefordate as A
alter Table [Data].[Calendar2015to2018]
Add ISOCurrency [char](3) NULL
Go
alter Table [Data].[Calendar2015to2018]
Add ExchangeRate money NULL
Go
DROP VIEW IF EXISTS [Reference].[NewForex];
GO
CREATE VIEW [Reference].[NewForex]
AS(
Select A.thedate as ExchangeDate, A.ISOCurrency as ISOCurrency, A.ExchangeRate as ExchangeRate
From [Data].[Calendar2015to2018] as A
);
GO
UPDATE [Reference].[NewForex]
SET [ISOCurrency] = ''
WHERE [ISOCurrency] IS NULL;
UPDATE [Reference].[NewForex]
SET [ExchangeRate] = CAST(0 as Money)
WHERE [ExchangeRate] IS NULL;
Select * from [Reference].[NewForex]
Drop Table if Exists [Data].[Calendar2015to2018]
Drop function if Exists Reference.ForexbyMonthandYear
GO
CREATE FUNCTION Reference.ForexbyMonthandYear (@mon as int,@yea as int) Returns Table
AS
Return
 Select *
 From [Reference].[NewForex]
 Where @mon=Month(exchangedate) and @yea=Year(exchangedate);
GO
UPDATE Data.Stock
SET ModelID = 15
WHERE ModelID = 985
UPDATE Data.Stock
SET ModelID = 0
WHERE ModelID = 458
UPDATE Data.Stock
SET ModelID = 0
WHERE ModelID = 939

SELECT --COUNT(*) AS Orphans
        t.StockID,
        t.ModelID,
        t.Cost,
        t.RepairsCost,
        t.PartsCost,
        t.TransportInCost,
        t.IsRHD,
        t.Color,
        t.BuyerComments,
        t.DateBought,
        t.TimeBought
    FROM [Data].Stock t
    WHERE NOT EXISTS
    (
        SELECT * FROM [Data].Model WHERE ModelID = t.ModelID
    )
    GROUP BY t.StockID,
             t.ModelID,
             t.Cost,
             t.RepairsCost,
             t.PartsCost,
             t.TransportInCost,
             t.IsRHD,
             t.Color,
             t.BuyerComments,
             t.DateBought,
             t.TimeBought
ALTER TABLE [Data].[Stock]
ADD  CONSTRAINT CHK_DateBought CHECK (YEAR([DateBought])>=1900 AND YEAR([DateBought])<=2021);
go
ALTER TABLE [Data].[Stock]
ADD  CONSTRAINT CHK_ModelID CHECK ([ModelID]>= 0 AND [ModelID]<= 100);
go
ALTER TABLE [Data].[PivotTable]
ADD  CONSTRAINT CHK_Color CHECK ([Color] <> NULL);
go
ALTER TABLE [Reference].[MarketingInformation]
ADD  CONSTRAINT CHK_CustomerName CHECK ([CustomerName] <> NULL);
go
ALTER TABLE [Reference].[MarketingInformation]
ADD  CONSTRAINT CHK_Country CHECK ([Country] <> NULL);
go
ALTER TABLE [Reference].[YearlySales]
ADD CONSTRAINT CHK_MakeName CHECK ([MakeName] <> NULL);
go