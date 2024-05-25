

SELECT [ProdDate] ,FORMAT(ROUND(((SUM([Standard]) / 440) * 100), 2), '0.##') AS [Standard]
FROM [CLHOURS].[dbo].[CLHOURS]
WHERE [ProdDate] BETWEEN DATEADD(DAY,1,'2024-03-11 00:00:00') AND DATEADD(DAY,1,'2024-04-21 00:00:00')
GROUP BY [ProdDate];

-----------------------------------

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

-----------------------------------

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

-----------------------------------

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

-----------------------------------

DECLARE @EndDate DATETIME = @thisDay
DECLARE @StartDate DATETIME


SET @StartDate = DATEADD(WEEK, -31, @EndDate)

CREATE TABLE #TempResultsDATAProyectallCLHOURS (
DateRangeStart DATETIME,
StandardPercentage VARCHAR(10)
)

WHILE @StartDate <= @EndDate
BEGIN
INSERT INTO #TempResultsDATAProyectallCLHOURS (DateRangeStart, StandardPercentage)
SELECT @StartDate AS DateRangeStart, FORMAT(ROUND(SUM(Standard) / 2040 * 100, 2), '0.##') AS StandardPercentage
FROM CLHOURS
WHERE ProdDate >= DATEADD(DAY, 1, @StartDate) AND ProdDate < DATEADD(DAY, 8, @StartDate) AND Qty > 0

SET @StartDate = DATEADD(WEEK, 1, @StartDate)
END

DELETE FROM #TempResultsDATAProyectallCLHOURS
WHERE DateRangeStart = (SELECT MIN(DateRangeStart) FROM #TempResultsDATAProyectallCLHOURS)

SELECT TOP(30)  * FROM #TempResultsDATAProyectallCLHOURS
WHERE StandardPercentage IS NOT NULL
ORDER BY DateRangeStart DESC

DROP TABLE #TempResultsDATAProyectallCLHOURS
-----------------------------------

SELECT * FROM ( SELECT top 30 Week = DATEADD(DAY, - 1 * DATEPART(dw, ProdDate - 2 ), ProdDate ), Standard = round(SUM(Standard)/100,2) FROM CLHOURS WHERE  ProdDate <= DATEADD(mm, 8, GetDate()) AND ( WorkOrder IS NOT NULL AND PartNo IS NOT NULL AND Qty>0 AND Standard IS NOT NULL  ) GROUP BY DATEADD(DAY, - 1 * DATEPART(dw, ProdDate - 2 ),ProdDate ) ORDER BY WEEK DESC) a ORDER BY a.WEEK ASC

------------------------------------
SELECT 
SUM(CASE WHEN STATUS = 'PENDING' AND ItemNumber NOT LIKE('%NRE%') AND ItemNumber NOT LIKE ('%M%') AND ItemNumber NOT LIKE ('%C%') AND ProductLine <> 'REP' THEN 1 ELSE 0 END) AS PENDING,
SUM(CASE WHEN STATUS LIKE '%PICK%' THEN 1 ELSE 0 END) AS PICK,
SUM(CASE WHEN STATUS LIKE '%STK%' THEN 1 ELSE 0 END) AS STOCK,
SUM(CASE WHEN STATUS LIKE '%PREP-LABEL%' THEN 1 ELSE 0 END) AS PREP_LABEL,
SUM(CASE WHEN STATUS LIKE '%PREP-WIRE%' THEN 1 ELSE 0 END) AS PREP_WIRE,
SUM(CASE WHEN STATUS LIKE '%WIP-READY%' THEN 1 ELSE 0 END) AS WIP_READY,
SUM(CASE WHEN STATUS LIKE '%WIP%' AND STATUS NOT LIKE '%-READY%' THEN 1 ELSE 0 END) AS WIP,
SUM(CASE WHEN STATUS LIKE '%TEST%' AND ItemNumber NOT LIKE('%NRE%') AND ItemNumber NOT LIKE ('%M%') AND ItemNumber NOT LIKE ('%C%') AND ProductLine <> 'REP' THEN 1 ELSE 0 END) AS TEST,
SUM(CASE WHEN STATUS LIKE '%INSP%' AND ItemNumber NOT LIKE('%NRE%') AND ProductLine <> 'REP' THEN 1 ELSE 0 END) AS INSPECTION,
SUM(CASE WHEN STATUS = 'PACKAGING' AND ItemNumber NOT LIKE('%NRE%') AND ItemNumber NOT LIKE ('%M%') AND ItemNumber NOT LIKE ('%C%') AND ProductLine <> 'REP' THEN 1 ELSE 0 END) AS PACKAGING,
SUM(CASE WHEN STATUS LIKE '%SHIP%' AND ItemNumber NOT LIKE('%NRE%') AND ItemNumber NOT LIKE ('%M%') AND ItemNumber NOT LIKE ('%C%') AND ProductLine <> 'REP' THEN 1 ELSE 0 END) AS SHIPPING
FROM 
SO2_420
INNER JOIN 
WorkOrder_420 ON SO2_420.SalesOrderNo = WorkOrder_420.SalesOrderNumber 
AND SO2_420.LineKey = WorkOrder_420.LineIndex 
WHERE 
SO2_420.QuantityOrdered > SO2_420.QuantityShipped;

---------------------------------------------------------

SELECT 
    DATEADD(DAY, -1 * DATEPART(DW, DueDate), DueDate) AS DateRangeStart,
    FORMAT(SUM(QtyDue * Cost), '0') AS StandardPercentage
FROM 
    PO
GROUP BY 
    DATEADD(DAY, -1 * DATEPART(DW, DueDate), DueDate)
ORDER BY 
    DateRangeStart ASC;

--------------------------------------------------------

DECLARE @EndDate DATETIME = '5/13/2024'
DECLARE @StartDate DATETIME

SET @StartDate = DATEADD(WEEK, -29, @EndDate)

;WITH TempResultsCTE AS (
    SELECT
        DateRangeStart = DATEADD(WEEK, Number, @StartDate),
        StandardPercentage = FORMAT(ROUND(SUM(Standard) / 2040.0 * 100, 2), '0.##')
    FROM
        CLHOURS
    CROSS JOIN
        (SELECT TOP 30 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Number FROM sys.objects) AS Numbers
    WHERE
        ProdDate >= DATEADD(DAY, 1, DATEADD(WEEK, Number, @StartDate)) 
        AND ProdDate < DATEADD(DAY, 8, DATEADD(WEEK, Number, @StartDate)) 
        AND Qty > 0
    GROUP BY
        Number
)
SELECT
    *
FROM
    TempResultsCTE
WHERE
    StandardPercentage IS NOT NULL  -- Mostrar solo fechas con datos disponibles
ORDER BY
    DateRangeStart DESC

--------------------------------------------

SELECT 
                               s.CustomerNumber, 
                                s.SurveyYear, 
                                ISNULL(s.Q01, -1) AS Q01, 
                                s.Q01a, 
                                ISNULL(s.Q02, -1) AS Q02, 
                                s.Q02a, 
                                s.Q03, 
                                s.Q03a, 
                                ISNULL(s.Q04, -1) AS Q04, 
                                ISNULL(s.Q05, -1) AS Q05, 
                                s.Q05a, 
                                s.Q06, 
                                s.Q06a, 
                                ISNULL(s.Q07, -1) AS Q07, 
                                ISNULL(s.Q08, -1) AS Q08, 
                                ISNULL(s.Q09, -1) AS Q09, 
                                s.Q09a, 
                                s.Q10, 
                                ISNULL(s.Q11, -1) AS Q11, 
                                ISNULL(s.Q12, -1) AS Q12, 
                                ISNULL(s.Q13, -1) AS Q13, 
                                s.Q14, 
                                s.Q15, 
                                ISNULL(s.Q15a, -1) AS Q15a, 
                                s.Q15b, 
                                s.Q16, 
                                s.Q16a, 
                                s.Q17,
                                FORMAT(
                                    ROUND(
                                        (COALESCE(s.Q01, 0) + COALESCE(s.Q02, 0) + COALESCE(s.Q04, 0) + COALESCE(s.Q05, 0) + COALESCE(s.Q07, 0) + COALESCE(s.Q08, 0) + 
                                         COALESCE(s.Q09, 0) + COALESCE(s.Q10, 0) + COALESCE(s.Q11, 0) + COALESCE(s.Q12, 0) + COALESCE(s.Q13, 0) + COALESCE(s.Q15a, 0)) / 
                                        NULLIF(
                                            CAST(
                                                CASE WHEN s.Q01 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q02 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q04 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q05 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q07 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q08 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q09 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q10 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q11 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q12 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q13 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN s.Q15a IS NOT NULL THEN 1 ELSE 0 END 
                                            AS DECIMAL(10,2)
                                            ), 0
                                        ), 2
                                    ), '#.00') AS AverageScore
                            FROM 
                                survey AS s
                            WHERE
                                COALESCE(Q01,Q02,Q04,Q05,Q07,Q08,Q09,Q10,Q11,Q12,Q13,Q15a) IS NOT NULL
                            ORDER BY 
                                s.SurveyYear DESC;

-- variante

SELECT 
								UserName,
                                CustomerNumber, 
                                SurveyYear, 
                                ISNULL(Q01, -1) AS Q01, 
                                Q01a, 
                                ISNULL(Q02, -1) AS Q02, 
                                Q02a, 
                                Q03, 
                                Q03a, 
                                ISNULL(Q04, -1) AS Q04, 
                                ISNULL(Q05, -1) AS Q05, 
                                Q05a, 
                                Q06, 
                                Q06a, 
                                ISNULL(Q07, -1) AS Q07, 
                                ISNULL(Q08, -1) AS Q08, 
                                ISNULL(Q09, -1) AS Q09, 
                                Q09a, 
                                Q10, 
                                ISNULL(Q11, -1) AS Q11, 
                                ISNULL(Q12, -1) AS Q12, 
                                ISNULL(Q13, -1) AS Q13, 
                                Q14, 
                                Q15, 
                                ISNULL(Q15a, -1) AS Q15a, 
                                Q15b, 
                                Q16, 
                                Q16a, 
                                Q17,
                                FORMAT(
                                    ROUND(
                                        (COALESCE(Q01, 0) + COALESCE(Q02, 0) + COALESCE(Q04, 0) + COALESCE(Q05, 0) + COALESCE(Q07, 0) + COALESCE(Q08, 0) + 
                                         COALESCE(Q09, 0) + COALESCE(Q10, 0) + COALESCE(Q11, 0) + COALESCE(Q12, 0) + COALESCE(Q13, 0) + COALESCE(Q15a, 0)) / 
                                        NULLIF(
                                            CAST(
                                                CASE WHEN Q01 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q02 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q04 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q05 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q07 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q08 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q09 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q10 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q11 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q12 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q13 IS NOT NULL THEN 1 ELSE 0 END +
                                                CASE WHEN Q15a IS NOT NULL THEN 1 ELSE 0 END 
                                            AS DECIMAL(10,2)
                                            ), 0
                                        ), 2
                                    ), '#.00') AS AverageScore
                            FROM 
                                survey
                            ORDER BY 
                                SurveyYear DESC;


