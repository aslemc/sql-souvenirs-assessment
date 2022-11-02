-- To create the Souvenir Tracking database
USE master
GO
DROP DATABASE IF EXISTS SouvenirTracking
GO
CREATE DATABASE SouvenirTracking
GO
USE SouvenirTracking
GO

 -- `use master` first or the existing connection will tie up FieldAgent.
/*use master;
-- close client connections
ALTER DATABASE SouvenirTracking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- drop the database
drop database SouvenirTracking;*/

-- To create the Owner table
CREATE TABLE [Owner](
    OwnerID INT PRIMARY KEY IDENTITY(1,1),
    OwnerName VARCHAR(7) NOT NULL UNIQUE
);

-- To create the Location table
CREATE TABLE [Location](
    LocationID INT PRIMARY KEY IDENTITY(1,1),
    City VARCHAR(30) NULL,
    Region VARCHAR(30) NULL,
    Country VARCHAR(30) NULL,
    Longitude DECIMAL(10,4) NULL,
    Latitude DECIMAL(10,4) NULL,
);

-- To create the Category table
CREATE TABLE Category(
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(20) UNIQUE
);

--To create the Souvenir table
CREATE TABLE Souvenir(
    SouvenirID INT PRIMARY KEY IDENTITY (1,1),
    SouvenirName VARCHAR(75) NOT NULL,
    [Description] VARCHAR(130) NULL,
    Price DECIMAL(9,2) NOT NULL,
    [Weight] DECIMAL(7,2) NULL,
    DateObtained DATETIME2 NOT NULL,
    OwnerID INT NOT NULL,
    LocationID INT NOT NULL,
    CategoryID INT NOT NULL,
    CONSTRAINT fk_OwnerID
        FOREIGN KEY(OwnerID)
        REFERENCES [Owner](OwnerID),
    CONSTRAINT fk_LocationID
        FOREIGN KEY(LocationID)
        REFERENCES Location(LocationID),
    CONSTRAINT fk_Category
        FOREIGN KEY(CategoryID)
        REFERENCES Category(CategoryID),
    CONSTRAINT uq_SouvenirName_Date
        unique (SouvenirName, [Description])
);