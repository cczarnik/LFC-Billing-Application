/****** Object:  Table [dbo].[FuelSurch]    Script Date: 5/12/2019 6:24:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FuelSurch](
	[FuelSchgID] [int] IDENTITY(1,1) NOT NULL,
	[Aircraft] [varchar](20) NULL,
	[FlightDate] [datetime] NULL,
	[BillDate] [datetime] NULL,
	[Pilot] [varchar](255) NULL,
	[CustomerID] [int] NULL,
	[FuelSurchGallonCredit] [float] NULL,
	[FuelSurchSKU] [varchar](20) NULL,
	[FuelSurchCharge] [money] NULL,
	[LogSheetID] [int] NULL,
	[DateModified] [datetime] NULL,
	[FlightYear] [int] NULL,
	[PeriodEnding] [date] NULL,
	[FuelSurchDesc] [varchar](1000) NULL
) ON [PRIMARY]
GO


