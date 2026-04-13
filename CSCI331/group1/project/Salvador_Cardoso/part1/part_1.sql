/*
 *  Mystery:
 *
 *    As part of the annual performance review process, leadership has requested an assessment of sales performance. Management wants to compile several metrics by which to judge every employee's performance.
 *  The assessment must examine employee performance from multiple angles, including total revenue, order volume, customer concentration, discount behavior, product mix, category exposure, supplier exposure, and shipper usage.
 */

/*  
 *  Identifying the strongest performers by sales volume.
 *
 *  Before management can evaluate employee performance in more detail, it first needs a reliable summary of basic sales activity. 
 *  In this section, the investigation begins with the simplest measurable facts: 
 *    how many orders each employee handled, 
 *    how those employees are identified in the company, 
 *    what line items appear in the orders they managed, 
 *    and how those detailed line items can be rolled up into larger performance totals. i
 *  Each step builds on the previous one so that the final results are both understandable and verifiable
 *
 */

/*
 *  To begin the investigation, first identify which employees appear in the order records and 
 *  count how many orders each one handled during the reporting period. 
 *  At this stage, only the EmployeeId and the total number of orders are needed. 
 *  This provides a simple starting point for the performance review and establishes a baseline ranking before any other details are introduced.
 *
 *  Tables used: Sales.[Order]
 *
 *  Expected Output:

EmployeeId  TotalOrders
----------- -----------
          4         156
          3         127
          1         123
          8         104
          2          96
          7          72
          6          67
          9          43
          5          42

(9 rows affected)

*/

/*
 * Enter query here.
 */

/*
 *
 *  The previous result identifies employees only by ID, which is useful for the database but not very meaningful to management. 
 *  In this step, join the order data to the employee table so that each EmployeeId is paired with the employee’s full name and job title. 
 *  The total number of orders should remain the same as in the previous query, but the results should now be easier to read and interpret.
 *
 *  New table introduced: HumanResources.Employee
 *
 *  Expected Output:

EmployeeId  EmployeeName                                        EmployeeTitle                  TotalOrders
----------- --------------------------------------------------- ------------------------------ -----------
          4 Yael Peled                                          Sales Representative                   156
          3 Judy Lew                                            Sales Manager                          127
          1 Sara Davis                                          CEO                                    123
          8 Maria Cameron                                       Sales Representative                   104
          2 Don Funk                                            Vice President, Sales                   96
          7 Russell King                                        Sales Representative                    72
          6 Paul Suurs                                          Sales Representative                    67
          9 Patricia Doyle                                      Sales Representative                    43
          5 Sven Mortensen                                      Sales Manager                           42

(9 rows affected)

 */

/*
 *  query here
 */

/*
 *
 *  Now that the employees responsible for each order have been identified, the next step is to examine the detailed line items within those orders. 
 *  Join the order records to the order detail table and display the product-level sales information associated with each employee’s orders. 
 *  Include the 
 *    ProductId,
 *    Quantity,
 *    LineAmount, and
 *    DiscountedLineAmount
 *  so that the raw sales activity can be inspected before any aggregation is performed. 
 *  The purpose of this step is to show where the revenue data comes from and to make clear that a single order may contain multiple line items.
 *
 *  New table introduced: Sales.OrderDetail
 *
 *  Expected Output:

OrderId     EmployeeId  EmployeeName                                        EmployeeTitle                  ProductId   Quantity LineAmount            DiscountedLineAmount
----------- ----------- --------------------------------------------------- ------------------------------ ----------- -------- --------------------- ---------------------------
      10258           1 Sara Davis                                          CEO                                      2       50              760.0000                 608.0000000
      10258           1 Sara Davis                                          CEO                                      5       65             1105.0000                 884.0000000
      10258           1 Sara Davis                                          CEO                                     32        6              153.6000                 122.8800000
.
.
.
      11058           9 Patricia Doyle                                      Sales Representative                    21        3               30.0000                  30.0000000
      11058           9 Patricia Doyle                                      Sales Representative                    60       21              714.0000                 714.0000000
      11058           9 Patricia Doyle                                      Sales Representative                    61        4              114.0000                 114.0000000

(2155 rows affected)

*/

/*
 *  Query here:
 */

/*
 *
 *  After inspecting the detailed line items, summarize them at the employee level. 
 *  Use the order detail rows to calculate three performance measures for each employee: 
 *    total units sold,
 *    gross sales before discounts, and
 *    net sales after discounts.
 *  Since joining orders to order details creates multiple rows per order,
 *  be careful to count distinct orders rather than counting every detail row as a separate order. 
 *  This step produces the first complete employee-level sales summary and serves as the foundation for the later sections of the mystery
 *
 *  Expected Output:

EmployeeId  EmployeeName                                        EmployeeTitle                  TotalUnitsSold GrossSales            NetSalesAfterDiscount                    TotalOrders
----------- --------------------------------------------------- ------------------------------ -------------- --------------------- ---------------------------------------- -----------
          4 Yael Peled                                          Sales Representative                     9798           250187.4500
  232890.8460000         156
          3 Judy Lew                                            Sales Manager                            7852           213051.3000
  202812.8430000         127
          1 Sara Davis                                          CEO                                      7812           202143.7100
  192107.6045000         123
          2 Don Funk                                            Vice President, Sales                    6055           177749.2600
  166537.7550000          96
          8 Maria Cameron                                       Sales Representative                     5913           133301.0300
  126862.2775000         104
          7 Russell King                                        Sales Representative                     4654           141295.9900
  124568.2350000          72
          9 Patricia Doyle                                      Sales Representative                     2670            82964.0000
   77308.0665000          43
          6 Paul Suurs                                          Sales Representative                     3527            78198.1000
   73913.1295000          67
          5 Sven Mortensen                                      Sales Manager                            3036            75567.7500
   68792.2825000          42

(9 rows affected)

*/

/*
 *  Query here:
 */

/*
 * ANSWERS
 *
 *  (1.1):

SELECT
    O.EmployeeId,
    COUNT(*) AS TotalOrders
FROM 
  Sales.[Order] AS O
GROUP BY 
  O.EmployeeId
ORDER BY 
  TotalOrders DESC, O.EmployeeId;

 *  (1.2):

SELECT
    O.EmployeeId,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName,
    E.EmployeeTitle,
    COUNT(*) AS TotalOrders
FROM 
  Sales.[Order] AS O
INNER JOIN
  HumanResources.Employee as E
ON
  O.EmployeeId = E.EmployeeId
GROUP BY 
  O.EmployeeId,
  E.EmployeeFirstName,
  E.EmployeeLastName,
  E.EmployeeTitle
ORDER BY 
  TotalOrders DESC, O.EmployeeId;

 * (1.3):

SELECT
    O.OrderId,
    O.EmployeeId,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName,
    E.EmployeeTitle,
    OD.ProductId,
    OD.Quantity,
    OD.LineAmount,
    OD.DiscountedLineAmount
FROM Sales.[Order] AS O
INNER JOIN HumanResources.Employee AS E
    ON O.EmployeeId = E.EmployeeId
INNER JOIN Sales.OrderDetail AS OD
    ON OD.OrderId = O.OrderId
ORDER BY
    O.EmployeeId,
    O.OrderId,
    OD.ProductId;

 *  (1.4)

SELECT
    O.EmployeeId,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName,
    E.EmployeeTitle,
    SUM(OD.Quantity) AS TotalUnitsSold,
    SUM(OD.LineAmount) AS GrossSales,
    SUM(OD.DiscountedLineAmount) AS NetSalesAfterDiscount,
    COUNT(DISTINCT O.OrderId) AS TotalOrders
FROM Sales.[Order] AS O
INNER JOIN HumanResources.Employee AS E
    ON O.EmployeeId = E.EmployeeId
INNER JOIN Sales.OrderDetail AS OD
    ON OD.OrderId = O.OrderId
GROUP BY
    O.EmployeeId,
    E.EmployeeFirstName,
    E.EmployeeLastName,
    E.EmployeeTitle
ORDER BY
    NetSalesAfterDiscount DESC,
    TotalOrders DESC,
    O.EmployeeId;
