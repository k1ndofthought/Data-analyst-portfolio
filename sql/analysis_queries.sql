-- 1. TOTAL SALES
SELECT SUM(Sales) AS total_sales
FROM retail_data;

-- 2. TOTAL PROFIT
SELECT SUM(Profit) AS total_profit
FROM retail_data;

-- 3. PROFIT MARGIN
SELECT 
    SUM(Profit) / SUM(Sales) * 100 AS profit_margin
FROM retail_data;

-- 4. SALES BY CATEGORY
SELECT 
    Category,
    SUM(Sales) AS total_sales
FROM retail_data
GROUP BY Category
ORDER BY total_sales DESC;

-- 5. TOP 10 PRODUCTS BY SALES
SELECT 
    "Product Name",
    SUM(Sales) AS total_sales
FROM retail_data
GROUP BY "Product Name"
ORDER BY total_sales DESC
LIMIT 10;

-- 6. MONTHLY SALES TREND
SELECT 
    DATE_TRUNC('month', "Order Date") AS month,
    SUM(Sales) AS monthly_sales
FROM retail_data
GROUP BY month
ORDER BY month;
