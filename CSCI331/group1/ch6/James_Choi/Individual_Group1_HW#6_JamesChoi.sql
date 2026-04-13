Use NorthWinds2024Student;

-- 1
-- Explain the difference between the UNION ALL and UNION operators
-- In what cases are they equivalent?
-- When they are equivalent, which one should you use?

/*
    the UNION ALL operator does not remove differences between two
    sets while the UNION operator does. They are equivalent when there
    exist no duplicates between the sets naturally. UNION ALL is best
    for when there are no duplicates because it has better performace
    than UNION.
*/

-- 2
-- Write a query that generates a virtual auxiliary table of 10 numbers
-- in the range 1 through 10
-- Tables involved: no table

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
-- Write a query that returns customer and employee pairs 
-- that had order activity in January 2022 but not in February 2022
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
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2022 and February 2022
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
-- that had order activity in both January 2022 and February 2022
-- but not in 2021

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
-- You are given the following query:
-- select country, region, city
-- From HR.Employees

-- UNION ALL

-- select country, region, city
-- From Production.Suppliers;

-- You are asked to add logic to the query 
-- such that it would guarantee that the rows from Employees
-- would be returned in the output before the rows from Suppliers,
-- and within each segment, the rows should be sorted
-- by country, region, city

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

------------------------------------------------

/* Proposition 1:
    Let's say we wanted to have a combined list of all the customers and
    employees by ID in 2021, without the duplicates. This query would do so,
    using UNION to remove duplicates.
*/
select CustomerId as PersonId, 'Customer' as PersonType
from Sales.[Order]
where YEAR(OrderDate) = 2021
union
select EmployeeId, 'Employee'
from Sales.[Order]
where YEAR(OrderDate) = 2021;

/* Proposition 2:
    Suppose you wanted to compare the order activity across two different years.
    This query will stack all of the recrods together with UNION ALL, and I wanted
    to preserve the duplicates to get a more accurate total count per period.
*/
select OrderId, CustomerId, EmployeeId, OrderDate, '2021' as OrderYear
from Sales.[Order]
where OrderDate >= '20210101' and OrderDate < '20220101'
union all
select OrderId, CustomerId, EmployeeId, OrderDate, '2022' as OrderYear
from Sales.[Order]
where OrderDate >= '20220101' and OrderDate < '20230101';

/* Proposition 3:
    Let's say we wanted to find employees that handled orders BOTH in q1 and q4.
    This query will do so using INTERSECT.
*/
select EmployeeId
from Sales.[Order]
where MONTH(OrderDate) between 1 and 3
intersect
select EmployeeId
from Sales.[Order]
where MONTH(OrderDate) between 10 and 12;

/* Proposition 4:
    Suppose we wanted to know waht customers did place orders in 2021 but not in 2022.
    This query will use the EXCEPT operator to flag customers that fit in this 
    scenario.
*/
select CustomerId
from Sales.[Order]
where OrderDate >= '20210101' and OrderDate < '20220101'
except
select CustomerId
from Sales.[Order]
where OrderDate >= '20220101' and OrderDate < '20230101';
