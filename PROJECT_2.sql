-- Q.1 The quantity of noodle flour sold in 2023

SELECT 
	Group_Product,
	strftime('%Y-%m',Posting_Date) AS MonthID,
	SUM(Quantity_Total) AS SUM_Quantity
From Sale_Order_Batch 
WHERE Group_Product = "NOODLE FLOUR"
AND MonthID like '2023%'
Group by MonthID ;

----------------------------------------------------------------------------------------------------------------------------------------------

-- Q.2 Top 10 customers with the most Products purchases in 2022

SELECT 
	SL.Company_name,
	strftime('%Y',SB.Posting_Date) AS YEAR,
	SUM(SB.Quantity_Total) AS SUM_Quantity
From Sale_Order_Batch AS SB , Sale_Order_List AS SL
WHERE SB.Customer = SL.Sale_Order
AND YEAR like '%2022%'
GROUP BY SL.Company_name
ORDER BY SUM_Quantity DESC
Limit 10; 

----------------------------------------------------------------------------------------------------------------------------------------------

-- Q.3 Cost price, selling price, and profit in 2023

SELECT 
	RM.MonthID,
	Round(SUM(RM.Quantity),2) AS Quantity_RM ,
	Round(SUM(FG.Quantity),2) AS Quantity_FG,
	Round(SUM(RM.Quantity - FG.Quantity),2) AS Diff,
	Round(SUM(RM.Cost),2)  AS RM_Cost,
	Round(SUM(FG.Cost),2)  AS FG_Cost,
	Round(SUM(FG.Cost - RM.Cost),2) AS Profit
FROM 
   (SELECT 
   substr(Process_Order, 9, 4) AS PO,
   strftime('%Y-%m',Posting_Date) AS MonthID,
   CASE
		WHEN Movement_type = '261' or Movement_type = '262' THEN 'RM'
		ELSE 'FG'
	END AS Type,
	ROUND(SUM(Quantity_Total),2) AS Quantity,
	ROUND(SUM(Cost),2) AS Cost
	FROM Transaction_Table
	WHERE Type = 'RM'
	GROUP by PO) AS RM ,
   (SELECT 
   substr(Process_Order, 9, 4) AS PO,
   strftime('%Y-%m',Posting_Date) AS MonthID,
   CASE
		WHEN Movement_type = '261' or Movement_type = '262' THEN 'RM'
		ELSE 'FG'
	END AS Type,
	SUM(Quantity_Total)*-1 AS Quantity,
	SUM(Cost)*-1 AS Cost
	FROM Transaction_Table
	WHERE Type = 'FG'
	GROUP by PO) AS FG
WHERE RM.PO = FG.PO
AND RM.MonthID Like '%2023%'
GROUP by RM.MonthID ; 

----------------------------------------------------------------------------------------------------------------------------------------------
--Q.4 Traceability inspection of product lot 230621 for food products
SELECT
 PKGR.PO AS PO_Packing,
 PKGR.MonthID,
 PKGR.Lot AS Lot_Packing,
 PKGR.Product_NAME,
 (CASE
		WHEN Product_NAME Like 'VITAL%' THEN 'VITAL'
		ELSE 'FOOD'
	END) AS Type,
 PKGR.Quantity_Product*-1 AS Quantity_Product,
 PDGR.PO AS PO_PD,
 PKGI.Material_Name AS WIP_NAME,
 PKGI.Batch AS Batch_WIP,
 PKGI.Quantity_Production AS Quantity_WIP,
 PDGI.Material_Name AS RM_Name,
 PDGI.Lot AS LOT_RM,
 PDGI.Quantity_Production AS Quantity_RM
FROM
	(SELECT 
		substr(TS.Process_Order, 9, 4) AS PO,
		strftime('%Y-%m',TS.Posting_Date) AS MonthID,
		substr(TS.Batch, 1, 6) AS Lot,
		ML.Material_Name AS Product_NAME,
			(CASE
			   WHEN Movement_type = '261' or Movement_type = '262' THEN 'GI'
			   ELSE 'GR'
			 END) AS Type_Process,
		OH.Order_Type,
		SUM(TS.Quantity_Total) AS Quantity_Product
		FROM Transaction_Table AS TS , Material_list AS ML , Order_Hearder AS OH
		WHERE TS.Material =  ML.Material_Number
		AND TS.Process_Order = OH.Process_Order
		AND OH.Order_Type IN ('102','199')
		AND Type_Process = 'GR'
		AND ML.Material_Name not like '%RE%'
		AND TS.Batch not like '%0'
		GROUP by TS.Process_Order,Product_NAME,Lot
		HAVING 
			SUM(TS.Quantity_Total) != 0 ) 	AS PKGR ,
	 (SELECT 
		substr(TS.Process_Order, 9, 4) AS PO,
		strftime('%Y-%m',TS.Posting_Date) AS MonthID,
		ML.Material_Name,
		TS.Batch As Batch,
			(CASE
			  WHEN Movement_type = '261' or Movement_type = '262' THEN 'GI'
			  ELSE 'GR'
			END) AS Type_Process,
		OH.Order_Type,
		SUM(TS.Quantity_Total) AS Quantity_Production
		FROM Transaction_Table AS TS , Material_list AS ML , Order_Hearder AS OH
		WHERE TS.Material =  ML.Material_Number
		AND TS.Process_Order = OH.Process_Order
		AND OH.Order_Type IN ('102','199')
		AND Type_Process = 'GI'
		AND ML.Material_name like 'PL%'
		GROUP by TS.Process_Order,ML.Material_Name,TS.Batch
		HAVING 
			SUM(TS.Quantity_Total) != 0) 	AS PKGI ,
	 (SELECT 
		substr(TS.Process_Order, 9, 4) AS PO,
		strftime('%Y-%m',TS.Posting_Date) AS MonthID,
		ML.Material_Name,
		TS.Batch,
			(CASE
			  WHEN Movement_type = '261' or Movement_type = '262' THEN 'GI'
			  ELSE 'GR'
			END) AS Type_Process,
		OH.Order_Type,
		SUM(TS.Quantity_Total) AS Quantity_Production
		FROM Transaction_Table AS TS , Material_list AS ML , Order_Hearder AS OH
		WHERE TS.Material =  ML.Material_Number
		AND TS.Process_Order = OH.Process_Order
		AND OH.Order_Type = '101' 
		AND Type_Process = 'GR'
		AND ML.Material_name like 'PL%'
		GROUP by TS.Process_Order,ML.Material_Name,TS.Batch
		HAVING 
			SUM(TS.Quantity_Total) != 0 ) AS PDGR ,
	 (SELECT 
		substr(TS.Process_Order, 9, 4) AS PO,
		strftime('%Y-%m',TS.Posting_Date) AS MonthID,
		substr(TS.Batch, 1, 6) AS Lot,
		ML.Material_Name,
			(CASE
			  WHEN Movement_type = '261' or Movement_type = '262' THEN 'GI'
			  ELSE 'GR'
			END) AS Type_Process,
		OH.Order_Type,
		SUM(TS.Quantity_Total) AS Quantity_Production
		FROM Transaction_Table AS TS , Material_list AS ML , Order_Hearder AS OH
		WHERE TS.Material =  ML.Material_Number
		AND TS.Process_Order = OH.Process_Order
		AND OH.Order_Type = '101' 
		AND Type_Process = 'GI'
		AND ML.Material_Name Like '%RM%'
		GROUP by TS.Process_Order,ML.Material_Name,Lot
		HAVING 
			SUM(TS.Quantity_Total) != 0) AS PDGI 
WHERE PKGR.PO = PKGI.PO
AND PKGI.Batch = PDGR.Batch
AND PDGR.PO = PDGI.PO
AND Lot_Packing Like '230621'
AND Type Like 'Food'
GROUP by PKGR.PO,PKGR.Lot,PDGR.PO
ORDER by PKGR.PO,PDGR.PO,PKGI.Batch;

----------------------------------------------------------------------------------------------------------------------------------------------

--Q.5 How many SKUs of bread are there?
SELECT 
	Material_Name
FROM Material_list
WHERE Material_Name Like '%BREAD FlOUR%'

----------------------------------------------------------------------------------------------------------------------------------------------

--Q.6 Monthly sales of each type of flour in 2022
	
SELECT 
 (CASE
		WHEN ML.Material_Name Like '%BREAD%' THEN 'BREAD FLOUR'
		WHEN ML.Material_Name Like '%ALL PURPOSE%' THEN 'ALL PURPOSE FLOUR'
		WHEN ML.Material_Name Like '%NOODLE%' THEN 'NOODLE FLOUR'
		WHEN ML.Material_Name Like '%INSTANT%' THEN 'INSTANT NOODLE FLOUR'
		WHEN ML.Material_Name Like '%BISCUITS%' THEN 'BISCUITS FLOUR' 
		WHEN ML.Material_Name Like '%PIZZA%' THEN 'PIZZA FLOUR'
		WHEN ML.Material_Name Like '%SALAPAO%' THEN 'SALAPAO FLOUR'
		WHEN ML.Material_Name Like '%CAKE%' THEN 'CAKE FLOUR'
		ELSE 'VITAL FLOUR'
	END) AS Type_FLOUR ,
	SUM(SB.Quantity_Total) ,
 (CASE
		WHEN Material_Name Like 'VITAL%' THEN 'VITAL'
		ELSE 'FOOD'
	END) AS Type_Product ,
	strftime('%Y-%m',SB.Posting_Date) AS MonthID
	FROM Material_list AS ML ,Sale_Order_Batch AS SB
	WHERE ML.Material_Number = SB.Material
	AND ML.Material_Name like '%FLOUR%'
	AND ML.Material_Name NOT like '%F3%'
	AND ML.Material_Name NOT like '%MIX%' 
	AND MonthID Like '2022%'
	GROUP by Type_FLOUR , MonthID ;

----------------------------------------------------------------------------------------------------------------------------------------------

--Q.7 What type of flour has sold best between 2021 and 2023

SELECT 
 (CASE
		WHEN ML.Material_Name Like '%BREAD%' THEN 'BREAD FLOUR'
		WHEN ML.Material_Name Like '%ALL PURPOSE%' THEN 'ALL PURPOSE FLOUR'
		WHEN ML.Material_Name Like '%NOODLE%' THEN 'NOODLE FLOUR'
		WHEN ML.Material_Name Like '%INSTANT%' THEN 'INSTANT NOODLE FLOUR'
		WHEN ML.Material_Name Like '%BISCUITS%' THEN 'BISCUITS FLOUR' 
		WHEN ML.Material_Name Like '%PIZZA%' THEN 'PIZZA FLOUR'
		WHEN ML.Material_Name Like '%SALAPAO%' THEN 'SALAPAO FLOUR'
		WHEN ML.Material_Name Like '%CAKE%' THEN 'CAKE FLOUR'
		ELSE 'VITAL FLOUR'
	END) AS Type_FLOUR ,
	SUM(SB.Quantity_Total) ,
 (CASE
		WHEN Material_Name Like 'VITAL%' THEN 'VITAL'
		ELSE 'FOOD'
	END) AS Type_Product ,
	strftime('%Y',SB.Posting_Date) AS MonthID
	FROM Material_list AS ML ,Sale_Order_Batch AS SB
	WHERE ML.Material_Number = SB.Material
	AND ML.Material_Name like '%FLOUR%'
	AND ML.Material_Name NOT like '%F3%'
	AND ML.Material_Name NOT like '%MIX%' 
	AND MonthID Not like '2024'
	GROUP by Type_FLOUR , MonthID ;
