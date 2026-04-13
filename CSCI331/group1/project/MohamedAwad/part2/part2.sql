select top(1) * from HumanResources.Employee
select top(1) * from Production.Category
select top(1) * from Production.[Product]
select top(1) * from Production.Supplier
select top(1) * from Sales.Customer
select top(1) * from Sales.[Order]
select top(1) * from Sales.OrderDetail
select top(1) * from Sales.Shipper

/*
 *	(1) Which customers spent the most amount of money.
 */

 select 
	Top(1)
	--OD.OrderId,
	C.CustomerId,
	C.CustomerContactName,
	SUM(OD.UnitPrice * OD.Quantity) as TotalSpending
From
	Sales.[Order] as O
Inner join
	Sales.Customer as C
on
	O.CustomerId = C.CustomerId
Inner join
	Sales.OrderDetail as OD
on
	OD.OrderId = O.OrderId
group by
	--OD.OrderId,
	C.CustomerId,
	C.CustomerContactName
order by
	TotalSpending desc

/*
 *	(2) the month that has the most amount of orders
 */
select
	Datename(month, O.OrderDate ) as [Month],
	count(*)
from
	Sales.[Order] as O
group by
	datename(month, O.OrderDate)
order by
	[Month]

/*
 *	(3) Products that generate the most amount of revenue AKA the best sellers.
 */
 select
	top(1)
	P.ProductId,
	P.ProductName,
	Sum(OD.DiscountedLineAmount) as TotalRevenue
from
	Sales.[OrderDetail] as OD
inner join
	Production.[Product] as P
on
	OD.ProductId = P.ProductId
group by
	P.ProductId,
	P.ProductName
Order by
	TotalRevenue desc

/*
 * (4) Products that are below the average of unit price
 */
 /*
with avgPrice as
(
	select
		avg(UnitPrice) as up
	from
		Production.[Product]
)

select
	*
from avgPrice;
*/
 select
	P.ProductName,
	P.UnitPrice
from
	Production.[Product] as P
where
	P.UnitPrice < 
	(
		select
			avg(UnitPrice) as up
		from
			Production.[Product]
	)
order by
	p.UnitPrice desc

/*
 * (5) The most recent order by customer
 */
 select
	C.CustomerId,
	C.CustomerContactName,
	max(O.OrderDate) as [Recent Order]
from
	Sales.[Order] as O
inner join
	Sales.[Customer] as C
on
	O.CustomerId = C.CustomerId
group by
	C.CustomerId,
	C.CustomerContactName

