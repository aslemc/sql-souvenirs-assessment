USE SouvenirTracking
GO

-- adding the distinct group names from the owner name into the owner table
INSERT INTO [Owner](OwnerName)
    SELECT DISTINCT [Owner] 
    FROM TempSouvenirs


-- adding the 11 distinct categories into the category table
INSERT INTO Category(CategoryName)
    SELECT DISTINCT Category
    FROM TempSouvenirs


-- populating the location table with city, region, country, longitude, and latitude values 
INSERT INTO [Location](City, Region, Country, Longitude, Latitude)
    SELECT DISTINCT City, Region, Country, Longitude, Latitude
    FROM TempSouvenirs


-- populating the souvenir table with the data
INSERT INTO Souvenir(SouvenirName, [Description], Price, [Weight], DateObtained, OwnerID, LocationID, CategoryID)
    SELECT DISTINCT [Souvenir_Name], [Souvenir_Description], Price, [Weight], DateObtained, OwnerID, 
    CASE WHEN (L.City IS NULL AND L.Latitude IS NULL) THEN 1
        ELSE LocationID
        END, 
    CategoryID
        FROM TempSouvenirs TS
    INNER JOIN [Owner] O ON O.OwnerName = TS.[Owner]
    LEFT JOIN [Location] L ON 
        L.City = TS.City 
        OR L.Latitude = TS.Latitude
    INNER JOIN Category C ON C.CategoryName = TS.Category


-- Completing updates & deletions

-- Creating a new category for video games & assigning video games to that category
INSERT INTO Category(CategoryName)
    VALUES('Video Game')

DECLARE @VGCat INT
SELECT @VGCat = CategoryID FROM Category WHERE CategoryName LIKE 'Video Game'

UPDATE Souvenir SET
    CategoryID = @VGCat
WHERE [Description] LIKE 'Video game%'


-- Moving jewelry boxes to the category miscellaneous
DECLARE @MCat INT
SELECT @MCat = CategoryID FROM Category WHERE CategoryName LIKE 'Miscellaneous'

UPDATE Souvenir SET
    CategoryID = @MCat
WHERE SouvenirName LIKE '%Jewelry Box'


-- Recategorizing three miscellaneous objects as musical instruments
INSERT INTO Category(CategoryName)
    VALUES('Musical Instrument')

DECLARE @MICat INT
SELECT @MICat = CategoryID FROM Category WHERE CategoryName LIKE 'Musical Instrument'

UPDATE Souvenir SET
    CategoryID = @MICat
WHERE SouvenirName IN ('Shamisen', 'Egyptian Drum', 'Zuffolo')


-- Deleting the heaviest souvenir
DELETE FROM Souvenir
WHERE [Weight] IN 
    (SELECT MAX([Weight]) FROM Souvenir)

 
-- Deleting all souvenirs that are dirt or sand
DELETE FROM Souvenir
WHERE SouvenirName LIKE '%dirt' OR SouvenirName LIKE '%sand'