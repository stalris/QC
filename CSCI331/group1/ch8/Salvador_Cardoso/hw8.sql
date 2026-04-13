use Northwinds2024Student;

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
  CustomerID    INT           NOT NULL PRIMARY KEY,
  CompanyName   NVARCHAR(40)  NOT NULL,
  Country       NVARCHAR(40)  NOT NULL,
  Region        NVARCHAR(15)  NULL,
  City          NVARCHAR(15)  NOT NULL
);

/*
 *  Exercise 1-1
 *  
 *  Insert into the dbo.Customers table a row with the following information:
 *  ■ custid: 100
 *  ■ companyname: Coho Winery
 *  ■ country: USA
 *  ■ region: WA
 *  ■ city: Redmond
 */

INSERT INTO
  dbo.Customers (CustomerID, CompanyName, Country, Region, City)
Values
  (100, 'Coho Winery', 'USA', 'WA', 'Redmond');


/*
 * Exercise 1-2
 *
 * Insert into the dbo.Customers table all customers from Sales.Customers who placed orders.
 */
INSERT INTO 
  dbo.Customers (CustomerID, CompanyName, Country, Region, City)
(
SELECT
  CustomerId, 
  CustomerCompanyName, 
  CustomerCountry, 
  CustomerRegion, 
  CustomerCity
FROM
  Sales.[Customer]
)
