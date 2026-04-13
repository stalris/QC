/* 
 *  Step 0:
 *    Create a dummy table to work with, so you don't pollute an existing table.
 */
USE TSQLV6;
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders
(
  OrderID INT NOT NULL
  CONSTRAINT PK_Orders PRIMARY KEY,
  OrderDate DATE NOT NULL
  CONSTRAINT DFT_OrderDate DEFAULT(SYSDATETIME()),
  EmpID INT NOT NULL,
  CustID VARCHAR(10) NOT NULL,
  Email VARCHAR(20) NOT NULL
);

/*  
 *  (1)
 *
 *  Insert into a table with the provided values.
 *  syntax:
 *
 *    1) INSERT INTO schema_name.table_name (col1, col2, ...) VAlUES (val1, val2, ...){ , (val1, val2, ...) }
 *    2) INSERT INTO schema_name.table_name VALUES (val1, val2, ...) { , (val1, val2, ...) }
 *  
 */

--  The first version allows you insert values independently of how the columns are defined.
-- This inserts into the table in the order the columns were defined.
-- OrderDate generates a default value of SYSDATETIME(), per the table definition.
INSERT INTO 
  dbo.Orders (OrderId, EmpID, CustID, Email)
VALUES
  (1, 1, 1, N'someEmail@gmail.com'),
  (2, 1, 1, N'anotherEmail@qc.cuny.edu'),
  (3, 100, 200, N'thirdUser@mciMail.com')

-- This inserts columns based on the provided order.
INSERT INTO
  dbo.Orders (CustID, Email, EmpID, OrderID)
VALUES
  (1, N'fourthUser@yahoo.com', 1, 4)

-- Providing the column order is optional. If omitted, uses the order from the table definition.
INSERT INTO
  dbo.Orders
VALUES
  (5, 1, 1, N'fifthUser@aol.com'),
  (6, 1, 10, N'sixthUser@askJeeves.com')

/*
 *  (2)
 *  
 *  Insert into a table using a querie's results
 */
INSERT INTO
  dbo.Orders (OrderId, 
