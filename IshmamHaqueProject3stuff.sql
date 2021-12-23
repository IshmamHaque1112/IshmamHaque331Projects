SET ANSI_WARNINGS OFF;
Go
use  QueensClassSchedule;
go
create schema udt;
go 
Create Schema [Project3];
Go
Create Schema [Department];
Go
Create Schema [Instructor];
Go
create type udt.surrogatekeysmallint from smallint not null;
create type udt.smallnumber  from smallint null;
create type udt.[description] from varchar(100) null;
create type udt.datemodified from datetime2(7) null ;
create type udt.smallchar from varchar(6) null; 
create type [udt].[individualproject] from  nvarchar (60) null; 
create type udt.[name] from  varchar(50)   null;
-- does not work
--create type udt.classtime from time(8,0) null;
create type udt.tinychar from varchar(2) null;
create type udt.tinynumber from tinyint  null;
-- same as description from top so changed it to description 2
create type udt.[description2] from varchar(6) null ;
Go
Drop Table If Exists [Department].[Department]
Create Table [Department].[Department]
(
 DepartmentKey udt.surrogatekeysmallint IDENTITY(1,1) NOT NULL, 
 DepartmentName udt.smallchar null,
 [UserAuthorizationKey] Udt.SurrogateKeySmallInt NOT NULL DEFAULT 0,
 [DateAdded] Udt.DateModified NOT NULL DEFAULT SYSDATETIME(),
 [DateOfLastUpdate] Udt.DateModified NOT NULL DEFAULT SYSDATETIME(),
 PRIMARY KEY CLUSTERED 
(
	[DepartmentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
Go
Alter Table [Department].[Department]
Add Constraint pk_DepartmentKey Primary Key (DepartmentKey)
Go
SET ANSI_WARNINGS ON;
DROP VIEW IF EXISTS [Department].[DepartmentView]
go
CREATE VIEW [Department].[DepartmentView] AS
SELECT DISTINCT
CASE
	WHEN Len([Course (hr, crd)])>0 THEN SUBSTRING([Course (hr, crd)],0,CHARINDEX(' ',[Course (hr, crd)]))
	END AS DepartmentName
FROM [Uploadfile].[CurrentSemesterCourseOfferings]
Go
INSERT INTO [Department].[Department] (DepartmentName)
SELECT (DepartmentName) FROM [Department].[DepartmentView]
ORDER BY DepartmentName ASC
Go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Project3].[Load_Department] @GroupMemberUserAuthorizationKey INT
AS
BEGIN
SET NOCOUNT ON;
DECLARE @DateAdded AS DATETIME2 = SYSDATETIME();
DECLARE @DateOfLastUpdate AS DATETIME2 = SYSDATETIME();
DECLARE @StartDate AS DATETIME2 = SYSDATETIME();
INSERT INTO [Department].[Department]
(
    DepartmentName,
    UserAuthorizationKey,
    DateAdded,
    DateOfLastUpdate
)
SELECT DISTINCT
    DepartmentName,
    @GroupMemberUserAuthorizationKey,
    @DateAdded,
    @DateOfLastUpdate
FROM [Department].[DepartmentView]
EXEC [Process].[usp_TrackWorkFlows] @StartTime = @StartDate,
									@WorkFlowDescription = 'Loaded the [Department].[Department] table',
									@WorkFlowStepTableRowCount = @@ROWCOUNT,
									@UserAuthorizationKey = @GroupMemberUserAuthorizationKey;
END
Go
SET ANSI_WARNINGS OFF;
Drop Table If Exists [Queens_Class].[Instructor]
Create Table [Instructor].[Instructor]
(
 InstructorKey udt.surrogatekeysmallint IDENTITY(1,1) NOT NULL,
 DepartmentKey udt.surrogatekeysmallint  NOT NULL, 
 CourseKey udt.surrogatekeysmallint NOT NULL,
 InstructorDetailKey udt.surrogatekeysmallint NOT NULL,
 [UserAuthorizationKey] Udt.SurrogateKeySmallInt NOT NULL DEFAULT 0,
 [DateAdded] Udt.DateModified NOT NULL DEFAULT SYSDATETIME(),
 [DateOfLastUpdate] Udt.DateModified NOT NULL DEFAULT SYSDATETIME(),
PRIMARY KEY CLUSTERED 
(
	[InstructorKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
Alter Table [Instructor].[Instructor]
Add Constraint pk_InstructorKey Primary Key (InstructorKey)
Go
ALTER TABLE [Instructor].[Instructor]
ADD CONSTRAINT FK_DepartmentKey
FOREIGN KEY (DepartmentKey) REFERENCES [Department].[Department](DepartmentKey);
Go
SET ANSI_WARNINGS ON;
DROP VIEW IF EXISTS [Instructor].[InstructorView]
go
CREATE VIEW [Instructor].[InstructorView] AS
SELECT DISTINCT I.InstructorDetailKey,D.DepartmentKey,C.CourseKey
FROM [Uploadfile].[CurrentSemesterCourseOfferings] as UF
 Inner join [Department].[Department] as D
  ON D.DepartmentName=SUBSTRING(UF.[Course (hr, crd)],0,CHARINDEX(' ',UF.[Course (hr, crd)]))
 Inner join Course.Course as C
  ON C.coursename=SUBSTRING([Course (hr, crd)], 0, PATINDEX('%(%', [Course (hr, crd)]) - 1)
 Inner join [Instructor].[InstructorDetail] as I
  ON I.FullName=UF.Instructor
Go
INSERT INTO [Instructor].[Instructor](InstructorDetailKey,DepartmentKey,CourseKey)
SELECT InstructorDetailKey,DepartmentKey,CourseKey FROM [Instructor].[InstructorView]

ORDER BY InstructorDetailKey ASC
Go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Project3].[Load_Instructor] @GroupMemberUserAuthorizationKey INT
AS
BEGIN
SET NOCOUNT ON;
DECLARE @DateAdded AS DATETIME2 = SYSDATETIME();
DECLARE @DateOfLastUpdate AS DATETIME2 = SYSDATETIME();
DECLARE @StartDate AS DATETIME2 = SYSDATETIME();
INSERT INTO [Instructor].[Instructor]
(
    InstructorDetailKey,
    DepartmentKey, 
    CourseKey,
    UserAuthorizationKey,
    DateAdded,
    DateOfLastUpdate
)
SELECT DISTINCT
    InstructorDetailKey,
    DepartmentKey, 
    CourseKey,
    @GroupMemberUserAuthorizationKey,
    @DateAdded,
    @DateOfLastUpdate
FROM [Instructor].[InstructorView]
EXEC [Process].[usp_TrackWorkFlows] @StartTime = @StartDate,
									@WorkFlowDescription = 'Loaded the [Instructor].[Instructor] table',
									@WorkFlowStepTableRowCount = @@ROWCOUNT,
									@UserAuthorizationKey = @GroupMemberUserAuthorizationKey;
END;
GO
ALTER TABLE [Instructor].[Instructor]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentKey] FOREIGN KEY([DepartmentKey])
REFERENCES [Department].[Department] ([DepartmentKey])
GO
ALTER TABLE [Instructor].[Instructor] CHECK CONSTRAINT [FK_DepartmentKey]
GO
ALTER TABLE [Instructor].[Instructor]  WITH CHECK ADD  CONSTRAINT [FK_CourseKey] FOREIGN KEY([CourseKey])
REFERENCES [Course].[Course] ([CourseKey])
GO
ALTER TABLE [Instructor].[Instructor] CHECK CONSTRAINT [FK_CourseKey]
GO
ALTER TABLE [Instructor].[Instructor]  WITH CHECK ADD  CONSTRAINT [FK_InstructorDetailKey] FOREIGN KEY([InstructorDetailKey])
REFERENCES [Instructor].[InstructorDetail] ([InstructorDetailKey])
GO
ALTER TABLE [Instructor].[Instructor] CHECK CONSTRAINT [FK_InstructorDetailKey]
GO
Select * from [Uploadfile].[CurrentSemesterCourseOfferings]
Select * from [Department].[Department]
Select * from [Instructor].[Instructor]