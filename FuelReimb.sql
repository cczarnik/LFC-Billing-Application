/****** Object:  Table [dbo].[FuelReimb]    Script Date: 5/12/2019 6:24:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FuelReimb](
	[FuelReimbID] [int] IDENTITY(1,1) NOT NULL,
	[Aircraft] [varchar](20) NULL,
	[FlightDate] [datetime] NULL,
	[BillDate] [datetime] NULL,
	[Pilot] [varchar](255) NULL,
	[CustomerID] [int] NULL,
	[FuelReimbPaid] [money] NULL,
	[FuelReimbGallons] [float] NULL,
	[FuelReimbPPG] [money] NULL,
	[FuelReimbDesc] [varchar](255) NULL,
	[FuelReimbSKU] [varchar](20) NULL,
	[FuelReimbCharge] [money] NULL,
	[LogSheetID] [int] NULL,
	[DateModified] [datetime] NULL,
	[FlightYear] [int] NULL,
	[PeriodEnding] [date] NULL
) ON [PRIMARY]
GO


