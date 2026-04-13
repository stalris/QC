select top(1) * from HumanResources.Employee;
select top(1) * from Production.Category;
select top(1) * from Production.[Product];
select top(1) * from Production.Supplier;
select top(1) * from Sales.Customer;
select top(1) * from Sales.[Order];
select top(1) * from Sales.OrderDetail;
select top(1) * from Sales.Shipper;


/*
 *	(1) Which product do we sell the most of, in terms of tonnage?
 */

select
	sum(O.Freight) as TotalFreight,
	OD.ProductId
from
	Sales.[Order] as O
inner join
	Sales.OrderDetail as OD
on
	O.OrderId = OD.OrderId
group by
	OD.ProductId
order by
	TotalFreight desc;

/*
 *	(2) which companies supply us with these popular items?
 */

 with TotalFreightByProduct as
 (
 select
	sum(O.Freight) as TotalFreight,
	OD.ProductId
from
	Sales.[Order] as O
inner join
	Sales.OrderDetail as OD
on
	O.OrderId = OD.OrderId
group by
	OD.ProductId
 )
select
	TFP.ProductId,
	P.ProductName,
	TFP.TotalFreight,
	S.SupplierCompanyName
from
	Production.[Product] as P
inner join
	Production.Supplier as S
on
	S.SupplierId = P.SupplierId
inner join
	TotalFreightByProduct as TFP
on
	TFP.ProductId = P.ProductId
order by
	TFP.TotalFreight desc

/*
 *	(3) Which customers generate the most revenue for us?
 */
select
	*
from
	sales.[order];
/*
 *	(4) Which region generates the most revenue for us?
 */
select
	C.CustomerCountry,
	sum(OD.DiscountedLineAmount) as TotalRevenue
From	
	Sales.Customer as C
inner join
	Sales.[Order] as O
on
	C.CustomerId = O.CustomerId
inner join
	Sales.OrderDetail as OD
on
	OD.OrderId = O.OrderId
group by
	C.CustomerCountry
Order by
	TotalRevenue desc;

/*
 *	(5) Measure how popular items are, in terms of revenue, per country.
 */
 select
	SUM(OD.DiscountedLineAmount) over (partition by C.CustomerCountry) as P
from
	Sales.OrderDetail as OD
inner join
	Sales.[Order] as O
on
	OD.OrderId = O.OrderId
inner join
	Sales.[Customer] as C
on
	C.CustomerId = O.CustomerId
--
SELECT
    O.ShipToCountry,
    P.ProductId,
    P.ProductName,
    SUM(OD.DiscountedLineAmount) AS Revenue
FROM 
	Sales.OrderDetail AS OD
JOIN 
	Sales.[Order] AS O
ON 
	O.OrderId = OD.OrderId
JOIN 
	Production.Product AS P
ON 
	P.ProductId = OD.ProductId
GROUP BY
    O.ShipToCountry,
    P.ProductId,
    P.ProductName
ORDER BY
    O.ShipToCountry,
    Revenue DESC;