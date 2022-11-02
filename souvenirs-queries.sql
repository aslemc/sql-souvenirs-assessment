USE SouvenirTracking
GO

-- Three most inexpensive souvenirs
SELECT TOP 3 SouvenirName, Price 
FROM Souvenir
ORDER BY Price


-- Seven most expensive souvenirs
SELECT TOP 7 SouvenirName, Price
FROM Souvenir
ORDER BY Price DESC


-- All mugs, ordered from heaviest to lightest
SELECT SouvenirName, [Weight]
FROM Souvenir
WHERE SouvenirName LIKE '%mug%'
ORDER BY [Weight] DESC


-- Count the number of spoons in the collection 
SELECT COUNT(SouvenirName) NumberOfSpoons
FROM Souvenir
WHERE SouvenirName LIKE '%spoon%'


-- Find the average weight, minimum weight, and maximum weight for each category by name.
SELECT CategoryName, AVG([Weight]) AS AverageWeight, MIN([Weight]) AS MinimumWeight, MAX([Weight]) AS MaximumWeight
FROM Category C
JOIN Souvenir S ON S.CategoryID = C.CategoryID
GROUP BY CategoryName


-- List all kitchenware souvenirs and their general location fields without duplication. 
-- The "without duplication" is confusing to me as it's unclear whether I ought to avoid duplicating the category, the souvenir, or the location
SELECT STRING_AGG(SouvenirName,', ') AS Souvenirs, City, Region, Country, Longitude, Latitude
FROM Souvenir S
JOIN Category C ON C.CategoryID = S.CategoryID
JOIN [Location] L ON L.LocationID = S.LocationID 
WHERE CategoryName LIKE 'Kitchenware'
GROUP BY City, Region, Country, Longitude, Latitude


-- Find the earliest and latest obtained date for each owner
SELECT OwnerName, MIN(DateObtained) AS EarliestDateObtained, MAX(DateObtained) AS LatestDateObtained
FROM [Owner] O
JOIN Souvenir S ON S.OwnerID = O.OwnerID
GROUP BY OwnerName
ORDER BY MIN(DateObtained) 


-- What is the most popular date for the souvenirs? Store this in a variable & display all souvenirs purchased on this date.
-- Declaring the variable @PopularDate and storing the most popular date in it
DECLARE @PopularDate DATETIME2
SELECT @PopularDate = (SELECT TOP 1 DateObtained
    FROM Souvenir
    GROUP BY DateObtained
    ORDER BY COUNT(DateObtained) DESC)

-- Finding all souvenirs purchased on the date stored in @PopularDate
SELECT SouvenirName, @PopularDate AS DateObtained 
FROM Souvenir
WHERE DateObtained = @PopularDate


-- Find all souvenirs that do not have a latitude and longitude.
SELECT SouvenirName, Latitude, Longitude
FROM Souvenir S
LEFT JOIN [Location] L ON L.LocationID = S.LocationID
WHERE Latitude IS NULL 
    AND Longitude IS NULL
ORDER BY SouvenirName


-- Find all souvenirs that do not have a city, region, and country.
SELECT SouvenirName, City, Region, Country
FROM Souvenir S
FULL JOIN [Location] L ON L.LocationID = S.LocationID
WHERE City IS NULL
    AND Region IS NULL
    AND Country IS NULL
ORDER BY SouvenirName


-- Find all souvenirs heavier than the average weight for all souvenirs. Use a subquery in the WHERE clause to achieve this.
SELECT SouvenirName, City, Region, Country, Latitude, Longitude, [Weight]
FROM Souvenir S
JOIN [Location] L ON 
    L.LocationID = S.LocationID 
    OR S.LocationID IS NULL
WHERE [Weight] >
    (SELECT AVG([Weight]) FROM Souvenir)


-- Find the most expensive and least expensive souvenir in each category
-- listing the most expensive price and least expensive price in each category 
SELECT DISTINCT CategoryName, Max([Price]) AS MostExpensivePrice, Min(Price) AS LeastExpensivePrice
FROM Souvenir S 
JOIN Category C ON C.CategoryID = S.CategoryID
GROUP BY CategoryName
ORDER BY CategoryName


-- most and least expensive prices per category with the items
SELECT C.CategoryName, 
    STRING_AGG(S.SouvenirName,' ,') AS MostExpensiveSouvenir, 
    S.Price AS GreatestPrice, 
    LeastExpensive.LeastExpensiveSouvenir AS LeastExpensiveSouvenir, 
    LeastExpensive.Price AS LowestPrice
FROM Souvenir S
JOIN Category C ON C.CategoryID = S.CategoryID
JOIN 
-- using a subquery to find the minimum price per category and join it to the main select statement
    (SELECT DISTINCT CategoryID, MAX(Price) AS MostExpensive
        FROM Souvenir
        GROUP BY CategoryID) ExpensiveSouvenir
    ON ExpensiveSouvenir.CategoryID = S.CategoryID
    AND ExpensiveSouvenir.MostExpensive = S.Price
JOIN -- making a table with the least expensive price/souvenir via a subquery 
    (SELECT CategoryName, STRING_AGG(SouvenirName,' ,') AS LeastExpensiveSouvenir, Price
    FROM Souvenir S
    JOIN 
    -- using a subquery to find the minimum price per category and join it to the main select statement
        (SELECT DISTINCT CategoryID, MIN(Price) AS LeastExpensive
        FROM Souvenir
        GROUP BY CategoryID) CheapSouvenir
    ON CheapSouvenir.CategoryID = S.CategoryID
    AND CheapSouvenir.LeastExpensive = S.Price
    JOIN Category C ON C.CategoryID = S.CategoryID
    GROUP BY CategoryName, Price
    ) LeastExpensive
ON LeastExpensive.CategoryName = c.CategoryName
GROUP BY C.CategoryName, S.Price, LeastExpensive.LeastExpensiveSouvenir, LeastExpensive.Price
ORDER BY C.CategoryName