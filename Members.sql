/****** Object:  Table [dbo].[Members]    Script Date: 5/12/2019 6:24:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Members](
	[CustomerID] [int] NULL,
	[CustomerName] [varchar](255) NULL,
	[Company] [varchar](255) NULL,
	[Address] [varchar](255) NULL,
	[Phone] [varchar](50) NULL,
	[Email] [varchar](100) NULL,
	[DateUpdated] [datetime] NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[RecurMinFlight] [float] NULL,
	[RecurDues] [money] NULL,
	[Discount] [float] NULL,
	[RecurFreeFlight] [float] NULL,
	[RecurMinFlightVariance] [float] NULL
) ON [PRIMARY]
GO


