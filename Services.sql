/****** Object:  Table [dbo].[Services]    Script Date: 5/12/2019 6:24:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Services](
	[ServiceName] [varchar](255) NULL,
	[Description] [varchar](255) NULL,
	[SKU] [varchar](50) NULL,
	[Type] [varchar](20) NULL,
	[Price] [money] NULL,
	[IncomeAccount] [varchar](255) NULL,
	[PurchseDescription] [varchar](255) NULL,
	[PurchaseCost] [money] NULL,
	[ExpenseAccount] [varchar](255) NULL,
	[DateUpdated] [datetime] NULL
) ON [PRIMARY]
GO


