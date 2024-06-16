-- Q1 The quantity of noodle flour sold in 2023

SELECT 
	Group_Product,
	strftime('%Y-%m',Posting_Date) AS MonthID,
	SUM(Quantity_Total) AS SUM_Quantity
From Sale_Order_Batch 
WHERE Group_Product = "NOODLE FLOUR"
AND MonthID like '2023%'
Group by MonthID ;

----------------------------------------------------------------------------------------------------------------------------------------------

