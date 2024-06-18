-- Q.1 The quantity of noodle flour sold in 2023

````sql
SELECT 
	Group_Product,
	strftime('%Y-%m',Posting_Date) AS MonthID,
	SUM(Quantity_Total) AS SUM_Quantity
From Sale_Order_Batch 
WHERE Group_Product = "NOODLE FLOUR"
AND MonthID like '2023%'
Group by MonthID ;
````

🟣**Results:**

| Materialdescription   | MonthID   |   SUM_Quantity  |
|:----------------------|:----------|---------------: |
| NOODLE FLOUR          | 2023-01   |        296910   |
| NOODLE FLOUR          | 2023-02   |        297832.5 |
| NOODLE FLOUR          | 2023-03   |        484042.4 |
| NOODLE FLOUR          | 2023-04   |        388777.5 |
| NOODLE FLOUR          | 2023-05   |        621855   |
| NOODLE FLOUR          | 2023-06   |        479295   |
| NOODLE FLOUR          | 2023-07   |        526815   |
| NOODLE FLOUR          | 2023-08   |        576967.5 |
| NOODLE FLOUR          | 2023-09   |        578317.5 |
| NOODLE FLOUR          | 2023-10   |        541890   |
| NOODLE FLOUR          | 2023-11   |        552645   |
| NOODLE FLOUR          | 2023-12   |        417735   |



--Q.2 Top 10 customers with the most Products purchases in 2022

````sql
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
````

🟣**Results:**
	
| Company_name |   YEAR |   SUM_Quantity    |
|:-------------|-------:|-----------------: |
| DY_COMPANY   |    2022 |       2636586    |
| CH_COMPANY   |    2022 |       1136317.5  |
| IR_COMPANY   |    2022 |       1105820    |
| BI_COMPANY   |    2022 |        879525    |
| BL_COMPANY   |    2022 |        671745    |
| HQ_COMPANY   |    2022 |        618750    |
| BT_COMPANY   |    2022 |        592042.5  |
| IG_COMPANY   |    2022 |        495630    |
| BH_COMPANY   |    2022 |        449100    |
| CA_COMPANY   |    2022 |        431597.52 |


--Q3. Cost price, selling price, and profit in 2023

````sql
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
GROUP by RM.MonthID;
````

🟣**Results:**

| MonthID | Quantity_RM | Quantity_FG | Diff       | RM_Cost      | FG_Cost      | Profit      |
|---------|-------------|-------------|------------|--------------|--------------|-------------|
| 2023-01 | 7657102.25  | 7461143.5   | 195958.75  | 134630890.5  | 137046991.5  | 2416100.97  |
| 2023-02 | 5858748.2   | 5707113.5   | 151634.7   | 103205010.6  | 107361976.3  | 4156965.72  |
| 2023-03 | 8593895.86  | 8357339.97  | 236555.89  | 151529618.9  | 157590265.1  | 6060646.21  |
| 2023-04 | 8572267.08  | 8447285.41  | 124981.67  | 147746928.7  | 159358774.8  | 11611846.1  |
| 2023-05 | 10319308.94 | 10107754    | 211554.94  | 176783192.2  | 190244678.5  | 13461486.27 |
| 2023-06 | 8955396.48  | 8779719.44  | 175677.04  | 151387816.6  | 165297985.5  | 13910168.82 |
| 2023-07 | 10027767.47 | 9834565     | 193202.47  | 162673646.3  | 182758128.2  | 20084481.87 |
| 2023-08 | 11017791.02 | 10878489.5  | 139301.52  | 173873267.2  | 200714362.3  | 26841095.17 |
| 2023-09 | 10675417.4  | 10495629.89 | 179787.51  | 165709899.8  | 191869422.6  | 26159522.84 |
| 2023-10 | 9764250.89  | 9690245.49  | 74005.4    | 151157013.6  | 175932338.6  | 24775325.03 |
| 2023-11 | 10499137.76 | 10449469.52 | 49668.24   | 157283391.7  | 165424949.9  | 8141558.17  |
| 2023-12 | 8477412.02  | 8472340.63  | 5071.39    | 125722161.1  | 132111089.6  | 6388928.51  |



--Q.4 Traceability inspection of product lot 230621 for food products

````sql
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
````

🟣**Results:**

| PO_Packing | MonthID | Lot_Packing | Product_NAME         | Type | Quantity_Product | PO_PD | WIP_NAME | Batch_WIP    | Quantity_WIP | RM_Name | LOT_RM | Quantity_RM  |
|------------|---------|-------------|--------------------  |------|------------------|-------|----------|--------------|--------------|---------|--------|--------------|
| 3477       | 2023-06 | 230621      | NOODLE FLOUR 10      | FOOD | 6907.5           | 3550  | PL-11    | 230612002A   | 1791         | RM-18   | 230106 | 12659        |
| 3477       | 2023-06 | 230621      | NOODLE FLOUR 10      | FOOD | 6907.5           | 3557  | PL-22    | 230614001A   | 713.5        | RM-6    | 230222 | 78391        |
| 3477       | 2023-06 | 230621      | NOODLE FLOUR 10      | FOOD | 6907.5           | 3594  | PL-25    | 230620002A   | 4679.5       | RM-8    | 230316 | 19575        |
| 3571       | 2023-06 | 230621      | BISCUITS FLOUR 6     | FOOD | 23062.5          | 3550  | PL-11    | 230612002A   | 21731.5      | RM-18   | 230106 | 12659        |
| 3571       | 2023-06 | 230621      | BISCUITS FLOUR 6     | FOOD | 23062.5          | 3556  | PL-1     | 230613003A   | 199          | RM-16   | 220928 | 40612        |
| 3606       | 2023-06 | 230621      | NOODLE FLOUR 6       | FOOD | 11250            | 3569  | PL-25    | 230615001A   | 11490.5      | RM-8    | 230313 | 785          |
| 3607       | 2023-06 | 230621      | NOODLE FLOUR 9       | FOOD | 11587.5          | 3569  | PL-25    | 230615001A   | 9181         | RM-8    | 230313 | 785          |
| 3607       | 2023-06 | 230621      | NOODLE FLOUR 9       | FOOD | 11587.5          | 3594  | PL-25    | 230620002A   | 2655.5       | RM-8    | 230316 | 19575        |
| 3610       | 2023-06 | 230621      | ALL PURPOSE FLOUR 31 | FOOD | 29340            | 3542  | PL-18    | 230610001A   | 16439        | RM-22   | 230609 | 56636        |
| 3610       | 2023-06 | 230621      | ALL PURPOSE FLOUR 31 | FOOD | 29340            | 3557  | PL-22    | 230614001A   | 3447         | RM-6    | 230222 | 78391        |
| 3610       | 2023-06 | 230621      | ALL PURPOSE FLOUR 31 | FOOD | 29340            | 3592  | PL-22    | 230619001A   | 9973.5       | RM-6    | 230222 | 88608        |
| 3614       | 2023-06 | 230621      | BISCUITS FLOUR 12    | FOOD | 4700             | 3471  | PL-24    | 230530003A   | 305          | RM-7    | 221028 | 78521        |
| 3614       | 2023-06 | 230621      | BISCUITS FLOUR 12    | FOOD | 4700             | 3550  | PL-11    | 230612002A   | 1734.5       | RM-18   | 230106 | 12659        |
| 3614       | 2023-06 | 230621      | BISCUITS FLOUR 12    | FOOD | 4700             | 3583  | PL-11    | 230617002A   | 1196.5       | RM-18   | 230112 | 38895.12     |
| 3614       | 2023-06 | 230621      | BISCUITS FLOUR 12    | FOOD | 4700             | 3592  | PL-22    | 230619001A   | 739          | RM-6    | 230222 | 88608        |
| 3614       | 2023-06 | 230621      | BISCUITS FLOUR 12    | FOOD | 4700             | 3595  | PL-13    | 230620003A   | 293.5        | RM-8    | 230529 | 80540        |
| 3614       | 2023-06 | 230621      | BISCUITS FLOUR 12    | FOOD | 4700             | 3602  | PL-24    | 230621001A   | 658.5        | RM-7    | 221028 | 89309        |


--Q.5 How many SKUs of bread are there?

````sql	
SELECT 
	Material_Name
FROM Material_list
WHERE Material_Name Like '%BREAD FlOUR%'
````

🟣**Results:**
	
| Material_Name  |
|----------------|
| BREAD FLOUR 1  |
| BREAD FLOUR 2  |
| BREAD FLOUR 3  |
| BREAD FLOUR 4  |
| BREAD FLOUR 5  |
| BREAD FLOUR 6  |
| BREAD FLOUR 7  |
| BREAD FLOUR 8  |
| BREAD FLOUR 9  |
| BREAD FLOUR 10 |
| BREAD FLOUR 11 |
| BREAD FLOUR 12 |
| BREAD FLOUR 13 |
| BREAD FLOUR 14 |
| BREAD FLOUR 15 |
| BREAD FLOUR 16 |
| BREAD FLOUR 17 |
| BREAD FLOUR 18 |
| BREAD FLOUR 19 |
| BREAD FLOUR 20 |
| BREAD FLOUR 21 |
| BREAD FLOUR 22 |


--Q.6 Monthly sales of each type of flour in 2022

````sql
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
````


🟣**Results:**


| Type_FLOUR       | SUM(SB.Quantity_Total) | Type_Product | MonthID  |
|------------------|------------------------|--------------|----------|
| ALL PURPOSE FLOUR | 237700                | FOOD         | 2022-01  |
| ALL PURPOSE FLOUR | 178707.5              | FOOD         | 2022-02  |
| ALL PURPOSE FLOUR | 293785                | FOOD         | 2022-03  |
| ALL PURPOSE FLOUR | 114362.5              | FOOD         | 2022-04  |
| ALL PURPOSE FLOUR | 206930                | FOOD         | 2022-05  |
| ALL PURPOSE FLOUR | 326052.5              | FOOD         | 2022-06  |
| ALL PURPOSE FLOUR | 321457.5              | FOOD         | 2022-07  |
| ALL PURPOSE FLOUR | 390857.5              | FOOD         | 2022-08  |
| ALL PURPOSE FLOUR | 419512.5              | FOOD         | 2022-09  |
| ALL PURPOSE FLOUR | 544602.5              | FOOD         | 2022-10  |
| ALL PURPOSE FLOUR | 565427.5              | FOOD         | 2022-11  |
| ALL PURPOSE FLOUR | 325702.5              | FOOD         | 2022-12  |
| BISCUITS FLOUR    | 39847.5               | FOOD         | 2022-01  |
| BISCUITS FLOUR    | 96437.5               | FOOD         | 2022-02  |
| BISCUITS FLOUR    | 203978.5              | FOOD         | 2022-03  |
| BISCUITS FLOUR    | 170222.5              | FOOD         | 2022-04  |
| BISCUITS FLOUR    | 365810                | FOOD         | 2022-05  |
| BISCUITS FLOUR    | 451045                | FOOD         | 2022-06  |
| BISCUITS FLOUR    | 776365                | FOOD         | 2022-07  |
| BISCUITS FLOUR    | 803297.5              | FOOD         | 2022-08  |
| BISCUITS FLOUR    | 948860                | FOOD         | 2022-09  |
| BISCUITS FLOUR    | 734767.5              | FOOD         | 2022-10  |
| BISCUITS FLOUR    | 785320                | FOOD         | 2022-11  |
| BISCUITS FLOUR    | 545992.5              | FOOD         | 2022-12  |
| BREAD FLOUR       | 224930.01             | FOOD         | 2022-01  |
| BREAD FLOUR       | 359352.5              | FOOD         | 2022-02  |
| BREAD FLOUR       | 240807.5              | FOOD         | 2022-03  |
| BREAD FLOUR       | 112792.51             | FOOD         | 2022-04  |
| BREAD FLOUR       | 374667.5              | FOOD         | 2022-05  |
| BREAD FLOUR       | 460770                | FOOD         | 2022-06  |
| BREAD FLOUR       | 315285                | FOOD         | 2022-07  |
| BREAD FLOUR       | 314597.5              | FOOD         | 2022-08  |
| BREAD FLOUR       | 385497.5              | FOOD         | 2022-09  |
| BREAD FLOUR       | 380160                | FOOD         | 2022-10  |
| BREAD FLOUR       | 507485                | FOOD         | 2022-11  |
| BREAD FLOUR       | 265572.5              | FOOD         | 2022-12  |
| NOODLE FLOUR      | 617400                | FOOD         | 2022-01  |
| NOODLE FLOUR      | 490275                | FOOD         | 2022-02  |
| NOODLE FLOUR      | 597060                | FOOD         | 2022-03  |
| NOODLE FLOUR      | 214560                | FOOD         | 2022-04  |
| NOODLE FLOUR      | 275400                | FOOD         | 2022-05  |
| NOODLE FLOUR      | 382005                | FOOD         | 2022-06  |
| NOODLE FLOUR      | 371137.5              | FOOD         | 2022-07  |
| NOODLE FLOUR      | 290992.5              | FOOD         | 2022-08  |
| NOODLE FLOUR      | 420075                | FOOD         | 2022-09  |
| NOODLE FLOUR      | 481500                | FOOD         | 2022-10  |
| NOODLE FLOUR      | 580717.5              | FOOD         | 2022-11  |
| NOODLE FLOUR      | 411120                | FOOD         | 2022-12  |
| PIZZA FLOUR       | 29925                 | FOOD         | 2022-01  |
| PIZZA FLOUR       | 20475                 | FOOD         | 2022-02  |
| PIZZA FLOUR       | 15750                 | FOOD         | 2022-03  |
| PIZZA FLOUR       | 17325                 | FOOD         | 2022-04  |
| PIZZA FLOUR       | 19575                 | FOOD         | 2022-05  |
| PIZZA FLOUR       | 23625                 | FOOD         | 2022-06  |
| PIZZA FLOUR       | 34650                 | FOOD         | 2022-07  |
| PIZZA FLOUR       | 34875                 | FOOD         | 2022-08  |
| PIZZA FLOUR       | 29925                 | FOOD         | 2022-09  |
| PIZZA FLOUR       | 23625                 | FOOD         | 2022-10  |
| PIZZA FLOUR       | 28800                 | FOOD         | 2022-11  |
| PIZZA FLOUR       | 21600                 | FOOD         | 2022-12  |
| VITAL FLOUR       | 30000                 | VITAL        | 2022-01  |
| VITAL FLOUR       | 3000                  | VITAL        | 2022-02  |
| VITAL FLOUR       | 1500                  | VITAL        | 2022-04  |
| VITAL FLOUR       | 192000                | VITAL        | 2022-05  |
| VITAL FLOUR       | 91000                 | VITAL        | 2022-10  |
| VITAL FLOUR       | 155675                | VITAL        | 2022-11  |
| VITAL FLOUR       | 99000                 | VITAL        | 2022-12  |


	
--Q.7 What type of flour has sold best between 2021 and 2023

````sql
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
````


🟣**Results:**

| Type_FLOUR       | SUM(SB.Quantity_Total) | Type_Product | MonthID |
|------------------|------------------------|--------------|---------|
| ALL PURPOSE FLOUR| 1928637.43             | FOOD         | 2021    |
| ALL PURPOSE FLOUR| 3925097.5              | FOOD         | 2022    |
| ALL PURPOSE FLOUR| 3695120.14             | FOOD         | 2023    |
| BISCUITS FLOUR   | 580895                 | FOOD         | 2021    |
| BISCUITS FLOUR   | 5921943.5              | FOOD         | 2022    |
| BISCUITS FLOUR   | 5318690                | FOOD         | 2023    |
| BREAD FLOUR      | 2133713.4              | FOOD         | 2021    |
| BREAD FLOUR      | 3941917.52             | FOOD         | 2022    |
| BREAD FLOUR      | 5043755                | FOOD         | 2023    |
| NOODLE FLOUR     | 3143073.49             | FOOD         | 2021    |
| NOODLE FLOUR     | 5132242.5              | FOOD         | 2022    |
| NOODLE FLOUR     | 5763082.4              | FOOD         | 2023    |
| PIZZA FLOUR      | 299452.5               | FOOD         | 2021    |
| PIZZA FLOUR      | 300150                 | FOOD         | 2022    |
| PIZZA FLOUR      | 305595                 | FOOD         | 2023    |
| VITAL FLOUR      | 1752668.46             | VITAL        | 2021    |
| VITAL FLOUR      | 572175                 | VITAL        | 2022    |
| VITAL FLOUR      | 3250000                | VITAL        | 2023    |

