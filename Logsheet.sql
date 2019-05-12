/****** Object:  Table [dbo].[LogSheet]    Script Date: 5/12/2019 6:24:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogSheet](
	[LogSheetID] [int] IDENTITY(1,1) NOT NULL,
	[Aircraft] [varchar](10) NULL,
	[FlightDate] [datetime] NULL,
	[HobbsOut] [float] NULL,
	[HobbsIn] [float] NULL,
	[Pilot] [varchar](255) NULL,
	[FuelReimbPaid] [money] NULL,
	[FuelReimbGallons] [float] NULL,
	[CustomerID] [int] NULL,
	[FlightTime] [float] NULL,
	[FlightTimeSKU] [varchar](20) NULL,
	[FlightTimeRate] [money] NULL,
	[FlightTimeCharge] [money] NULL,
	[FuelReimbPPG] [money] NULL,
	[FuelReimbDesc] [varchar](255) NULL,
	[FuelReimbSKU] [varchar](20) NULL,
	[FuelReimbCharge] [money] NULL,
	[FuelSurchGallonCredit] [float] NULL,
	[FuelSurchSKU] [varchar](20) NULL,
	[FuelSurchCharge] [money] NULL,
	[DateUpdated] [datetime] NULL,
	[BillDate] [datetime] NULL,
	[FlightYear] [int] NULL,
	[PeriodEnding] [date] NULL,
	[DueDate] [date] NULL,
	[FuelSurchDesc] [varchar](1000) NULL
) ON [PRIMARY]
GO


