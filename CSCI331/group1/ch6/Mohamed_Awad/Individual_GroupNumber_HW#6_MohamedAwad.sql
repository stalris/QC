USE Northwinds2024Student;
---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 06 - Set Operations
-- Exercises
---------------------------------------------------------------------

-- Exercise 1
-- Explain the difference between UNION ALL and UNION operators. In what cases are the two equivalent? When are they equivalent and which should you use?
/*Answer: The difference between UNION ALL and UNION is that UNION returns all the rows from both tables with duplicates, 
whereas UNION returns all rows from both tables and eliminates duplicates. They are equivalent only if they are guaranteed to have no duplicate rows.
In some cases, you should use UNION ALL since not only has a better performance than UNION, you don't have to bother using the unnecessary perfomance penalty for checking duplicates.

*/

-- Exercise 2
-- Write a query that generates a virtual auxiliary table of 10 numbers in the range 1-10 without using a looping construct or generate series function
-- Tables involved: None 
SELECT 1 AS n
UNION ALL
SELECT 2
UNION ALL
SELECT 3
UNION ALL
SELECT 4
UNION ALL
SELECT 5
UNION ALL
SELECT 6
UNION ALL
SELECT 7
UNION ALL
SELECT 8
UNION ALL
SELECT 9
UNION ALL
SELECT 10

-- Exercise 3
-- Write a query that returns customer and employee pairs that had order activity in January 2022 but not in February 2022
-- Tables involved: Sales.Order
SELECT CustomerId, EmployeeId
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate >= '20220101' AND OrderDate <= '20220131'
) AS table1
EXCEPT
SELECT CustomerId, EmployeeId 
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate >= '20220201' AND OrderDate <= '20220228'
) AS table2

-- Exercise 4
-- Write a query that returns customer and employee pairs that had an order activity in both January 2022 and February 2022
-- Tables involved: Sales.Order
SELECT CustomerId, EmployeeId
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate >= '20220101' AND OrderDate <= '20220131'
) AS table1
INTERSECT
SELECT CustomerId, EmployeeId 
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate >= '20220201' AND OrderDate <= '20220228'
) AS table2

-- Exercise 5
-- Write a query that returns customer and employee pairs that had an order activity in both Jan. 2022 and Feb. 2022, but not in 2021
-- Tables involved: Sales.Orders
SELECT CustomerId, EmployeeId
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate >= '20220101' AND OrderDate <= '20220131'
) AS table1
INTERSECT
SELECT CustomerId, EmployeeId 
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate >= '20220201' AND OrderDate <= '20220228'
) AS table2
EXCEPT -- Returns all the rows on the left, but not on the right
SELECT CustomerId, EmployeeId
FROM (
    SELECT CustomerId, EmployeeId
    FROM Sales.[Order]
    WHERE OrderDate BETWEEN '20210101' AND '20211231'
) AS table3

-- Exercise 6
-- You are given the following query:
/*
SELECT country, region, city
FROM HR.Employees
UNION ALL
SELECT country, region, city
FROM Production.Suppliers;
*/
-- You are asked to add logic to the query so that it guarantees that the the rows from Employees are returned in the output before the rows from Suppliers. Also, within each segment, the rows should be sorted by country, region, and city.
-- Tables involved: HR.Employee and Production.Supplier
SELECT EmployeeCountry, EmployeeRegion, EmployeeCity
FROM (
    SELECT 1 AS sortColumn, EmployeeCountry, EmployeeRegion, EmployeeCity
    FROM HumanResources.Employee

    UNION ALL 
    SELECT 2, SupplierCountry, SupplierRegion, SupplierCity
    FROM Production.Supplier
) AS EmployeeTable

-----------------------------------------------------------------------
-- Additional query proposition
--  Medium article referenced: SQL Set Operators: How to UNION, INTERSECT, and EXCEPT Your Data with Precision (The Analyst's Guide)
-- (https://medium.com/@harsh1995hg/sql-set-operators-how-to-union-intersect-and-except-your-data-with-precision-the-analysts-86b21bbe2ed0)
---------------------------------------------------------------------
-- Exercise 7
-- Write a query that returns customers who have placed orders in 2021 but not in 2022
-- Tables involved: Sales.Orders 
SELECT CustomerId, OrderId
FROM (
    SELECT CustomerId, OrderId
    FROM Sales.[Order]
    WHERE OrderDate BETWEEN '20210101' AND '20211231'
) AS table1
EXCEPT 
SELECT CustomerId, OrderId 
FROM (
    SELECT CustomerId, OrderId
    FROM Sales.[Order]
    WHERE OrderDate BETWEEN '20220101' AND '20221231'
) AS table2



