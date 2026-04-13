USE Northwinds2024Student;
GO 
---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 04 - Subqueries
-- Exercises
---------------------------------------------------------------------

-- Exercise 1
-- Write a query that returns all orders placed on the last day of activity that can be found in the Orders table
-- Tables involved: Sales.Order
SELECT OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order] o
WHERE OrderDate = (SELECT MAX(o.OrderDate) FROM Sales.[Order] o)

-- Exercise 2
-- Write a query that returns all orders placed by the customers who placed the highest number of orders
-- Tables involved: Sales.Order 
/*
SELECT TOP(1) with TIES O.CustomerId
FROM Sales.[Order] AS O
GROUP BY O.CustomerId
ORDER BY COUNT(*) DESC
*/
SELECT CustomerId, OrderId, OrderDate, EmployeeId 
FROM Sales.[Order]
WHERE CustomerId IN (
    SELECT TOP (1) WITH TIES O.CustomerId
    FROM Sales.[Order] O
    GROUP BY CustomerId
    ORDER BY COUNT(*) DESC)

-- Exercise 3
-- Write a query that returns employees who did not place orders on or after May 1, 2022
-- Tables involved: HR.Employee and Sales.Order
SELECT e.EmployeeId, e.EmployeeFirstName as firstname, e.EmployeeLastName as lastname
FROM HumanResources.Employee AS e
WHERE e.EmployeeId NOT IN (
    Select o.EmployeeId
    FROM Sales.[Order] AS o 
    WHERE o.OrderDate >= '20220501'
)
ORDER BY e.EmployeeId

-- Exercise 4
-- Write write a query that returns countries where there are customers but not employees
-- Tables involved: Sales.Customer and HR.Employee 
SELECT DISTINCT c.CustomerCountry AS country 
FROM Sales.Customer AS c 
WHERE c.CustomerCountry NOT IN (
    SELECT e.EmployeeCountry 
    FROM HumanResources.Employee AS e 
)

-- Exercise 5 
-- Write a query that returns for each customer all orders placed on the customer's last day of activity
-- Tables involved: Sales.Order 
SELECT o1.CustomerId, o1.OrderId, o1.OrderDate, o1.EmployeeId 
FROM Sales.[Order] o1
WHERE OrderDate IN (
    SELECT  MAX(OrderDate)
    FROM Sales.[Order] o2
    WHERE o1.CustomerId = o2.CustomerId
)
ORDER BY o1.CustomerId 

-- Exercise 6
-- Write a query that returns customers who placed orders in 2021 but not in 2022 
-- Tables involved: Sales.Customers and Sales.order 
SELECT c.CustomerId, c.CustomerCompanyName
FROM Sales.Customer c 
WHERE EXISTS (
    SELECT * 
    FROM Sales.[Order] o
    WHERE c.CustomerId = o.CustomerId 
    AND o.OrderDate >= '20210101' AND o.OrderDate <= '20211231'
) AND NOT EXISTS (
    SELECT *
    FROM Sales.[Order] o 
    WHERE c.CustomerId = o.CustomerId
    AND o.OrderDate >= '20220101' AND o.OrderDate <= '20221231'
)

-- Exercise 7
-- Write a query that returns customers who ordered product 12 
-- Tables involved: Sales.Customer, Sales.Orders, and Sales.OrderDetail 
SELECT c.CustomerId, c.CustomerCompanyName 
FROM Sales.Customer AS c
WHERE c.CustomerId IN (
    SELECT e.CustomerId 
    FROM Sales.[Order] AS e 
    INNER JOIN Sales.OrderDetail AS od 
    ON od.OrderId = e.OrderId AND od.ProductId = 12

)

-- Exercise 8
-- Write a query that calculates the running total-quantity for each customer and month
-- Tables involved: 

-- Exercise 9
-- Explain the difference between IN and EXIST 
-- The difference bewteen IN and EXIST is that IN uses three-valued logic, so it either returns True, False or Null depending if they are values within a table
-- EXIST on the other hand uses a two-valued logic system that returns True if at least one row exist. It doesn't compare values unlike IN

-- Exercise 10
-- Write a query that returns for each order the number of days that passed since the same customer’s
--previous order. To determine recency among orders, use orderdate as the primary sort element and
--orderid as the tiebreaker
-- Tables involved: Sales.Order
SELECT CustomerId, OrderDate, OrderId, 
    DATEDIFF(day, 
      (SELECT TOP (1) o2.OrderDate
      FROM Sales.[Order] AS o2
      WHERE o2.CustomerId = o1.CustomerId AND (
        o2.OrderDate = o1.OrderDate AND o2.OrderId < o1.OrderId OR
        o2.OrderDate < o1.OrderDate)
        ORDER BY o2.OrderDate DESC, o2.OrderId DESC),
        orderDate) AS diff
FROM Sales.[Order] AS o1
ORDER BY CustomerId, OrderDate, orderId; 

---------------------------------------------------------------------
-- Additional queries
--  Medium article referenced: SQL Subqueries -- From Simple to Advanced
-- (https://medium.com/%40bskky001/sql-subqueries-from-simple-to-advanced-2451e61d6c74)
---------------------------------------------------------------------

-- Exercise 1
-- Return all products whose unit price is less than the average unit price of all products
-- Tables involved: Production.Product
SELECT ProductName, UnitPrice
FROM Production.Product
WHERE UnitPrice < (
    SELECT AVG(UnitPrice)
    FROM Production.Product
)

-- Exercise 2
-- Return all customers who have placed orders in May 2022
-- Tables involved: Sales.Customer, Sales.Order
SELECT c.CustomerId, c.CustomerContactName
FROM Sales.Customer AS c
WHERE c.CustomerId IN (
    SELECT o.CustomerId
    FROM Sales.[Order] AS o 
    WHERE OrderDate >= '20220501' AND OrderDate <= '20220531'
);

-- Exercise 3