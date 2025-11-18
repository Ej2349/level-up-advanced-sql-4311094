SELECT * FROM model
limit 5; 

SELECT sql
FROM sqlite_schema
WHERE name = 'employee';

SELECT emp.firstName, emp.lastName, emp.title,
mng.firstName AS ManagerFirstName, mng.lastName AS ManagerLastName
FROM employee AS emp
INNER JOIN employee AS mng
ON emp.managerId = mng.employeeId;

SELECT e.firstName, e.lastName, s.salesAmount FROM employee AS e
LEFT JOIN sales AS s
ON e.employeeId = s.employeeId
WHERE salesAmount >= 0;

SELECT e.firstName, e.lastName, e.employeeId, e.title, s.salesAmount FROM employee AS e
LEFT JOIN sales AS s
ON e.employeeId = s.employeeId
WHERE e.title = 'Sales Person'  AND
(s.salesAmount IS NULL OR s.salesAmount = 0);

SELECT s.salesAmount, s.soldDate, c.firstName, c.lastName, c.email FROM customer AS c
INNER JOIN  sales AS s
ON c.customerId = s.customerId
UNION
-- Customers without sales
SELECT NULL AS salesAmount, NULL AS soldDate, c.firstName, c.lastName, c.email 
FROM customer AS c
WHERE c.customerId NOT IN (SELECT customerId FROM sales)
--Sales missing customer info
UNION
SELECT s.salesAmount, s.soldDate, NULL AS firstName, NULL AS lastName, NULL AS email 
FROM sales AS s
WHERE s.customerId NOT IN (SELECT customerId FROM customer);

SELECT cus., sls.*
FROM customer AS cus
FULL OUTER JOIN sales AS sls
ON cus.customerId = sls.customerId;

-- Total number of car sold by each sales person
SELECT emp.employeeId, emp.firstName, emp.lastName
FROM sales AS sales
INNER JOIN employee AS emp
  ON sales.employeeId = emp.employeeId

SELECT emp.employeeId, emp.firstName, emp.lastName, COUNT(sales.salesId) AS TotalCarsSold
FROM sales AS sales
INNER JOIN employee AS emp
  ON sales.employeeId = emp.employeeId
GROUP BY emp.employeeId, emp.firstName, emp.lastName
ORDER BY TotalCarsSold DESC;

-- Find the latest and most expensive sale made by each sales person this year
SELECT emp.employeeId, emp.firstName, emp.lastName, 
  Min(sales.salesAmount) AS LowestSaleAmount, 
  MAX(sales.salesAmount) AS HighestSaleAmount
FROM sales AS sales
INNER JOIN employee AS emp
  ON sales.employeeId = emp.employeeId
WHERE sales.soldDate >= date('2023', 'start of year')
GROUP BY emp.employeeId, emp.firstName, emp.lastName
HAVING count(*) > 5 limit 5;

SELECT emp.employeeId, emp.firstName, emp.lastName, count(sales.salesId) AS TotalSalesTransactions
FROM employee AS emp
INNER JOIN sales AS sales
  ON emp.employeeId = sales.employeeId
WHERE sales.soldDate >= date('2023', 'start of year')
GROUP BY emp.employeeId, emp.firstName, emp.lastName
HAVING TotalSalesTransactions > 5;

-- Report showing the total sales per year.
WITH YearlySales AS (
  SELECT 
    strftime('%Y', soldDate) AS SaleYear,
    ROUND(SUM(salesAmount),2) AS TotalSales
  FROM sales
  GROUP BY SaleYear
)
SELECT * FROM YearlySales
ORDER BY SaleYear ASC;

-- Report that shows the amount of sales per employee each month in 2021.address
WITH MonthlyEmployeeSales AS (
  SELECT 
    emp.employeeId,
    emp.firstName,
    emp.lastName,
    strftime('%Y-%m', sls.soldDate) AS SaleMonth,
    ROUND(SUM(sls.salesAmount),2) AS TotalSales
  FROM sales AS sls
  INNER JOIN employee AS emp
    ON sls.employeeId = emp.employeeId
  WHERE strftime('%Y', sls.soldDate) = '2021'
  GROUP BY emp.employeeId, SaleMonth
)
SELECT employeeId, firstName, lastName, SaleMonth, TotalSales
  CASE WHEN strftime('%m', SaleMonth) = '01' THEN 'January'
       WHEN strftime('%m', SaleMonth) = '02' THEN 'February'
       WHEN strftime('%m', SaleMonth) = '03' THEN 'March'
       WHEN strftime('%m', SaleMonth) = '04' THEN 'April'
       WHEN strftime('%m', SaleMonth) = '05' THEN 'May'
       WHEN strftime('%m', SaleMonth) = '06' THEN 'June'
       WHEN strftime('%m', SaleMonth) = '07' THEN 'July'
       WHEN strftime('%m', SaleMonth) = '08' THEN 'August'
       WHEN strftime('%m', SaleMonth) = '09' THEN 'September'
       WHEN strftime('%m', SaleMonth) = '10' THEN 'October'
       WHEN strftime('%m', SaleMonth) = '11' THEN 'November'
       WHEN strftime('%m', SaleMonth) = '12' THEN 'December'
  END AS MonthName
FROM MonthlyEmployeeSales
ORDER BY employeeId, SaleMonth; 

