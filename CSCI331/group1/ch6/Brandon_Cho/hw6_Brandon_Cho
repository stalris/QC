Use NorthWinds2024Student;

-- 1
-- Describe the difference between the UNION and UNION ALL operators.
-- When will both operators return the same result?
-- If the results are identical, which operator is preferable?

/*
    UNION removes duplicate rows from the combined result set,
    while UNION ALL keeps every row from both queries including duplicates.
    They will produce the same output if there are no duplicate rows
    between the two result sets. In those situations, UNION ALL should
    be used because it performs faster since it does not need to check
    for duplicates.
*/

-- 2
-- Create a query that produces a temporary table of numbers
-- containing values from 1 to 10
-- Tables involved: none

select 1 as n
union all select 2
union all select 3
union all select 4
union all select 5
union all select 6
union all select 7
union all select 8
union all select 9
union all select 10;


-- 3
-- Write a query that finds customer and employee combinations
-- that placed orders in January 2022 but had no orders in February 2022
-- Tables involved: TSQLV6 database, Orders table

select CustomerId, EmployeeId
from Sales.[Order]
where OrderDate >= '20220101'
  and OrderDate < '20220201'

except

select CustomerId, EmployeeId
from Sales.[Order]
where OrderDate >= '20220201'
  and OrderDate < '20220301';


-- 4
-- Write a query that lists customer and employee pairs
-- that placed orders in both January 2022 and February 2022
-- Tables involved: TSQLV6 database, Orders table

select CustomerId, EmployeeId
from Sales.[Order]
where OrderDate >= '20220101'
  and OrderDate < '20220201'

intersect

select CustomerId, EmployeeId
from Sales.[Order]
where OrderDate >= '20220201'
  and OrderDate < '20220301';


-- 5
-- Write a query that returns customer and employee pairs
-- that had order activity in January and February of 2022
-- but had no orders at any time during 2021

with Activity2022 as
(
    select CustomerId, EmployeeId
    from Sales.[Order]
    where OrderDate >= '20220101'
      and OrderDate < '20220201'

    intersect

    select CustomerId, EmployeeId
    from Sales.[Order]
    where OrderDate >= '20220201'
      and OrderDate < '20220301'
)

select CustomerId, EmployeeId
from Activity2022

except

select CustomerId, EmployeeId
from Sales.[Order]
where OrderDate >= '20210101'
  and OrderDate < '20220101';


-- 6
-- Modify the following query so that rows from the Employees table
-- appear before rows from the Suppliers table in the result.
-- Additionally, ensure each group is sorted by country, region, and city.

with Locations as
(
    select 
        1 as SortOrder,
        EmployeeCountry as Country,
        EmployeeRegion as Region,
        EmployeeCity as City
    from HumanResources.Employee

    union all

    select 
        2 as SortOrder,
        SupplierCountry,
        SupplierRegion,
        SupplierCity
    from Production.Supplier
)

select Country, Region, City
from Locations

order by SortOrder, Country, Region, City;

-- 7
-- Return a list of cities from Employees and Suppliers without duplicates

select EmployeeCity as City
from HumanResources.Employee

union

select SupplierCity
from Production.Supplier;


-- 8
-- Return a list of cities from Employees and Suppliers including duplicates

select EmployeeCity as City
from HumanResources.Employee

union all

select SupplierCity
from Production.Supplier;


-- 9
-- Return cities that exist in both Employees and Suppliers tables

select EmployeeCity as City
from HumanResources.Employee

intersect

select SupplierCity
from Production.Supplier;


-- 10
-- Return cities that exist in Employees but not in Suppliers

select EmployeeCity as City
from HumanResources.Employee

except

select SupplierCity
from Production.Supplier;
