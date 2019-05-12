/****** Object:  Table [dbo].[InvoiceLine]    Script Date: 5/12/2019 6:24:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoiceLine](
	[InvoiceNo] [int] NULL,
	[Customer] [varchar](255) NULL,
	[InvoiceDate] [date] NULL,
	[DueDate] [date] NULL,
	[MessageDisplayedOnInvoice] [varchar](4000) NULL,
	[Email] [varchar](255) NULL,
	[DiscountPercent] [float] NULL,
	[DiscountAccount] [varchar](100) NULL,
	[LineItemServiceDate] [date] NULL,
	[LineItem] [varchar](50) NULL,
	[LineItemDescription] [varchar](255) NULL,
	[LineItemQuantity] [float] NULL,
	[LineItemRate] [money] NULL,
	[LineItemAmount] [money] NULL,
	[FlightYear] [int] NULL,
	[PeriodEnding] [date] NULL
) ON [PRIMARY]
GO


