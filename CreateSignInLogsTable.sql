/****** Set the database to create the table in - <Database> ******/
USE [<Database>]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/****** Set the Table to create - <TableName> ******/

CREATE TABLE [dbo].[<TableName>](
	[Id] [nvarchar](max) NULL,
	[CreatedDateTime] [nvarchar](max) NULL,
	[UserDisplayName] [nvarchar](max) NULL,
	[UserPrincipalName] [nvarchar](max) NULL,
	[UserId] [nvarchar](max) NULL,
	[AppId] [nvarchar](max) NULL,
	[AppDisplayName] [nvarchar](max) NULL,
	[IpAddress] [nvarchar](max) NULL,
	[ClientAppUsed] [nvarchar](max) NULL,
	[CorrelationId] [nvarchar](max) NULL,
	[ConditionalAccessStatus] [nvarchar](max) NULL,
	[IsInteractive] [nvarchar](max) NULL,
	[RiskDetail] [nvarchar](max) NULL,
	[RiskLevelAggregated] [nvarchar](max) NULL,
	[RiskLevelDuringSignIn] [nvarchar](max) NULL,
	[RiskState] [nvarchar](max) NULL,
	[RiskEventTypes] [nvarchar](max) NULL,
	[RiskEventTypes_v2] [nvarchar](max) NULL,
	[ResourceDisplayName] [nvarchar](max) NULL,
	[ResourceId] [nvarchar](max) NULL,
	[StatusCode] [nvarchar](max) NULL,
	[StatusFailureReason] [nvarchar](max) NULL,
	[StatusAdditionalDetails] [nvarchar](max) NULL,
	[DeviceId] [nvarchar](max) NULL,
	[DeviceDisplayName] [nvarchar](max) NULL,
	[DeviceOperatingSystem] [nvarchar](max) NULL,
	[DeviceBrowser] [nvarchar](max) NULL,
	[DeviceIsCompliant] [nvarchar](max) NULL,
	[DeviceIsManaged] [nvarchar](max) NULL,
	[DeviceTrustType] [nvarchar](max) NULL,
	[LocationCity] [nvarchar](max) NULL,
	[LocationState] [nvarchar](max) NULL,
	[LocationCountryOrRegion] [nvarchar](max) NULL,
	[LocationLatitude] [nvarchar](max) NULL,
	[LocationLongitude] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

