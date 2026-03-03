/* ===============================================
   Grind Sales � Unified Dataset Construction
   Combining Orders from 2023, 2024, 2025
   =============================================== */

WITH all_orders AS (

    SELECT OrderID, CustomerID, ProductID, OrderDate,
           Quantity, Revenue, COGS, SourceFile
    FROM grind_sales.dbo.Orders_2023

    UNION ALL

    SELECT OrderID, CustomerID, ProductID, OrderDate,
           Quantity, Revenue, COGS, SourceFile
    FROM grind_sales.dbo.Orders_2024

    UNION ALL

    SELECT OrderID, CustomerID, ProductID, OrderDate,
           Quantity, Revenue, COGS, SourceFile
    FROM grind_sales.dbo.Orders_2025
)

SELECT 
    a.OrderID,
    a.CustomerID,
    c.Region,
    a.ProductID,
    a.OrderDate,
    c.CustomerJoinDate,
    a.Quantity,
    
    -- Handle missing revenue
    CASE 
        WHEN a.Revenue IS NULL 
            THEN p.Price * a.Quantity 
        ELSE a.Revenue 
    END AS CleanedRevenue,

    -- Correct Profit Calculation
    CASE 
        WHEN a.Revenue IS NULL 
            THEN (p.Price * a.Quantity) - a.COGS
        ELSE a.Revenue - a.COGS
    END AS Profit,

    a.COGS,
    p.ProductName,
    p.ProductCategory,
    p.Price,
    p.Base_Cost

FROM all_orders a

LEFT JOIN Customers c
    ON a.CustomerID = c.CustomerID

LEFT JOIN Products p
    ON a.ProductID = p.ProductID

WHERE a.CustomerID IS NOT NULL;