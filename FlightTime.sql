/****** Object:  Table [dbo].[FlightTime]    Script Date: 5/12/2019 6:23:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FlightTime](
	[FlightTimeID] [int] IDENTITY(1,1) NOT NULL,
	[Aircraft] [varchar](20) NULL,
	[FlightDate] [datetime] NULL,
	[BillDate] [datetime] NULL,
	[Pilot] [varchar](255) NULL,
	[CustomerID] [int] NULL,
	[HobbsOut] [float] NULL,
	[HobbsIn] [float] NULL,
	[FlightTime] [float] NULL,
	[FlightTimeSKU] [varchar](20) NULL,
	[FlightTimeRate] [money] NULL,
	[FlightTimeCharge] [money] NULL,
	[LogSheetID] [int] NULL,
	[DateModified] [datetime] NULL,
	[FlightYear] [int] NULL,
	[PeriodEnding] [date] NULL
) ON [PRIMARY]
GO


