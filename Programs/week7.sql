CREATE DATABASE BankDB;

USE BankDB;


============================================================
2. CREATE CUSTOMER TABLE
============================================================

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(100),
    City VARCHAR(50)
);


============================================================
3. CREATE ACCOUNT TABLE
============================================================

CREATE TABLE Account (
    Account_No INT PRIMARY KEY,
    Customer_ID INT,
    Account_Type VARCHAR(20),
    Balance DECIMAL(12,2),
    Branch VARCHAR(50),

    FOREIGN KEY (Customer_ID)
    REFERENCES Customer(Customer_ID)
);


============================================================
4. CREATE BANK TRANSACTION TABLE
============================================================

CREATE TABLE Bank_Transaction (
    Transaction_ID INT PRIMARY KEY AUTO_INCREMENT,
    Account_No INT,
    Transaction_Type VARCHAR(20),
    Amount DECIMAL(12,2),
    Transaction_Date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (Account_No)
    REFERENCES Account(Account_No)
);


============================================================
5. CREATE LOAN TABLE
============================================================

CREATE TABLE Loan (
    Loan_ID INT PRIMARY KEY,
    Customer_ID INT,
    Loan_Type VARCHAR(30),
    Loan_Amount DECIMAL(12,2),
    Interest_Rate DECIMAL(5,2),

    FOREIGN KEY (Customer_ID)
    REFERENCES Customer(Customer_ID)
);


============================================================
6. INSERT CUSTOMER DATA
============================================================

INSERT INTO Customer
(Customer_ID, Customer_Name, Phone, Email, City)
VALUES
(101, 'Ravi Kumar', '9876543210',
 'ravi@gmail.com', 'Hyderabad'),

(102, 'Priya Sharma', '9876543211',
 'priya@gmail.com', 'Vijayawada'),

(103, 'Arjun Reddy', '9876543212',
 'arjun@gmail.com', 'Bangalore'),

(104, 'Sneha Rao', '9876543213',
 'sneha@gmail.com', 'Chennai'),

(105, 'Kiran Kumar', '9876543214',
 'kiran@gmail.com', 'Hyderabad'),

(106, 'Anil Kumar', '9876543215',
 'anil@gmail.com', 'Delhi'),

(107, 'Meena Reddy', '9876543216',
 'meena@gmail.com', 'Mumbai'),

(108, 'Rahul Sharma', '9876543217',
 'rahul@gmail.com', 'Pune'),

(109, 'Lakshmi Devi', '9876543218',
 'lakshmi@gmail.com', 'Hyderabad'),

(110, 'Suresh Babu', '9876543219',
 'suresh@gmail.com', 'Vijayawada');


============================================================
7. INSERT ACCOUNT DATA
============================================================

INSERT INTO Account
(Account_No, Customer_ID, Account_Type, Balance, Branch)
VALUES
(10001, 101, 'Savings', 50000, 'Hyderabad'),

(10002, 102, 'Savings', 75000, 'Vijayawada'),

(10003, 103, 'Current', 120000, 'Bangalore'),

(10004, 104, 'Savings', 45000, 'Chennai'),

(10005, 105, 'Current', 90000, 'Hyderabad'),

(10006, 106, 'Savings', 65000, 'Delhi'),

(10007, 107, 'Current', 150000, 'Mumbai'),

(10008, 108, 'Savings', 35000, 'Pune'),

(10009, 109, 'Savings', 85000, 'Hyderabad'),

(10010, 110, 'Current', 110000, 'Vijayawada');


============================================================
8. INSERT TRANSACTION DATA
============================================================

INSERT INTO Bank_Transaction
(Account_No, Transaction_Type, Amount)
VALUES
(10001, 'DEPOSIT', 10000),

(10001, 'WITHDRAW', 5000),

(10002, 'DEPOSIT', 15000),

(10003, 'WITHDRAW', 20000),

(10004, 'DEPOSIT', 5000),

(10005, 'WITHDRAW', 10000),

(10006, 'DEPOSIT', 12000),

(10007, 'DEPOSIT', 25000),

(10008, 'WITHDRAW', 5000),

(10009, 'DEPOSIT', 20000),

(10010, 'WITHDRAW', 15000);


============================================================
9. INSERT LOAN DATA
============================================================

INSERT INTO Loan
(Loan_ID, Customer_ID, Loan_Type,
 Loan_Amount, Interest_Rate)
VALUES
(501, 101, 'Home Loan', 5000000, 7.5),

(502, 102, 'Education Loan', 1000000, 6.5),

(503, 103, 'Car Loan', 800000, 8.2),

(504, 104, 'Personal Loan', 500000, 10.5),

(505, 105, 'Home Loan', 4000000, 7.2),

(506, 106, 'Car Loan', 900000, 8.5),

(507, 107, 'Business Loan', 3000000, 9.0),

(508, 109, 'Personal Loan', 600000, 10.0);


============================================================
10. DISPLAY ORIGINAL TABLES
============================================================

SELECT * FROM Customer;

SELECT * FROM Account;

SELECT * FROM Bank_Transaction;

SELECT * FROM Loan;


============================================================
              PART A – SIMPLE VIEWS
============================================================


------------------------------------------------------------
11. CREATE A VIEW FOR ALL CUSTOMERS
------------------------------------------------------------

CREATE VIEW Customer_View AS
SELECT *
FROM Customer;


DISPLAY VIEW:

SELECT * FROM Customer_View;


------------------------------------------------------------
12. CREATE A VIEW FOR CUSTOMER BASIC INFORMATION
------------------------------------------------------------

CREATE VIEW Customer_Basic_View AS
SELECT
    Customer_ID,
    Customer_Name,
    City
FROM Customer;


DISPLAY:

SELECT * FROM Customer_Basic_View;


------------------------------------------------------------
13. CREATE A VIEW FOR ACCOUNT INFORMATION
------------------------------------------------------------

CREATE VIEW Account_View AS
SELECT
    Account_No,
    Account_Type,
    Balance,
    Branch
FROM Account;


DISPLAY:

SELECT * FROM Account_View;


------------------------------------------------------------
14. CREATE A VIEW FOR SAVINGS ACCOUNTS
------------------------------------------------------------

CREATE VIEW Savings_Account_View AS
SELECT *
FROM Account
WHERE Account_Type = 'Savings';


DISPLAY:

SELECT * FROM Savings_Account_View;


------------------------------------------------------------
15. CREATE A VIEW FOR CURRENT ACCOUNTS
------------------------------------------------------------

CREATE VIEW Current_Account_View AS
SELECT *
FROM Account
WHERE Account_Type = 'Current';


DISPLAY:

SELECT * FROM Current_Account_View;


============================================================
              PART B – VIEWS WITH CONDITIONS
============================================================


------------------------------------------------------------
16. HIGH BALANCE ACCOUNT VIEW
------------------------------------------------------------

CREATE VIEW High_Balance_View AS
SELECT
    Account_No,
    Customer_ID,
    Account_Type,
    Balance
FROM Account
WHERE Balance > 100000;


DISPLAY:

SELECT * FROM High_Balance_View;


------------------------------------------------------------
17. HYDERABAD ACCOUNT VIEW
------------------------------------------------------------

CREATE VIEW Hyderabad_Account_View AS
SELECT *
FROM Account
WHERE Branch = 'Hyderabad';


DISPLAY:

SELECT * FROM Hyderabad_Account_View;


------------------------------------------------------------
18. LOW BALANCE ACCOUNT VIEW
------------------------------------------------------------

CREATE VIEW Low_Balance_View AS
SELECT
    Account_No,
    Customer_ID,
    Balance
FROM Account
WHERE Balance < 50000;


DISPLAY:

SELECT * FROM Low_Balance_View;


============================================================
              PART C – VIEWS USING JOINS
============================================================


------------------------------------------------------------
19. CUSTOMER + ACCOUNT VIEW
------------------------------------------------------------

CREATE VIEW Customer_Account_View AS
SELECT
    C.Customer_ID,
    C.Customer_Name,
    C.City,
    A.Account_No,
    A.Account_Type,
    A.Balance,
    A.Branch
FROM Customer C
JOIN Account A
ON C.Customer_ID = A.Customer_ID;


DISPLAY:

SELECT * FROM Customer_Account_View;


------------------------------------------------------------
20. HYDERABAD CUSTOMER ACCOUNT VIEW
------------------------------------------------------------

CREATE VIEW Hyderabad_Customer_Accounts AS
SELECT
    C.Customer_Name,
    C.City,
    A.Account_No,
    A.Account_Type,
    A.Balance
FROM Customer C
JOIN Account A
ON C.Customer_ID = A.Customer_ID
WHERE A.Branch = 'Hyderabad';


DISPLAY:

SELECT * FROM Hyderabad_Customer_Accounts;


------------------------------------------------------------
21. CUSTOMER LOAN VIEW
------------------------------------------------------------

CREATE VIEW Customer_Loan_View AS
SELECT
    C.Customer_ID,
    C.Customer_Name,
    C.City,
    L.Loan_ID,
    L.Loan_Type,
    L.Loan_Amount,
    L.Interest_Rate
FROM Customer C
JOIN Loan L
ON C.Customer_ID = L.Customer_ID;


DISPLAY:

SELECT * FROM Customer_Loan_View;


------------------------------------------------------------
22. COMPLETE CUSTOMER BANKING VIEW
------------------------------------------------------------

CREATE VIEW Customer_Banking_View AS
SELECT
    C.Customer_ID,
    C.Customer_Name,
    C.City,
    A.Account_No,
    A.Account_Type,
    A.Balance,
    A.Branch,
    L.Loan_Type,
    L.Loan_Amount
FROM Customer C
LEFT JOIN Account A
ON C.Customer_ID = A.Customer_ID
LEFT JOIN Loan L
ON C.Customer_ID = L.Customer_ID;


DISPLAY:

SELECT * FROM Customer_Banking_View;


============================================================
           PART D – VIEWS USING AGGREGATE FUNCTIONS
============================================================


------------------------------------------------------------
23. TOTAL BANK BALANCE
------------------------------------------------------------

CREATE VIEW Total_Bank_Balance AS
SELECT
    SUM(Balance) AS Total_Balance
FROM Account;


DISPLAY:

SELECT * FROM Total_Bank_Balance;


------------------------------------------------------------
24. AVERAGE ACCOUNT BALANCE
------------------------------------------------------------

CREATE VIEW Average_Account_Balance AS
SELECT
    AVG(Balance) AS Average_Balance
FROM Account;


DISPLAY:

SELECT * FROM Average_Account_Balance;


------------------------------------------------------------
25. MAXIMUM ACCOUNT BALANCE
------------------------------------------------------------

CREATE VIEW Maximum_Balance_View AS
SELECT
    MAX(Balance) AS Maximum_Balance
FROM Account;


DISPLAY:

SELECT * FROM Maximum_Balance_View;


------------------------------------------------------------
26. MINIMUM ACCOUNT BALANCE
------------------------------------------------------------

CREATE VIEW Minimum_Balance_View AS
SELECT
    MIN(Balance) AS Minimum_Balance
FROM Account;


DISPLAY:

SELECT * FROM Minimum_Balance_View;


------------------------------------------------------------
27. TOTAL NUMBER OF ACCOUNTS
------------------------------------------------------------

CREATE VIEW Account_Count_View AS
SELECT
    COUNT(*) AS Total_Accounts
FROM Account;


DISPLAY:

SELECT * FROM Account_Count_View;


============================================================
           PART E – GROUP BY VIEWS
============================================================


------------------------------------------------------------
28. BRANCH-WISE ACCOUNT COUNT
------------------------------------------------------------

CREATE VIEW Branch_Account_Count AS
SELECT
    Branch,
    COUNT(*) AS Number_of_Accounts
FROM Account
GROUP BY Branch;


DISPLAY:

SELECT * FROM Branch_Account_Count;


------------------------------------------------------------
29. BRANCH-WISE TOTAL BALANCE
------------------------------------------------------------

CREATE VIEW Branch_Total_Balance AS
SELECT
    Branch,
    SUM(Balance) AS Total_Balance
FROM Account
GROUP BY Branch;


DISPLAY:

SELECT * FROM Branch_Total_Balance;


------------------------------------------------------------
30. ACCOUNT TYPE COUNT
------------------------------------------------------------

CREATE VIEW Account_Type_Count AS
SELECT
    Account_Type,
    COUNT(*) AS Number_of_Accounts
FROM Account
GROUP BY Account_Type;


DISPLAY:

SELECT * FROM Account_Type_Count;


------------------------------------------------------------
31. ACCOUNT TYPE TOTAL BALANCE
------------------------------------------------------------

CREATE VIEW Account_Type_Balance AS
SELECT
    Account_Type,
    SUM(Balance) AS Total_Balance
FROM Account
GROUP BY Account_Type;


DISPLAY:

SELECT * FROM Account_Type_Balance;


============================================================
              PART F – HAVING IN VIEWS
============================================================


------------------------------------------------------------
32. BRANCHES WITH MORE THAN ONE ACCOUNT
------------------------------------------------------------

CREATE VIEW Multiple_Account_Branches AS
SELECT
    Branch,
    COUNT(*) AS Number_of_Accounts
FROM Account
GROUP BY Branch
HAVING COUNT(*) > 1;


DISPLAY:

SELECT * FROM Multiple_Account_Branches;


------------------------------------------------------------
33. BRANCHES WITH TOTAL BALANCE ABOVE 100000
------------------------------------------------------------

CREATE VIEW Rich_Branches AS
SELECT
    Branch,
    SUM(Balance) AS Total_Balance
FROM Account
GROUP BY Branch
HAVING SUM(Balance) > 100000;


DISPLAY:

SELECT * FROM Rich_Branches;


============================================================
              PART G – TRANSACTION VIEWS
============================================================


------------------------------------------------------------
34. DEPOSIT TRANSACTION VIEW
------------------------------------------------------------

CREATE VIEW Deposit_Transaction_View AS
SELECT *
FROM Bank_Transaction
WHERE Transaction_Type = 'DEPOSIT';


DISPLAY:

SELECT * FROM Deposit_Transaction_View;


------------------------------------------------------------
35. WITHDRAWAL TRANSACTION VIEW
------------------------------------------------------------

CREATE VIEW Withdrawal_Transaction_View AS
SELECT *
FROM Bank_Transaction
WHERE Transaction_Type = 'WITHDRAW';


DISPLAY:

SELECT * FROM Withdrawal_Transaction_View;


------------------------------------------------------------
36. TRANSACTION DETAILS WITH CUSTOMER
------------------------------------------------------------

CREATE VIEW Customer_Transaction_View AS
SELECT
    C.Customer_Name,
    A.Account_No,
    A.Account_Type,
    T.Transaction_ID,
    T.Transaction_Type,
    T.Amount,
    T.Transaction_Date
FROM Customer C
JOIN Account A
ON C.Customer_ID = A.Customer_ID
JOIN Bank_Transaction T
ON A.Account_No = T.Account_No;


DISPLAY:

SELECT * FROM Customer_Transaction_View;


------------------------------------------------------------
37. HIGH VALUE TRANSACTION VIEW
------------------------------------------------------------

CREATE VIEW High_Value_Transaction_View AS
SELECT *
FROM Bank_Transaction
WHERE Amount > 10000;


DISPLAY:

SELECT * FROM High_Value_Transaction_View;


============================================================
              PART H – VIEWS WITH ORDER BY
============================================================


------------------------------------------------------------
38. ACCOUNTS ORDERED BY BALANCE
------------------------------------------------------------

CREATE VIEW Balance_Ranking_View AS
SELECT
    Account_No,
    Customer_ID,
    Account_Type,
    Balance
FROM Account
ORDER BY Balance DESC;


DISPLAY:

SELECT * FROM Balance_Ranking_View;


------------------------------------------------------------
39. CUSTOMERS ORDERED BY NAME
------------------------------------------------------------

CREATE VIEW Customer_Name_View AS
SELECT
    Customer_ID,
    Customer_Name,
    City
FROM Customer
ORDER BY Customer_Name;


DISPLAY:

SELECT * FROM Customer_Name_View;


============================================================
              PART I – VIEW WITH CALCULATED COLUMN
============================================================


------------------------------------------------------------
40. LOAN INTEREST CALCULATION VIEW
------------------------------------------------------------

CREATE VIEW Loan_Interest_View AS
SELECT
    Loan_ID,
    Customer_ID,
    Loan_Type,
    Loan_Amount,
    Interest_Rate,
    (Loan_Amount * Interest_Rate / 100)
        AS Annual_Interest
FROM Loan;


DISPLAY:

SELECT * FROM Loan_Interest_View;


------------------------------------------------------------
41. LOAN TOTAL AMOUNT VIEW
------------------------------------------------------------

CREATE VIEW Loan_Total_Amount_View AS
SELECT
    Loan_ID,
    Customer_ID,
    Loan_Type,
    Loan_Amount,
    Interest_Rate,
    Loan_Amount +
    (Loan_Amount * Interest_Rate / 100)
    AS Total_Amount
FROM Loan;


DISPLAY:

SELECT * FROM Loan_Total_Amount_View;


============================================================
              PART J – USING VIEW WITH QUERIES
============================================================


42. DISPLAY HIGH BALANCE ACCOUNTS FROM VIEW

SELECT *
FROM High_Balance_View
WHERE Balance > 120000;


------------------------------------------------------------

43. DISPLAY SAVINGS ACCOUNTS ABOVE 60000

SELECT *
FROM Savings_Account_View
WHERE Balance > 60000;


------------------------------------------------------------

44. DISPLAY HYDERABAD ACCOUNTS ABOVE 50000

SELECT *
FROM Hyderabad_Account_View
WHERE Balance > 50000;


------------------------------------------------------------

45. DISPLAY CUSTOMERS FROM HYDERABAD

SELECT *
FROM Customer_Basic_View
WHERE City = 'Hyderabad';


------------------------------------------------------------

46. DISPLAY CUSTOMER ACCOUNTS ORDERED BY BALANCE

SELECT *
FROM Customer_Account_View
ORDER BY Balance DESC;


------------------------------------------------------------

47. DISPLAY LOANS ABOVE 1000000

SELECT *
FROM Customer_Loan_View
WHERE Loan_Amount > 1000000;


============================================================
              PART K – UPDATING A VIEW
============================================================


48. UPDATE ACCOUNT BALANCE THROUGH VIEW

UPDATE Account_View
SET Balance = 60000
WHERE Account_No = 10001;


CHECK:

SELECT *
FROM Account
WHERE Account_No = 10001;


NOTE:

Not every view is updatable.

Views containing:
- GROUP BY
- Aggregate functions
- DISTINCT
- UNION
- Certain JOIN operations

may not be directly updatable.


============================================================
              PART L – INSERT THROUGH VIEW
============================================================


49. INSERT USING SIMPLE VIEW

CREATE VIEW Simple_Account_View AS
SELECT
    Account_No,
    Customer_ID,
    Account_Type,
    Balance,
    Branch
FROM Account;


INSERT INTO Simple_Account_View
VALUES
(10011, 101, 'Savings', 55000, 'Hyderabad');


CHECK:

SELECT *
FROM Account;


NOTE:

INSERT through a view is possible only when the view satisfies
the database system's rules for updatable views.


============================================================
              PART M – DELETE THROUGH VIEW
============================================================


50. DELETE USING SIMPLE VIEW

DELETE FROM Simple_Account_View
WHERE Account_No = 10011;


CHECK:

SELECT *
FROM Account;


============================================================
              PART N – VIEW INFORMATION
============================================================


51. SHOW ALL VIEWS

SHOW FULL TABLES
WHERE TABLE_TYPE = 'VIEW';


------------------------------------------------------------

52. SHOW VIEW DEFINITION

SHOW CREATE VIEW Customer_Account_View;


------------------------------------------------------------

53. DESCRIBE VIEW

DESCRIBE Customer_Account_View;


============================================================
              PART O – DROP VIEWS
============================================================


54. DROP ONE VIEW

DROP VIEW Customer_View;


------------------------------------------------------------

55. DROP MULTIPLE VIEWS

DROP VIEW
Customer_Basic_View,
Savings_Account_View,
Current_Account_View;