use Northwinds2024Student;

-- (1) The problem is that the query references the alias endofyear, but structurally the query doesn't know about this alias at the point the where clause is executed. To recap, queries are processed in the following order:
--  From > Join > On > Where > Group By > Having > Select > Order By 
-- Since the Select clause defines the alias endofyear, but the Where clause happens before this definition, it effectively tries to use a variable that hasn't been declared yet.
-- To Fix this, you can make a subquery that grabs the desired columns from the table and aliases them as needed. This subquery would live in the From clause. That way, the query would then see these aliases during the Where phase that follows.
-- The query would look something like this:

Select
top(10)
OrderId, OrderDate, CustomerId, EmployeeId, EndOfYear 
From
  (
    Select
      OrderId, OrderDate, CustomerId, EmployeeId, DATEFROMPARTS(YEAR(OrderDate), 12, 31) as EndOfYear 
    From
      Sales.[Order]
  ) as O
Where
  OrderDate != EndOfYear;
go

-- (2.1) Write a query that returns the maximum value in the orderdate column for each employee
Select 
  EmployeeId, MaxOrderDate
From
  (
    Select
      EmployeeId, MAX(OrderDate) as MaxOrderDate
    From  
      Sales.[Order]
    Group By
      EmployeeId
  ) as O
Order By
  EmployeeId;
go

-- (2.2) Encapsulate the query from Exercise 2-1 in a derived table. Write a join query between the derived table and the orders table to return the orders with the maximum order date for each employee.

select top(1) 'Question 2.2' from Sales.[Order];
go

With MostRecentOrders AS
(
  Select 
    EmployeeId, MaxOrderDate
  From
    (
      Select
        EmployeeId, MAX(OrderDate) as MaxOrderDate
      From
        Sales.[Order]
      Group By
        EmployeeId      
    ) As O
)

Select 
  M.EmployeeId, M.MaxOrderdate, O.OrderId, O.CustomerId
From
  MostRecentOrders as M
Join
  Sales.[Order] as O
ON
  M.EmployeeId = O.EmployeeId
AND
  M.MaxOrderDate = O.OrderDate
Order By
  M.EmployeeId;
go

-- (3.1) Write a query that calculates a row number for each order based on orderdate, orderid ordering.
With Ordering As
(
  Select 
    OrderId, OrderDate, CustomerId, EmployeeId, Row_Number() Over(order by OrderDate, OrderId) as RowNum
  From
    Sales.[Order] as O
)  

-- (3.2) Write a query that returns rows with numbers 11 through 20 based on the row-number definition in Exercise 3-1.
Select
  OrderId, OrderDate, CustomerId, EmployeeId, RowNum
From
  Ordering
where RowNum
Between 11 and 20
/*
Where
  RowNum >= 11
And
  RowNum <= 20
*/
Order By
  OrderId, OrderDate;
Go

/*
 * Forgot what the qualified name for the HR table is. Find out. 
 */
-- select S.name as Schema_Name, T.name as Table_name, concat(S.name, ".", T.name) as qualified_name from sys.schemas as S join sys.tables as T on S.Schema_Id = T.Schema_Id;

/*
 * Find out the structure of the HumanResources.Employee table.
 */

select top(1) * from HumanResources.[Employee];
go

-- (4.1) Write a solution using a recursive CTE that returns the management chain leading to Patricia Doyle(EmployeeId = 9):w
With GetMgmtChain As
(
  -- Base Case
  Select 
    E.EmployeeId, E.EmployeeManagerId, E.EmployeeFirstName, E.EmployeeLastName
  From
    HumanResources.[Employee] as E -- Base Case refers to some table.
  Where
    E.EmployeeId = 9 -- Start with Patricia Doyle in the base case.

  UNION ALL -- Keyword to signify the transition from base case to recursive case    

  Select
    E.EmployeeId, E.EmployeeManagerId, E.EmployeeFirstName, E.EmployeeLastName -- Make sure to have the same columns as the base case.
  From
    GetMgmtChain as M -- Recursive case refers to this CTE. Initially starts by referencing the base case.
  Join
    HumanResources.[Employee] as E
  On
    E.EmployeeId = M.EmployeeManagerId
) 

Select 
  EmployeeId,
  EmployeeManagerId,
  EmployeeFirstName,
  EmployeeLastName
From
  GetMgmtChain;
Go

-- (5.1) Create a view that returns the total quantity for each employee and year.
/*
 * I forgot the structure of the Order Table, inspect it.
 */

-- select top(1) * from Sales.[Order];
-- select top(1) * from Sales.[OrderDetail];

Create or Alter View Sales.VEmpOrder As -- your view's name must be qualified with a schema.
Select
  O.EmployeeId,
  Year(O.OrderDate) as OrderYear,
  Sum(OD.Quantity) as TotalQuantity
From
  Sales.[Order] as O
Join
  Sales.[OrderDetail] as OD
On
  O.OrderId = OD.OrderId
Group by
  O.EmployeeId,
  Year(O.OrderDate)
go

select * from Sales.[VEmpOrder] order by EmployeeId, OrderYear
go

-- (5.2) Write a query against Sales.VEmpOrder that returns the running total quantity for each employee and year.
Select
  O1.EmployeeId,
  O1.OrderYear,
  O1.TotalQuantity,
  SUM(O2.TotalQuantity) as RunningQuantity
From
  Sales.[VEmpOrder] as O1
Join
  Sales.[VEmpOrder] as O2
On
  O1.EmployeeId = O2.EmployeeId
And
  O1.OrderYear >= O2.OrderYear
Group By
  O1.EmployeeId,
  O1.OrderYear,
  O1.TotalQuantity
Order By
  O1.EmployeeId,
  O1.OrderYear,
  O1.TotalQuantity
Go

-- (6.1) Create an inline TVF that accepts as inputs a supplier ID(@SupId as Int) and a requested number of products (@n As Int).
-- The function should return @n products with the highest unit prices that are supplied by the specifid supplier id.

/*
 * Inspect the columns for the Product table.
 */
--select top(1) * from Production.Product;

Create or Alter Function 
  Production.TopProducts (@SupId As Int, @N As Int) -- Qualified name required for the IVF name
Returns Table  -- Specifies the return type is a table
As Return -- Honestly, no idea why this syntax exists.
  Select
    -- top(2)
    ProductId,
    ProductName,
    UnitPrice
  From
    Production.[Product]
  Where
    SupplierId = @SupId -- Grab all items by this supplier.
  Order By
    UnitPrice Desc 
  Offset 0 Rows -- Don't forget, Offset/Fetch requires a preceeding 'Order By' clause.
  Fetch next @N rows only  
Go

select * from Production.TopProducts(5, 2) -- Grab SupplierId = 5, and return only the top 2 most expensive results
-- Select * from Production.[Product] Order By SupplierId; -- Inspect the original table to confirm the above results.
go

-- (6.2) Using the Cross Apply operator and the function you created in 6.1, return the two most expensive products for each supplier. 
/*
 * Inspect the Production.[Supplier] table
 */

select top(1) * from Production.[Supplier];

select
  S.SupplierId,
  S.SupplierCompanyName,
  T.ProductId,
  T.ProductName,
  T.UnitPrice
From
  Production.[Supplier] as S
Cross Apply
  Production.TopProducts(S.SupplierId, 2) as T
go

