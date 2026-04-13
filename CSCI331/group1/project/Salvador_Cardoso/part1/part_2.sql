/*
 *  Section 2: Measuring Customer Concentration
 *
 *  Intro to Section 2
 *  Section 1 established which employees handled the most orders and generated the most sales. 
 *  However, strong overall performance does not necessarily mean that an employee’s business is widely distributed. 
 *  Some employees may work with many customers, while others may depend heavily on a smaller group of accounts. 
 *  In this section, the investigation shifts from overall sales activity to customer concentration. 
 *  The goal is to identify which customers are tied to each employee, examine the detailed order activity connecting them, and then measure how much revenue each employee receives from each customer.  
 */

/*
 *  (2.1) Begin by identifying the customers associated with each employee and counting how many distinct customers each employee served during the reporting period. 
 *  This gives the first measure of portfolio breadth.
 *
 *  Tables used: Sales.[Order], Sales.Customer 
 *
 *  Expected Output:

EmployeeId  DistinctCustomers
----------- -----------------
          4                75
          1                65
          3                63
          2                59
          8                56
          7                45
          6                43
          5                29
          9                29

(9 rows affected)

 */

/*
 *  Query here:
 */

/*
 *  (2.2)  After counting how many distinct customers each employee served, inspect the detailed employee-customer order relationships directly. 
 *  At this stage, do not calculate revenue yet. Instead, display the individual order records that connect employees to customers. 
 *  This makes it possible to verify which orders belong to which employee-customer pair before introducing any money-related calculations.
 *
 *  Expected Output:

OrderId     EmployeeId  CustomerId  CustomerCompanyName                      OrderDate
----------- ----------- ----------- ---------------------------------------- ----------------
      10835           1           1 Customer NRZBB                                 2022-01-15
      10952           1           1 Customer NRZBB                                 2022-03-16
      10677           1           3 Customer KBUDE                                 2021-09-22
          .
          .
          .
      10577           9          82 Customer EYHKM                                 2021-06-23
      10750           9          87 Customer ZHYOS                                 2021-11-21
      10905           9          88 Customer SRQVM                                 2022-02-24

(830 rows affected)

*/

/*
 * Query here
 */

/*
 *  (2.3) Now that the employee-customer order relationships have been identified, bring in the order detail rows so management can see where the revenue data comes from. 
 *  At this stage, the goal is still inspection rather than summarization. 
 *  Include the line-item values so that each employee-customer order can be traced to the underlying quantities and monetary amounts.
 *
 *  New table introduced: Sales.OrderDetail
 *
 *  Expected Output:

OrderId     EmployeeId  CustomerId  CustomerCompanyName                      ProductId   Quantity LineAmount            DiscountedLineAmount
----------- ----------- ----------- ---------------------------------------- ----------- -------- --------------------- ---------------------------
      10835           1           1 Customer NRZBB                                    59       15              825.0000                 825.0000000
      10835           1           1 Customer NRZBB                                    77        2               26.0000                  20.8000000
      10952           1           1 Customer NRZBB                                     6       16              400.0000                 380.0000000
          .
          .
          .
      10750           9          87 Customer ZHYOS                                    45       40              380.0000                 323.0000000
      10750           9          87 Customer ZHYOS                                    59       25             1375.0000                1168.7500000
      10905           9          88 Customer SRQVM                                     1       20              360.0000                 342.0000000

(2155 rows affected)
*/

/*
 *  Query here
 */

/*
 *  (2.4) After inspecting the detailed line items, aggregate them to the employee-customer level. 
 *  Sum the discounted line amounts so that each row represents the total revenue one employee generated from one customer. 
 *  This gives the first true revenue-based measure of customer concentration and prepares the way for later comparisons between employee totals and customer-level contributions.
 * 
 *  Expected Output:

EmployeeId  CustomerId  CustomerCompanyName                      CustomerRevenue
----------- ----------- ---------------------------------------- ----------------------------------------
          1          71 Customer LCOUJ                                                      20653.1000000
          1          34 Customer IBVRG                                                      19800.0000000
          1          20 Customer THHDP                                                      17087.2800000
          1          65 Customer NYUHS                                                      12442.1205000
          .
          .
          .
          9          11 Customer UBHAU                                                        139.8000000
          9          28 Customer XYUFB                                                         57.8000000
          9          12 Customer PSNMQ                                                         12.5000000

(464 rows affected)

*/

/*
 *  Query here
 */


/*
 *  Answers:
 *
 *  (2.1)
 *
 *  SELECT
 *    O.EmployeeId,
 *    COUNT(DISTINCT O.CustomerId) AS DistinctCustomers
 *  FROM 
 *    Sales.[Order] AS O
 *  INNER JOIN 
 *    Sales.Customer AS C
 *  ON 
 *    O.CustomerId = C.CustomerId
 *  GROUP BY
 *    O.EmployeeId
 *  ORDER BY
 *    DistinctCustomers DESC,
 *    O.EmployeeId;
 *
 *  (2.2)
 *
 *  SELECT
 *    O.OrderId,
 *    O.EmployeeId,
 *    C.CustomerId,
 *    C.CustomerCompanyName,
 *    O.OrderDate
 *  FROM 
 *    Sales.[Order] AS O
 *  INNER JOIN 
 *    Sales.Customer AS C
 *  ON
 *    O.CustomerId = C.CustomerId
 *  ORDER BY
 *    O.EmployeeId,
 *    C.CustomerId,
 *    O.OrderId;
 *
 *  (2.3)

 *  SELECT
 *    O.OrderId,
 *    O.EmployeeId,
 *    C.CustomerId,
 *    C.CustomerCompanyName,
 *    O.OrderDate
 *  FROM 
 *    Sales.[Order] AS O
 *  INNER JOIN 
 *    Sales.Customer AS C
 *  ON
 *    O.CustomerId = C.CustomerId
 *  ORDER BY
 *    O.EmployeeId,
 *    C.CustomerId,
 *    O.OrderId;
 
 *  SELECT
 *    O.OrderId,
 *    O.EmployeeId,
 *    C.CustomerId,
 *    C.CustomerCompanyName,
 *    OD.ProductId,
 *    OD.Quantity,
 *    OD.LineAmount,
 *    OD.DiscountedLineAmount
 *  FROM
 *    Sales.[Order] AS O
 *  INNER JOIN 
 *    Sales.Customer AS C
 *  ON
 *    O.CustomerId = C.CustomerId
 *  INNER JOIN 
 *    Sales.OrderDetail AS OD
 *  ON 
 *    O.OrderId = OD.OrderId
 *  ORDER BY
 *    O.EmployeeId,
 *    C.CustomerId,
 *    O.OrderId,
 *    OD.ProductId;
 *
 *  (2.4)
 *
 *  SELECT
 *    O.EmployeeId,
 *    C.CustomerId,
 *    C.CustomerCompanyName,
 *    SUM(OD.DiscountedLineAmount) AS CustomerRevenue
 *  FROM 
 *    Sales.[Order] AS O
 *  INNER JOIN 
 *    Sales.Customer AS C
 *  ON
 *    O.CustomerId = C.CustomerId
 *  INNER JOIN 
 *    Sales.OrderDetail AS OD
 *  ON 
 *    O.OrderId = OD.OrderId
 *  GROUP BY
 *    O.EmployeeId,
 *    C.CustomerId,
 *    C.CustomerCompanyName
 *  ORDER BY
 *    O.EmployeeId,
 *    CustomerRevenue DESC,
 *    C.CustomerId;
 *
 */
  
