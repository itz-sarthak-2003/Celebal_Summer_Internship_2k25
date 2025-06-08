USE AdventureWorks2019;
GO

/*List of all customers*/

SELECT * 
FROM Sales.Customer;


/* list of all customers where company name ending in N*/

SELECT c.CustomerID, s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';


/*list of all customers who live in Berlin or London*/

SELECT DISTINCT p.FirstName, p.LastName, a.City
FROM Person.Person p
JOIN Sales.Customer c ON p.BusinessEntityID = c.PersonID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');



/* list of all customers who live in UK or USA */

SELECT DISTINCT p.FirstName, p.LastName, cr.Name AS Country
FROM Person.Person p
JOIN Sales.Customer c ON p.BusinessEntityID = c.PersonID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE sp.CountryRegionCode IN ('GB', 'US');


/* list of all products sorted by product name*/

SELECT Name 
FROM Production.Product 
ORDER BY Name;


/* list of all products where product name starts with an A*/ 

SELECT * 
FROM Production.Product 
WHERE Name LIKE 'A%';


/*List of customers who ever placed an order*/

SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;


/*list of Customers who live in London and have bought chai*/

SELECT DISTINCT p.FirstName, p.LastName, a.City, pr.Name AS Product
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City = 'London' AND pr.Name LIKE '%chai%';


/* List of customers who never place an orde*/

SELECT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID NOT IN (
SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader
);


/*List of customers who ordered Tofu*/

SELECT DISTINCT c.CustomerID, p.FirstName + ' ' + p.LastName AS CustomerName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product prod ON sod.ProductID = prod.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE prod.Name = 'Tofu'; 


/*Details of first order of the system*/

SELECT TOP 1 * 
FROM Sales.SalesOrderHeader 
ORDER BY OrderDate ASC;


/* Find the details of most expensive order date*/

SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;


/*For each order get the OrderID and Average quantity of items in that order*/

SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


/* For each order get the orderiD, minimum quantity and maximum quantity for that order*/

SELECT SalesOrderID,
MIN(OrderQty) AS MinQuantity,
MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


/*Get a list of all managers and total number of employees who report to them*/

SELECT Manager.BusinessEntityID AS ManagerID,
p.FirstName + ' ' + p.LastName AS ManagerName,
COUNT(E.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee E
JOIN HumanResources.Employee Manager
ON E.OrganizationNode.GetAncestor(1) = Manager.OrganizationNode
JOIN Person.Person p ON Manager.BusinessEntityID = p.BusinessEntityID
GROUP BY Manager.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(E.BusinessEntityID) > 0;


/*Get the OrderID and the total quantity for each order that has a total quantity of greater than 300*/

SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;



/* list of all orders placed on or after 1996/12/31*/

SELECT * 
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';


/*list of all orders shipped to Canada*/

SELECT soh.SalesOrderID, a.City, a.PostalCode, cr.Name AS Country
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';


/*list of all orders with order total > 200*/

SELECT SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;


/*List of countries and sales made in each country*/

SELECT cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;



/*List of Customer Contact Name and number of orders they placed*/

SELECT p.FirstName + ' ' + p.LastName AS ContactName,
COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName;


/*List of customer contactnames who have placed more than 3 orders*/

SELECT p.FirstName + ' ' + p.LastName AS ContactName,
COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3;


/* List of discontinued products which were ordered between 1/1/1997 and 1/1/1998*/

SELECT DISTINCT p.ProductID, p.Name AS ProductName
FROM Production.Product p
JOIN Sales.SalesOrderDetail od ON p.ProductID = od.ProductID
JOIN Sales.SalesOrderHeader o ON od.SalesOrderID = o.SalesOrderID
WHERE p.SellEndDate IS NOT NULL
AND o.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';


/*List of employee firsname, lastName, superviser FirstName, LastName*/

SELECT 
e1.BusinessEntityID AS EmployeeID,
p1.FirstName AS EmployeeFirstName,
p1.LastName AS EmployeeLastName,
p2.FirstName AS SupervisorFirstName,
p2.LastName AS SupervisorLastName
FROM HumanResources.Employee e1
JOIN HumanResources.Employee e2 ON e1.OrganizationNode.GetAncestor(1) = e2.OrganizationNode
JOIN Person.Person p1 ON e1.BusinessEntityID = p1.BusinessEntityID
JOIN Person.Person p2 ON e2.BusinessEntityID = p2.BusinessEntityID;


/* List of Employees id and total sale condcuted by employee*/

SELECT SalesPersonID AS EmployeeID, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID;


/* list of employees whose FirstName contains character a*/

SELECT p.FirstName, p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';


/*. List of managers who have more than four people reporting to them.*/

SELECT Manager.BusinessEntityID AS ManagerID,
       COUNT(E.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee E
JOIN HumanResources.Employee Manager
ON E.OrganizationNode.GetAncestor(1) = Manager.OrganizationNode
GROUP BY Manager.BusinessEntityID
HAVING COUNT(E.BusinessEntityID) > 4;


/*List of Orders and ProductNames*/

SELECT sod.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID;


/*List of orders place by the best customer*/

SELECT TOP 1 soh.CustomerID, COUNT(*) AS TotalOrders
INTO #BestCustomer
FROM Sales.SalesOrderHeader soh
GROUP BY soh.CustomerID
ORDER BY COUNT(*) DESC;
SELECT soh.SalesOrderID, soh.OrderDate
FROM Sales.SalesOrderHeader soh
JOIN #BestCustomer bc ON soh.CustomerID = bc.CustomerID;


/* List of orders placed by customers who do not have a Fax number
*/

SELECT soh.SalesOrderID, p.FirstName, p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID NOT IN (
SELECT BusinessEntityID FROM Person.PersonPhone WHERE PhoneNumberTypeID = 3
);


/* List of Postal codes where the product Tofu was shipped*/

SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name LIKE '%Tofu%';


/* List of product Names that were shipped to France*/

SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';


/* List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.*/

SELECT p.Name, pc.Name AS Category
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';


/*List of products that were never ordered*/

SELECT p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail
);


/*List of products where units in stock is less than 10 and units on order are 0.*/

SELECT Name
FROM Production.Product
WHERE SafetyStockLevel < 10 AND ReorderPoint = 0;



/*Number of orders each employee has taken for customers with CustomerIDs between A and AO*/

SELECT 
e.BusinessEntityID AS EmployeeID,
p.FirstName + ' ' + p.LastName AS EmployeeName,
COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE c.AccountNumber BETWEEN 'A' AND 'AO'
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName;


/*List of top 10 countries by sales*/

SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;


/*Orderdate of most expensive order*/

SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;


/*Product name and total revenue from that product*/

SELECT p.Name AS ProductName, SUM(LineTotal) AS Revenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY Revenue DESC;


/*Supplierid and number of products offered*/

SELECT p.Name AS ProductName, SUM(LineTotal) AS Revenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY Revenue DESC;


/* Top ten customers based on their business
*/

SELECT BusinessEntityID AS SupplierID, COUNT(ProductID) AS ProductCount
FROM Purchasing.ProductVendor
GROUP BY BusinessEntityID;


 /*What is the total revenue of the company.*/

SELECT TOP 10 soh.CustomerID, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.SalesOrderHeader soh
GROUP BY soh.CustomerID
ORDER BY TotalSpent DESC;
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;



