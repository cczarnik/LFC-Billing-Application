/****** Object:  Table [dbo].[FlightTimeMonthly]    Script Date: 5/12/2019 6:24:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FlightTimeMonthly](
	[FlightTimeMonthlyID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodEnding] [date] NULL,
	[Pilot] [varchar](255) NULL,
	[CustomerID] [int] NULL,
	[Hours5NA] [float] NULL,
	[Hours79G] [float] NULL,
	[Hours5QR] [float] NULL,
	[HoursMFT] [float] NULL,
	[HoursBasis] [float] NULL,
	[DateModified] [datetime] NULL,
	[FlightYear] [int] NULL,
	[RecurMinFlightVariance] [float] NULL
) ON [PRIMARY]
GO


