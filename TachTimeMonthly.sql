/****** Object:  Table [dbo].[TachTimeMonthly]    Script Date: 5/12/2019 6:25:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TachTimeMonthly](
	[TachTimeMonthlyID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodEnding] [date] NULL,
	[TachHours5NA] [float] NULL,
	[TachHours79G] [float] NULL,
	[TachHours5QR] [float] NULL,
	[DateModified] [datetime] NULL,
	[FlightYear] [int] NULL
) ON [PRIMARY]
GO


