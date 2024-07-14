CREATE TABLE Person (
  PersonID INT,
  Name VARCHAR(255),
  Family VARCHAR(255)
);
CREATE UNIQUE INDEX IX_Name_Family ON Person (Name, Family);


INSERT INTO Person (PersonID, Name, Family)
VALUES
(1, 'Jane', 'Parker'),
(2, 'Mike', 'Copper');


CREATE TABLE Transactions (
  TransactionId INT,
  PersonId INT,
  TransactionDate DATETIME,
  Price FLOAT,
  CONSTRAINT CHK_PriceGreaterThanZero CHECK (Price > 0)
);


INSERT INTO Transactions (TransactionID, PersonID, TransactionDate, Price)
VALUES
(1, 1, '2019-11-01 12:30', 100000),
(2, 1, '2019-11-01 16:30', 200000),
(3, 1, '2019-11-01 18:30', 50000),
(4, 1, '2019-11-03 09:30', 300000),
(5, 2, '2019-11-01 14:30', 100000),
(6, 2, '2019-11-01 12:30', 20000);



WITH SumOfEachDayByPerson as
(
SELECT
       PersonId,
       CAST(TransactionDate AS DATE) TransactionDate,
       SUM(Price) SumOfDay
	   FROM dbo.Transactions
	   GROUP BY CAST(TransactionDate AS DATE),
                PersonId
),SumWithRunningTotal AS (
SELECT *, SUM(SumOfDay) OVER(PARTITION BY PersonId ORDER BY TransactionDate) Total 
FROM SumOfEachDayByPerson
)
,TransactionWithTotalAndDate AS 
(
SELECT SumWithRunningTotal.PersonId,
       SumWithRunningTotal.TransactionDate,
	   LEAD(SumWithRunningTotal.TransactionDate,1,NULL) 
		OVER(PARTITION BY SumWithRunningTotal.PersonId 
		ORDER BY SumWithRunningTotal.TransactionDate) EndDate,
	   MAX(SumWithRunningTotal.TransactionDate) 
		OVER(PARTITION BY SumWithRunningTotal.PersonId 
		ORDER BY SumWithRunningTotal.TransactionDate ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING) EndDate2,
       SumWithRunningTotal.SumOfDay,
       SumWithRunningTotal.Total FROM SumWithRunningTotal
)


SELECT Name,Family,TransactionWithTotalAndDate.* 
FROM dbo.Person 
	INNER JOIN TransactionWithTotalAndDate ON TransactionWithTotalAndDate.PersonId = Person.PersonID