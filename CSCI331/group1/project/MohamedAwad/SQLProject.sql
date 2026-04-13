USE Northwinds2024Student
GO

-- SQLNOIR Story Mysteries

/*
-----------------------------------------------------------------
Mystery #1: The Big Spender
-----------------------------------------------------------------
GOAL: Find and extract the  customer who spent the most amount of money
Tables involved: Sales.Customer, Sales.Order, Sales.OrderDetail
*/

-- Section 1
-- Examining the data in the first 10 rows
SELECT TOP 10 * FROM Sales.Customer
SELECT TOP 10 * FROM Sales.[Order]
SELECT TOP 10 * FROM Sales.OrderDetail

-- Section 2: Finding large individual purchases
SELECT 
    OrderId,
    SUM(UnitPrice * Quantity) AS TotalPurchases
FROM Sales.OrderDetail
GROUP BY OrderId
ORDER BY TotalPurchases DESC

-- Section 3: Finding the the total spending amount per customer

SELECT c.CustomerId, c.CustomerContactName, SUM(od.Quantity * od.UnitPrice) AS TotalSpending
FROM Sales.Customer AS c 
INNER JOIN Sales.[Order] AS o 
ON c.CustomerId = o.CustomerId 
INNER JOIN Sales.OrderDetail AS od 
ON od.OrderId = o.OrderId
GROUP BY c.CustomerId, c.CustomerContactName
ORDER BY TotalSpending DESC

-- Section 4: Final Result
;WITH TotalSpendingPerCustomer AS (
    SELECT
        c.CustomerId, 
        c.CustomerContactName, 
        SUM(od.Quantity * od.UnitPrice) AS TotalSpending
    FROM Sales.Customer AS c 
    INNER JOIN Sales.[Order] AS o 
    ON c.CustomerId = o.CustomerId 
    INNER JOIN Sales.OrderDetail AS od 
    ON od.OrderId = o.OrderId
    GROUP BY c.CustomerId, c.CustomerContactName
)

SELECT TOP(1) *
FROM TotalSpendingPerCustomer
ORDER BY TotalSpending DESC

/*
-----------------------------------------------------------------
Mystery #2: Customer Orders
-----------------------------------------------------------------
GOAL: Find which customer placed the most amount of orders
Tables involved: Sales.Customer, Sales.Order
*/

--Section 1: Examining the dataset
SELECT TOP 5 * FROM Sales.Customer
SELECT TOP 5 * FROM Sales.[Order]


-- Section 2: Finding the total orders
SELECT 
    COUNT(OrderId) AS TotalOrders
FROM Sales.[Order] 
ORDER BY TotalOrders DESC

-- Section 3: Getting the total number of orders per customer
SELECT 
    c.CustomerId,
    c.CustomerContactName,
    COUNT(o.OrderId) AS TotalOrders
FROM Sales.Customer as c 
INNER JOIN Sales.[Order] AS o 
ON c.CustomerId = o.CustomerId 
GROUP BY c.CustomerId, c.CustomerContactName
ORDER BY TotalOrders DESC

-- Section 4: Final Result-- Wrapping it with a CTE
;WITH TotalOrdersPerCustomer AS (
SELECT 
    c.CustomerId,
    c.CustomerContactName,
    COUNT(o.OrderId) AS TotalOrders
FROM Sales.Customer as c 
INNER JOIN Sales.[Order] AS o 
ON c.CustomerId = o.CustomerId 
GROUP BY c.CustomerId, c.CustomerContactName

)

SELECT TOP(1)* FROM TotalOrdersPerCustomer
ORDER BY TotalOrders DESC
-- Customer ID 71 had 31 orders which are the most amount 


/*
-----------------------------------------------------------------
Mystery #3: Popular Products
-----------------------------------------------------------------
GOAL: Identify which product is most popular
Tables involved: Production.Product, Sales.OrderDetail
*/

-- Section 1: Examining the datasets
SELECT TOP(5) * FROM Production.Product
SELECT TOP(5) * FROM Sales.OrderDetail

-- Section 2: Getting the total Products
SELECT 
    SUM(Quantity) AS TotalProducts
FROM Sales.OrderDetail
GROUP BY ProductId


-- Section 3: Getting all the total products per product

SELECT 
    p.ProductId,
    p.ProductName,
    SUM(od.Quantity) AS totalProducts
FROM Production.Product AS p 
INNER JOIN Sales.OrderDetail AS od 
ON p.ProductId = od.ProductId
GROUP BY p.ProductId, p.Productname 

-- Section 4: Final Result -- Wrapping it all with CTE
;WITH TotalProductsPerProduct AS (
    SELECT 
    p.ProductId,
    p.ProductName,
    SUM(od.Quantity) AS totalProducts
FROM Production.Product AS p 
INNER JOIN Sales.OrderDetail AS od 
ON p.ProductId = od.ProductId
GROUP BY p.ProductId, p.Productname 
)

SELECT TOP(1) * FROM TotalProductsPerProduct
ORDER BY totalProducts DESC

/*
-----------------------------------------------------------------
Mystery #4: The Top Revenue
-----------------------------------------------------------------
GOAL: Identify products that generated the most amount of money
Tables involved: Production.Product, Sales.OrderDetail
*/

-- Section 1: Survey the datasets
SELECT TOP(5) * FROM Production.Product
SELECT TOP(5) * FROM Sales.OrderDetail

-- Section 2: Getting the list of products
SELECT 
    ProductId
    ProductName
FROM Production.Product

-- Section 3: Getting the total revenue per product
SELECT 
    p.ProductId,
    p.ProductName,
    SUM(od.UnitPrice * od.Quantity) AS Revenue
FROM Production.Product AS p 
INNER JOIN Sales.OrderDetail AS od 
ON p.ProductId = od.ProductId
GROUP BY p.ProductId, p.ProductName

-- Section 4: Final Result

;WITH TotalRevenuePerProduct AS (
SELECT 
    p.ProductId,
    p.ProductName,
    SUM(od.UnitPrice * od.Quantity) AS Revenue
FROM Production.Product AS p 
INNER JOIN Sales.OrderDetail AS od 
ON p.ProductId = od.ProductId
GROUP BY p.ProductId, p.ProductName
)

SELECT TOP(2)* FROM TotalRevenuePerProduct
ORDER BY Revenue DESC
-- Product QDOMO had the highest revenue out of all the products

/*
-----------------------------------------------------------------
Mystery #5: Employee orders
-----------------------------------------------------------------
GOAL: Identify which employee had the most amount of orders
Tables involved: HumanResources.Employee, Sales.Order
*/

-- Section 1: Examining the tables
SELECT TOP(5) * FROM HumanResources.Employee
SELECT TOP(5) * FROM Sales.[Order]

-- Section 2: Getting the most orders
SELECT 
    COUNT(OrderId)
FROM Sales.[Order]

-- Section 3: Getting the orders per employee
SELECT
    e.EmployeeId,
    CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS Fullname, 
    COUNT(o.OrderId) AS TotalOrders
FROM HumanResources.Employee AS e 
INNER JOIN Sales.[Order] AS o 
ON o.EmployeeId = e.EmployeeId 
GROUP BY e.EmployeeId, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName)

-- Section 4: Final result

;WITH TotalOrdersPerEmployee AS (
SELECT
    e.EmployeeId,
    CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS Fullname, 
    COUNT(o.OrderId) AS TotalOrders
FROM HumanResources.Employee AS e 
INNER JOIN Sales.[Order] AS o 
ON o.EmployeeId = e.EmployeeId 
GROUP BY e.EmployeeId, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName)
)

SELECT TOP(1) * FROM TotalOrdersPerEmployee
ORDER BY TotalOrders DESC
-- The Employee Yael Peled had the most orders

/*
-----------------------------------------------------------------
Mystery #6: The Inactive Customers
-----------------------------------------------------------------
GOAL: Identify which customers who have barely placed any orders
Tables involved: Sales.Customer, Sales.Order
*/

-- Section 1
SELECT TOP(5) * FROM Sales.Customer
SELECT TOP(5) * FROM Sales.[Order]

-- Section 2: Getting all the customers
SELECT CustomerContactName FROM Sales.Customer

-- Section 3: For each Customer get their orders
SELECT 
    c.CustomerId,
    c.CustomerContactName,
    COUNT(o.OrderId) AS TotalOrders 
FROM Sales.Customer AS c 
INNER JOIN Sales.[Order] AS o 
ON o.CustomerId = c.CustomerId
GROUP BY c.CustomerId, c.CustomerContactName

-- Section 4: Wrapping it up with a CTE 
; WITH LeastNumOrders AS (
SELECT 
    c.CustomerId,
    c.CustomerContactName,
    COUNT(o.OrderId) AS TotalOrders 
FROM Sales.Customer AS c 
INNER JOIN Sales.[Order] AS o 
ON o.CustomerId = c.CustomerId
GROUP BY c.CustomerId, c.CustomerContactName
)
SELECT TOP(2)* FROM LeastNumOrders
ORDER BY TotalOrders
-- Customer Id 13 had the least amount of orders 



/*
-----------------------------------------------------------------
Mystery #7: Monthly Order Trends
-----------------------------------------------------------------
GOAL: Identify the month that have the most trends in terms of orders
Tables involved: Sales.Order
*/

-- Section 1: surveying the table
SELECT TOP(4) * FROM Sales.[Order]

-- Section 2: Getting all orders per month
SELECT 
    DATENAME(MONTH, OrderDate) AS Month,
    COUNT(OrderId) AS totalOrdersByMonth
FROM Sales.[Order]
GROUP BY DATENAME(MONTH, OrderDate)

-- Section 3: Wrapping the final result with a CTE 
;WITH TotalOrdersMonthly AS (
SELECT 
    DATENAME(MONTH, OrderDate) AS Month,
    COUNT(OrderId) AS totalOrdersByMonth
FROM Sales.[Order]
GROUP BY DATENAME(MONTH, OrderDate)
)

SELECT TOP(1)*FROM TotalOrdersMonthly
ORDER BY totalOrdersByMonth DESC
-- April had the most orders on a trend


/*
-----------------------------------------------------------------
Mystery #8: Most Recent Order By Employee
-----------------------------------------------------------------
GOAL: Identify the most recent orders by employee
Tables involved: Sales.Order, HumanResources.Employee
*/

-- Section 1: Survey the table
SELECT TOP(4) * FROM Sales.[Order]
SELECT TOP(4) * FROM HumanResources.Employee

-- Section 2: Getting the recent order
SELECT MAX(OrderDate) AS RecentOrder FROM Sales.[Order]

-- Section 3: For each employee, get their recent order
SELECT 
    e.EmployeeId,
    CONCAT(e.EmployeeFirstname, ' ', e.EmployeeLastName) AS FullName,
    MAX(o.OrderDate) AS RecentOrder
FROM HumanResources.Employee AS e 
INNER JOIN Sales.[Order] aS o 
ON e.EmployeeId = o.EmployeeId
GROUP BY e.EmployeeId, CONCAT(e.EmployeeFirstname, ' ', e.EmployeeLastName)

-- Section 4: Final result as CTE
;WITH RecentOrdersByEmployee AS (
SELECT 
    e.EmployeeId,
    CONCAT(e.EmployeeFirstname, ' ', e.EmployeeLastName) AS FullName,
    MAX(o.OrderDate) AS RecentOrder
FROM HumanResources.Employee AS e 
INNER JOIN Sales.[Order] aS o 
ON e.EmployeeId = o.EmployeeId
GROUP BY e.EmployeeId, CONCAT(e.EmployeeFirstname, ' ', e.EmployeeLastName)
)

SELECT * FROM RecentOrdersByEmployee


/*
-----------------------------------------------------------------
Mystery #9: Below the Unit Average
-----------------------------------------------------------------
GOAL: Identify the products whose unit price is less than the average of all unit prices
Tables involved: Production.Product
*/

-- Section 1: Looking at the table
SELECT TOP(4) * FROM Production.Product

-- Section 2: Getting the average of the Unit prices
SELECT AVG(UnitPrice) AS AvgUnitPrice FROM Production.Product

-- Section 3: Taking section 2 to find products
SELECT 
    ProductName,
    UnitPrice
FROM Production.Product
WHERE UnitPrice < (
    SELECT 
    AVG(UnitPrice) AS AvgUnitPrice 
    FROM Production.Product
)

-- Section 4: Final Result with CTE
;WITH AvgUnitPrices As (
    SELECT 
    ProductName,
    UnitPrice
FROM Production.Product
WHERE UnitPrice < (
    SELECT 
    AVG(UnitPrice) AS AvgUnitPrice 
    FROM Production.Product
)
)

SELECT * FROM AvgUnitPrices


/*
-----------------------------------------------------------------
Mystery #10: Suspicious Low Orders
-----------------------------------------------------------------
GOAL: Which orders have small quantites or spending
Tables involved: Sales.OrderDetail
*/

-- Section 1: Survey the table
SELECT TOP(4) * FROM Sales.OrderDetail

--Section 2: Getting the quanties
SELECT SUM(Quantity * UnitPrice) AS TotalSpending
FROM Sales.OrderDetail

-- Section 3: Getting the total spending for each order
SELECT TOP(3)
    OrderId,
    SUM(Quantity * UnitPrice) AS TotalSpending
FROM Sales.OrderDetail
GROUP BY OrderId
ORDER BY TotalSpending

