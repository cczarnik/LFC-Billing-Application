/****** Object:  StoredProcedure [dbo].[InsertFlightDetails]    Script Date: 5/12/2019 6:25:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DECLARE @PeriodEnding DATE = '12/31/2017'
--DECLARE @InvoiceDate DATE = '1/3/2018'
--DECLARE @DueDate DATE = '1/31/2018'
--DECLARE @FlightYear INT = 2017

CREATE PROCEDURE [dbo].[InsertFlightDetails] @PeriodEnding DATE, @InvoiceDate Date, @DueDate Date, @FlightYear INT
AS
--Inserts FlightTime Columns from LogSheet  
  INSERT INTO FlightTime (aircraft, FlightDate, billdate, Pilot, CustomerID, Hobbsout, hobbsin, flighttime, FlightTimeSKU, FlightTimeCharge, logsheetid, DateModified, FlightYear, PeriodEnding)
  SELECT aircraft, FlightDate, billdate, Pilot, CustomerID, Hobbsout, hobbsin, flighttime, FlightTimeSKU, FlightTimeCharge, logsheetid, getdate(), FlightYear, PeriodEnding  from logsheet
  WHERE @PeriodEnding = PeriodEnding

  --Flight Time Monthly Accruals
--Base Members And MFT Basis Calculation
  INSERT INTO FlightTimeMonthly (PeriodEnding, Pilot, CustomerID, HoursBasis, DateModified, FlightYear, RecurMinFlightVariance) 
  SELECT @PeriodEnding, CustomerName, CustomerID, RecurMinFlight + COALESCE(RecurMinFlightVariance, 0), GETDATE(), @FlightYear, RecurMinFlightVariance FROM Members WHERE BeginDate <= @PeriodEnding AND (EndDate IS NULL OR EndDate >= @PeriodEnding)
  
----5NA Totals
  UPDATE FlightTimeMonthly
  SET Hours5NA = (SELECT COALESCE(SUM(F.FlightTime),0) from FlightTime F
  WHERE F.Aircraft = '5NA' AND F.PeriodEnding = @PeriodEnding AND F.CUSTOMERID = FlightTimeMonthly.CustomerID)
  WHERE FlightTimeMonthly.PeriodEnding = @PeriodEnding 

  ----79G Totals
  UPDATE FlightTimeMonthly
  SET Hours79G = (SELECT COALESCE(SUM(F.FlightTime),0) from FlightTime F
  WHERE F.Aircraft = '79G' AND F.PeriodEnding = @PeriodEnding AND F.CUSTOMERID = FlightTimeMonthly.CustomerID)
  WHERE FlightTimeMonthly.PeriodEnding = @PeriodEnding 

  --5QR Totals
  UPDATE FlightTimeMonthly
  SET Hours5QR = (SELECT COALESCE(SUM(F.FlightTime),0) from FlightTime F
  WHERE F.Aircraft = '5QR' AND F.PeriodEnding = @PeriodEnding AND F.CUSTOMERID = FlightTimeMonthly.CustomerID)
  WHERE FlightTimeMonthly.PeriodEnding = @PeriodEnding 
  

  --Adjust Basis for members with a MFT flight time variance, but had flight time for a month
  --For a member who flew, it should be actual flight time up to the base recurring minimum flight.  Uses the RecurMinFlightVariance Column to adjust
  UPDATE FlightTimeMonthly
  SET HoursBasis = CASE 
						WHEN Hours5NA + Hours5QR + Hours79G > HoursBasis - RecurMinFlightVariance THEN HoursBasis - RecurMinFlightVariance --EXCEEDS standard basis, use basis (without the variance)
						WHEN Hours5NA + Hours5QR + Hours79G < HoursBasis - RecurMinFlightVariance THEN ROUND(Hours5NA + Hours5QR + Hours79G,2) --OTHERWISE USE THE ACTUAL TIME (AND SET IT TO ZERO IF NO TIME)
					END
  WHERE RecurMinFlightVariance < 0 AND PeriodEnding = @PeriodEnding
	
  --Minimum Flight Time Charged and Logged
  --Need MFT Billed for shortage
	UPDATE FlightTimeMonthly SET HoursMFT = (SELECT ROUND(SUM(HoursBasis) - coalesce(sum(hoursMFT),0) - (sum(hours5na) + sum(hours79g) + sum(hours5qr)),2)
											from FlightTimeMonthly f1
											INNER JOIN MEMBERS M ON f1.CustomerID = M.CustomerID
											where f1.flightyear = @FlightYear 
											AND M.BeginDate <= @PeriodEnding AND (M.EndDate IS NULL OR M.EndDate >= @PeriodEnding)
											AND FlightTimeMonthly.PeriodEnding = @PeriodEnding and FlightTimeMonthly.CustomerID = f1.CustomerID
											group by f1.customerid, piloT
											HAVING round(SUM(HoursBasis) - coalesce(sum(hoursMFT),0) - (sum(hours5na) + sum(hours79g) + sum(hours5qr)),2) > 0)
											WHERE FlightTimeMonthly.PeriodEnding = @PeriodEnding and FlightTimeMonthly.HoursMFT IS NULL

--Trending over Basis - set to zero because no unused MFT has been accrued
	UPDATE FlightTimeMonthly SET HoursMFT = (SELECT 0
											from FlightTimeMonthly f1
											INNER JOIN MEMBERS M ON f1.CustomerID = M.CustomerID
											where f1.flightyear = @FlightYear 
											AND M.BeginDate <= @PeriodEnding AND (M.EndDate IS NULL OR M.EndDate >= @PeriodEnding)
											AND FlightTimeMonthly.PeriodEnding = @PeriodEnding and FlightTimeMonthly.CustomerID = f1.CustomerID
											group by f1.customerid, piloT
											HAVING round(SUM(HoursBasis) - coalesce(sum(hoursMFT),0) - (sum(hours5na) + sum(hours79g) + sum(hours5qr)),2) <= 0 AND coalesce (round(sum(HoursMFT),2),0) = 0)
											WHERE FlightTimeMonthly.PeriodEnding = @PeriodEnding and FlightTimeMonthly.HoursMFT IS NULL

--Trending over Basis - credit previously purchased MFT
UPDATE FlightTimeMonthly SET HoursMFT = (SELECT CASE WHEN  round(SUM(HoursBasis) - coalesce(sum(hoursMFT),0) - (sum(hours5na) + sum(hours79g) + sum(hours5qr)),2) > -coalesce (round(sum(HoursMFT),2),0) 
												THEN round(SUM(HoursBasis) - coalesce(sum(hoursMFT),0) - (sum(hours5na) + sum(hours79g) + sum(hours5qr)),2) 
												ELSE -COALESCE(round(sum(HoursMFT),2),0) END
											from FlightTimeMonthly f1
											INNER JOIN MEMBERS M ON f1.CustomerID = M.CustomerID
											where f1.flightyear = @FlightYear 
											AND M.BeginDate <= @PeriodEnding AND (M.EndDate IS NULL OR M.EndDate >= @PeriodEnding)
											AND FlightTimeMonthly.PeriodEnding = @PeriodEnding and FlightTimeMonthly.CustomerID = f1.CustomerID
											group by f1.customerid, piloT
											HAVING round(SUM(HoursBasis) - coalesce(sum(hoursMFT),0) - (sum(hours5na) + sum(hours79g) + sum(hours5qr)),2) <= 0)
											WHERE FlightTimeMonthly.PeriodEnding = @PeriodEnding and FlightTimeMonthly.HoursMFT IS NULL

--Create an invoice message to be used for all line items later.
IF OBJECT_ID('tempdb..#InvMessage') IS NOT NULL DROP TABLE #InvMessage
CREATE TABLE #InvMessage (CustomerID INT, Message VARCHAR(MAX))
INSERT INTO #InvMessage (CustomerID, Message)
SELECT F.CustomerID, 'Month Ending ' 
	+ convert(varchar(10), cast(@PeriodEnding as date), 101) +'.  You have flown ' 
	+ CAST(SUM(Hours5NA)+SUM(Hours79G)+SUM(Hours5QR) AS VARCHAR(10)) + ' hours this year, beginning 7/1/' + cast(@flightyear as varchar(20)) + '.  You have ' 
	+ CAST(ROUND(SUM(HoursMFT),2) AS VARCHAR(10)) + ' hours Unused Minimum Flight Time, including any invoiced on this statement.  Minimum Flight Time must be used within the current flight year, which ends on 6/30/'
	+ CAST(@flightyear+1 as varchar(20)) + ', and cannot be carried beyond that date.  IMPORTANT:  If you pay by check, you agree to let us make a one-time electronic debit from your bank account equal to the amount of the check on or after the day it was received.'
FROM Members M
INNER JOIN FlightTimeMonthly F ON M.CustomerID = F.CustomerID AND F.FlightYear = @flightyear
WHERE M.BeginDate <= @PeriodEnding AND (M.EndDate IS NULL OR M.EndDate >= @PeriodEnding) --get only active members
GROUP BY F.CustomerID

--Fuel
  INSERT INTO FuelReimb (aircraft, FlightDate, billdate, Pilot, CustomerID, FuelReimbPaid, FuelReimbGallons, FuelReimbPPG, FuelReimbDesc, FuelReimbSKU, FuelReimbCharge, logsheetid, DateModified, FlightYear, PeriodEnding)
  SELECT aircraft, FlightDate, billdate, Pilot, CustomerID, FuelReimbPaid, FuelReimbGallons, FuelReimbPPG, FuelReimbDesc, FuelReimbSKU, FuelReimbCharge, logsheetid, getdate(), FlightYear, PeriodEnding  from logsheet
  WHERE @PeriodEnding = PeriodEnding And FuelReimbCharge <> 0

  INSERT INTO FuelSurch (aircraft, FlightDate, billdate, Pilot, CustomerID, FuelSurchGallonCredit, FuelSurchSKU, FuelSurchCharge, logsheetid, DateModified, FlightYear, PeriodEnding, FuelSurchDesc)
  SELECT aircraft, FlightDate, billdate, Pilot, CustomerID, FuelSurchGallonCredit, FuelSurchSKU, FuelSurchCharge, logsheetid, getdate(), FlightYear, PeriodEnding, FuelSurchDesc from logsheet
  WHERE @PeriodEnding = PeriodEnding And FuelSurchCharge <> 0

--Inserts DUES line item each month into the invoice line table.
INSERT INTO InvoiceLine (
InvoiceNo, 
Customer, 
InvoiceDate, 
DueDate, 
MessageDisplayedOnInvoice, 
Email,
DiscountPercent, 
DiscountAccount, 
LineItemServiceDate, 
LineItem, 
LineItemDescription, 
LineItemQuantity, 
LineItemRate, 
LineItemAmount, 
FlightYear, 
PeriodEnding)

SELECT 
CONVERT(CHAR(2),(YEAR(@PeriodEnding ) % 100 )) + CONVERT(CHAR(2),RIGHT('00000' + REPLACE(month(@periodending),'-',''), 2)) + RIGHT('00000' + REPLACE(m.CustomerID,'-',''), 3) InvoiceNo, 
CustomerName, 
@InvoiceDate, 
@DueDate, 
Message,
Email, 
Discount * 100, 
'Discounts/Refunds Given',
@PeriodEnding, 
SKU, 
ServiceName, 
1.0, 
RecurDues, 
1.0*RecurDues, 
@FlightYear, 
@PeriodEnding 
FROM Members M
INNER JOIN Services S ON S.SKU = 'DUES'
INNER JOIN #InvMessage MSG on m.CustomerID = msg.CustomerID
WHERE BeginDate <= @PeriodEnding AND (EndDate IS NULL OR EndDate >= @PeriodEnding) AND RecurDues > 0

--Insert OFFT
INSERT INTO InvoiceLine (
InvoiceNo, 
Customer, 
InvoiceDate, 
DueDate, 
MessageDisplayedOnInvoice, 
Email,
DiscountPercent, 
DiscountAccount, 
LineItemServiceDate, 
LineItem, 
LineItemDescription, 
LineItemQuantity, 
LineItemRate, 
LineItemAmount, 
FlightYear, 
PeriodEnding)

SELECT 
CONVERT(CHAR(2),(YEAR(@PeriodEnding ) % 100 )) + CONVERT(CHAR(2),RIGHT('00000' + REPLACE(month(@periodending),'-',''), 2)) + RIGHT('00000' + REPLACE(m.CustomerID,'-',''), 3) InvoiceNo, 
CustomerName, 
@InvoiceDate, 
@DueDate, 
Message,
Email, 
Discount * 100, 
'Discounts/Refunds Given',
@PeriodEnding, 
SKU,
ServiceName,  
REcurFreeFlight, 
Price,
RecurFreeFlight * Price,  
@FlightYear, 
@PeriodEnding 
FROM Members M
INNER JOIN Services S ON S.SKU = 'OFFT'
INNER JOIN #InvMessage MSG on m.CustomerID = msg.CustomerID
WHERE BeginDate <= @PeriodEnding AND (EndDate IS NULL OR EndDate >= @PeriodEnding) AND RecurFreeFlight > 0

--Insert FlightTime
INSERT INTO InvoiceLine (
InvoiceNo, 
Customer, 
InvoiceDate, 
DueDate, 
MessageDisplayedOnInvoice, 
Email,
DiscountPercent, 
DiscountAccount, 
LineItemServiceDate, 
LineItem, 
LineItemDescription, 
LineItemQuantity, 
LineItemRate, 
LineItemAmount, 
FlightYear, 
PeriodEnding)

SELECT 
CONVERT(CHAR(2),(YEAR(@PeriodEnding ) % 100 )) + CONVERT(CHAR(2),RIGHT('00000' + REPLACE(month(@periodending),'-',''), 2)) + RIGHT('00000' + REPLACE(m.CustomerID,'-',''), 3) InvoiceNo,  
Pilot, 
@InvoiceDate, 
@DueDate, 
Message,
Email, 
Discount * 100, 
'Discounts/Refunds Given',
FlightDate, 
SKU,
ServiceName,  
FlightTime, 
Price,
FlightTime * Price,  
@FlightYear, 
@PeriodEnding 
FROM FlightTime F
INNER JOIN Members M ON F.CustomerID = M.CustomerID
INNER JOIN Services S ON S.SKU LIKE Aircraft + 'FLT'
INNER JOIN #InvMessage MSG on m.CustomerID = msg.CustomerID
WHERE @PeriodEnding = f.PeriodEnding

--Insert Fuel Surcharge
INSERT INTO InvoiceLine (
InvoiceNo, 
Customer, 
InvoiceDate, 
DueDate, 
MessageDisplayedOnInvoice, 
Email,
DiscountPercent, 
DiscountAccount, 
LineItemServiceDate, 
LineItem, 
LineItemDescription, 
LineItemQuantity, 
LineItemRate, 
LineItemAmount, 
FlightYear, 
PeriodEnding)

SELECT 
CONVERT(CHAR(2),(YEAR(@PeriodEnding ) % 100 )) + CONVERT(CHAR(2),RIGHT('00000' + REPLACE(month(@periodending),'-',''), 2)) + RIGHT('00000' + REPLACE(m.CustomerID,'-',''), 3) InvoiceNo, 
Pilot, 
@InvoiceDate, 
@DueDate, 
Message,
Email, 
Discount * 100, 
'Discounts/Refunds Given',
FlightDate, 
SKU,
FuelSurchDesc,  
1.0, 
FuelSurchCharge,
1.0*FuelSurchCharge,  
@FlightYear, 
@PeriodEnding 
FROM FuelSurch F
INNER JOIN Members M ON F.CustomerID = M.CustomerID
INNER JOIN Services S ON S.SKU LIKE Aircraft + 'FUELSCG'
INNER JOIN #InvMessage MSG on m.CustomerID = msg.CustomerID
WHERE @PeriodEnding = f.PeriodEnding

--Insert Fuel Reimb
INSERT INTO InvoiceLine (
InvoiceNo, 
Customer, 
InvoiceDate, 
DueDate, 
MessageDisplayedOnInvoice, 
Email,
DiscountPercent, 
DiscountAccount, 
LineItemServiceDate, 
LineItem, 
LineItemDescription, 
LineItemQuantity, 
LineItemRate, 
LineItemAmount, 
FlightYear, 
PeriodEnding)

SELECT 
CONVERT(CHAR(2),(YEAR(@PeriodEnding ) % 100 )) + CONVERT(CHAR(2),RIGHT('00000' + REPLACE(month(@periodending),'-',''), 2)) + RIGHT('00000' + REPLACE(m.CustomerID,'-',''), 3) InvoiceNo,  
Pilot, 
@InvoiceDate, 
@DueDate, 
Message,
Email, 
Discount * 100, 
'Discounts/Refunds Given',
FlightDate, 
SKU,
FuelReimbDesc,  
1.0, 
FuelReimbCharge,
1.0*FuelReimbCharge,  
@FlightYear, 
@PeriodEnding 
FROM FuelReimb F
INNER JOIN Members M ON F.CustomerID = M.CustomerID
INNER JOIN Services S ON S.SKU LIKE Aircraft + 'FUELRMB'
INNER JOIN #InvMessage MSG on m.CustomerID = msg.CustomerID
WHERE @PeriodEnding = f.PeriodEnding

--Insert MFT
INSERT INTO InvoiceLine (
InvoiceNo, 
Customer, 
InvoiceDate, 
DueDate, 
MessageDisplayedOnInvoice, 
Email,
DiscountPercent, 
DiscountAccount, 
LineItemServiceDate, 
LineItem, 
LineItemDescription, 
LineItemQuantity, 
LineItemRate, 
LineItemAmount, 
FlightYear, 
PeriodEnding)

SELECT 
CONVERT(CHAR(2),(YEAR(@PeriodEnding ) % 100 )) + CONVERT(CHAR(2),RIGHT('00000' + REPLACE(month(@periodending),'-',''), 2)) + RIGHT('00000' + REPLACE(m.CustomerID,'-',''), 3) InvoiceNo, 
Pilot, 
@InvoiceDate, 
@DueDate, 
Message,
Email, 
Discount * 100, 
'Discounts/Refunds Given',
@PeriodEnding, 
SKU,
ServiceName,  
Round(HoursMFT,2), 
Price,
HoursMFT*Price,  
@FlightYear, 
@PeriodEnding 
FROM FlightTimeMonthly F
INNER JOIN Members M ON F.CustomerID = M.CustomerID
INNER JOIN Services S ON S.SKU = 'MINFLT'
INNER JOIN #InvMessage MSG on m.CustomerID = msg.CustomerID
WHERE @PeriodEnding = f.PeriodEnding and ROUND(HoursMFT,2) <> 0

GO


