

SELECT [ProdDate] ,FORMAT(ROUND(((SUM([Standard]) / 440) * 100), 2), '0.##') AS [Standard]
FROM [CLHOURS].[dbo].[CLHOURS]
WHERE [ProdDate] BETWEEN DATEADD(DAY,1,'2024-03-11 00:00:00') AND DATEADD(DAY,1,'2024-04-21 00:00:00')
GROUP BY [ProdDate];





SELECT 
    DATEPART(week, [ProdDate]) AS semana,
    FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS [Standard]
FROM 
    [CLHOURS].[dbo].[CLHOURS]
WHERE 
    [ProdDate] >= '2023-09-25 00:00:00' AND [ProdDate] <= '2024-04-21 00:00:00' 
    AND DATEPART(weekday, [ProdDate]) >= 2 AND DATEPART(weekday, [ProdDate]) <= 8 
GROUP BY 
    DATEPART(week, [ProdDate])
ORDER BY 
    semana;


	
SELECT FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS [Standard]
FROM 
    [CLHOURS].[dbo].[CLHOURS]
	WHERE [ProdDate] > '2023-09-24 00:00:00' AND [ProdDate] < '2023-10-02 00:00:00'

SELECT FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS [Standard]
FROM 
    [CLHOURS].[dbo].[CLHOURS]
	WHERE [ProdDate] > '2023-10-01 00:00:00' AND [ProdDate] < '2023-10-9 00:00:00'


SELECT FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS [Standard]
FROM 
    [CLHOURS].[dbo].[CLHOURS]
	WHERE [ProdDate] > '2023-10-08 00:00:00' AND [ProdDate] < '2023-10-16 00:00:00'


SELECT FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS [Standard]
FROM 
    [CLHOURS].[dbo].[CLHOURS]
	WHERE [ProdDate] > '2023-10-15 00:00:00' AND [ProdDate] < '2023-10-23 00:00:00'

	




DECLARE @StartDate DATETIME = '2023-09-24 00:00:00';
DECLARE @EndDate DATETIME = '2024-04-16 00:00:00';

SELECT 
    DATEPART(week, [ProdDate]) AS semana,
    FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS [Standard]
FROM 
    [CLHOURS].[dbo].[CLHOURS]
WHERE 
    [ProdDate] > @StartDate AND [ProdDate] < @EndDate
GROUP BY 
    DATEPART(week, [ProdDate])
ORDER BY 
    MIN([ProdDate]);



DECLARE @StartDate DATETIME = '2023-10-02 00:00:00'
                                    DECLARE @EndDate DATETIME = '2024-04-23 00:00:00'

                                    CREATE TABLE #TempResultsDATAProyectallCLHOURS (
                                        DateRangeStart DATETIME,
                                        StandardPercentage VARCHAR(10)
                                    )

                                    WHILE @StartDate <= @EndDate
                                    BEGIN
                                        INSERT INTO #TempResultsDATAProyectallCLHOURS (DateRangeStart, StandardPercentage)
                                        SELECT @StartDate AS DateRangeStart, FORMAT(ROUND(SUM([Standard]) / 2040 * 100, 2), '0.##') AS StandardPercentage
                                        FROM CLHOURS
                                        WHERE [ProdDate] >= DATEADD(DAY,1,@StartDate) AND [ProdDate] < DATEADD(DAY, 8, @StartDate) AND Qty > 0

                                        SET @StartDate = DATEADD(DAY, 7, @StartDate)
                                    END

                                    SELECT * FROM #TempResultsDATAProyectallCLHOURS

                                    DROP TABLE #TempResults
 -----------------------------------

SELECT * FROM ( SELECT top 30 Week = DATEADD(DAY, - 1 * DATEPART(dw, ProdDate - 2 ), ProdDate ), Standard = round(SUM(Standard)/100,2) FROM CLHOURS WHERE  ProdDate <= DATEADD(mm, 8, GetDate()) AND ( WorkOrder IS NOT NULL AND PartNo IS NOT NULL AND Qty>0 AND Standard IS NOT NULL  ) GROUP BY DATEADD(DAY, - 1 * DATEPART(dw, ProdDate - 2 ),ProdDate ) ORDER BY WEEK DESC) a ORDER BY a.WEEK ASC

------------------------------------
SELECT 
    SUM(CASE WHEN STATUS = 'PENDING' THEN 1 ELSE 0 END) AS PENDING,
    SUM(CASE WHEN STATUS LIKE '%PICK%' THEN 1 ELSE 0 END) AS PICK,
    SUM(CASE WHEN STATUS LIKE '%STK%' THEN 1 ELSE 0 END) AS STOCK,
    SUM(CASE WHEN STATUS LIKE '%PREP-LABEL%' THEN 1 ELSE 0 END) AS PREP_LABEL,
    SUM(CASE WHEN STATUS LIKE '%PREP-WIRE%' THEN 1 ELSE 0 END) AS PREP_WIRE,
    SUM(CASE WHEN STATUS LIKE '%WIP-READY%' THEN 1 ELSE 0 END) AS WIP_READY,
    SUM(CASE WHEN STATUS LIKE '%WIP%' AND STATUS NOT LIKE '%-READY%' THEN 1 ELSE 0 END) AS WIP,
    SUM(CASE WHEN STATUS LIKE '%TEST%' THEN 1 ELSE 0 END) AS TEST,
    SUM(CASE WHEN STATUS LIKE '%INSP%' THEN 1 ELSE 0 END) AS INSPECTION,
    SUM(CASE WHEN STATUS = 'PACKAGING' THEN 1 ELSE 0 END) AS PACKAGING,
    SUM(CASE WHEN STATUS = 'SHIPPING' THEN 1 ELSE 0 END) AS SHIPPING
FROM 
    SO2_420
INNER JOIN 
    WorkOrder_420 ON SO2_420.SalesOrderNo = WorkOrder_420.SalesOrderNumber 
        AND SO2_420.LineKey = WorkOrder_420.LineIndex
WHERE 
    SO2_420.QuantityOrdered > SO2_420.QuantityShipped;