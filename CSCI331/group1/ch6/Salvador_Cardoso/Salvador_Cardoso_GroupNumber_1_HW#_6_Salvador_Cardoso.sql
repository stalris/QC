Use NorthWinds2024Student;
go

/*
 *  (1)
 *
 *  Explain the difference between the UNION ALL and UNION operators. 
 *  In what cases are the two equivalent?
 *  When they are equivalent, which one would you use?
 *
 */

/*
 *
 *  Union includes distinct rows from two queries, q1 and q2, removing any duplicates.
 *  Union All does not remove duplicate rows, basically resulting as an unordered concatenation of rows from q1 and q2.  
 *  
 *  The two are equivalent when there are no duplicate rows.
 *  In such a case, use Union all as it does not have a phase that removes duplicate rows(same result as union since there are no duplicates).
 *
 */


/*
 *  (2) 
 *  Write a query that generates a virtual auxiliary table of 10 numbers in the range 1 through 10 without using a looping construct
 *  or the generate_series() function. 
 *  You do not need to guarantee any presentation order of the rows in the output of your solution.
 */

select
 '(2)'
go

  select
    1 as n
Union all
  select
    2 as n
Union all
  select
    3 as n
Union all
  select
    4 as n
Union all
  select
    5 as n
Union all
  select
    6 as n
Union all
  select
    7 as n
Union all
  select
    8 as n
Union all
  select
    9 as n
Union all
  select
    10 as n
go

/*
 *  (3)
 *  Write a query that returns customer and employee pairs that had order activity in january 2022, 
 *  but not in february 2022
 */

print ''
print  '(3)'
print ''

  select 
    CustomerId,
    EmployeeId
  from
    Sales.[Order]
  where 
    OrderDate >= '20220101'
  and
    OrderDate < '20220201'
Except
  select 
    CustomerId,
    EmployeeId
  from
    Sales.[Order]
  where 
    OrderDate >= '20220201'
  and
    OrderDate < '20220301'
go

/*
 *  (4) Write a query that returns customer and employee pairs that had order activity in both january 2022 and february 2022
 */

print ''
print  'Question (4)'
print ''

  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220101'
  and
    OrderDate < '20220201'
Intersect
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220201'
  and
    OrderDate < '20220301'
go

/*
 *  (5)
 *  Write a query that returns customer and employee pairs that had order activity in both January 2022 and February 2022,
 *  but not in 2021.
 */

print ''
print  'Question (5)'
print '';

with _2022_Activity as
(
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220101'
  and
    OrderDate < '20220201'
Intersect
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220201'
  and
    OrderDate < '20220301'
)
  select 
    CustomerId,
    EmployeeId
  From
    _2022_Activity  
except
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20210101'
  And
    OrderDate < '20220101'

/*
 *  (6)
 *  You are given the following query:
 *
 *  select country, region, city
 *  from HR.Employees
 *  
 *  Union all
 *
 *  select country, region, city
 *  from production.suppliers;
 *
 *  You are asked to add logic to the query so that it guarantees that the rows from Employees are returned in the output before the rows
 *  from suppliers. Also, within each segment, the rows should be sorted by country, region, city.
 */

print ''
print '(6)'
print '';

with locations as
(
    select
      1 as [Order],
      EmployeeCountry as Country,
      EmployeeRegion as Region,
      EmployeeCity as City
    From
      HumanResources.[Employee]
  Union All
    select
      2 as [Order],
      SupplierCountry as Country,
      SupplierRegion as Region,
      SupplierCity as City
    From
      Production.[Supplier] 
)

select
  Country,
  Region,
  City
From
  locations
Order By
  [Order], Country, Region, City


/*
 * Extra (1)
 * Find the symmetric difference of Order activity on January 2022 and February 2022, using CustomerId and EmployeeId
 * The symmetric difference of two sets are elements that belong to one or the other, but not both.
 */

print ''
print 'Extra (1)'
print ''

;with U as
(
    select
      CustomerId,
      EmployeeId
    From
      Sales.[Order]
    Where
      OrderDate >= '20220101'
    And
      OrderDate < '20220201'

  Union
    select
      CustomerId,
      EmployeeId
    From
      Sales.[Order]
    Where
      OrderDate >= '20220201'
    And
      OrderDate < '20220301'
),
I as
(
    select
      CustomerId,
      EmployeeId
    From
      Sales.[Order]
    Where
      OrderDate >= '20220101'
    And
      OrderDate < '20220201'

  Intersect  

    select
      CustomerId,
      EmployeeId
    From
      Sales.[Order]
    Where
      OrderDate >= '20220201'
    And
      OrderDate < '20220301'
)

  select
    CustomerId,
    EmployeeId
  From
    U
Except
  Select
    CustomerId,
    EmployeeId
  From  
    I
Order by
  CustomerId;
go

print ''
print 'extra (2)'
print ''

/*
 * (2) distinct Employee, Customer pairs active in the first quarter of 2022.
 */

;with jan as
(
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220101'
  And
    OrderDate < '20220201'
), feb as
(
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220201'
  And
    OrderDate < '20220301'
), mar as 
(
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220301'
  And
    OrderDate < '20220401'
)
-- Actual query here.
  select
    CustomerId,
    EmployeeId
  From
    jan

intersect

  select
    CustomerId,
    EmployeeId
  From
    feb 

intersect

  select
    CustomerId,
    EmployeeId
  From
    mar

order by
  CustomerId,
  EmployeeId
go

print ''
print 'extra (3)'
print ''

/*
 * (3)
 * New pairs in 2022 that DNE in 2021
 */

;with year2022 as
(
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20220101'
  And
    OrderDate < '20230101'
), year2021 as
(
  select
    CustomerId,
    EmployeeId
  From
    Sales.[Order]
  Where
    OrderDate >= '20210101'
  And
    OrderDate < '20220101'
)

-- real query here
  select
    CustomerId,
    EmployeeId
  From
    year2022

Except
 
  select
    CustomerId,
    EmployeeId
  From
    year2021
order by
  CustomerId, EmployeeId
