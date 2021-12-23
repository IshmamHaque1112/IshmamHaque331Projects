-- Author: --Ishmam Haque 
-- Procedure: LoadSalesManager
-- Create date: 11/6/2021
-- Description: Loads sales manager data from old data. -- 
use BICLass
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---Create columns with default values
alter table [CH01-01-Dimension].[SalesManagers]
add [UserAuthorizationKey] INT NOT NULL
alter table [CH01-01-Dimension].[SalesManagers]
add [DateAdded] datetime2 null default sysdatetime()
alter table [CH01-01-Dimension].[SalesManagers]
add [DateofLastUpdate] datetime2 null default sysdatetime()
alter table [CH01-01-Dimension].[SalesManagers]
 add constraint [SalesManager_DateAdded] default (sysdatetime()) for [DateAdded]
alter table [CH01-01-Dimension].[SalesManagers]
 add constraint [SalesManager_DateofLastUpdate] default (sysdatetime()) for [DateofLastUpdate]
Drop procedure if exists [Project2].[Load_SalesManagers];
Go
Create Procedure [Project2].[Load_SalesManagers] @GroupMemberUserAuthorizationKey AS INT
AS
Begin
Set Nocount on
ALTER SEQUENCE [CH01-01-Dimension].SeqOccupationKeys RESTART WITH 1;
 --Loads original data
Select Distinct SalesManager, @GroupMemberUserAuthorizationKey,sysdatetime()
From FileUpload.OriginallyLoadedData
Declare @counter as Int=(Select Count(*) As a from [CH01-01-Dimension].[SalesManagers]);
declare @curtime as datetime = sysdatetime()
Exec [Process].[usp_TrackWorkFlows]
@StartTime = @curtime, @WorkFlowDescription='Sales Manager Loaded', @WorkFlowStepTableRowCount=@counter, @UserAuthorizationKey=@GroupMemberUserAuthorizationKey
End;
Go