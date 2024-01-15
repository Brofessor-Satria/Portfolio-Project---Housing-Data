/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM HousingData
ORDER BY ParcelID

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

UPDATE HousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE HousingData
ADD Sale_Date Date;

UPDATE HousingData
SET Sale_Date = CONVERT(Date, SaleDate)
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingData a
JOIN HousingData b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null


--Where PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData a
JOIN HousingData b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



SELECT *
FROM HousingData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM HousingData

ALTER TABLE HousingData
ADD Property_Split_Address varchar(255);

UPDATE HousingData
SET  Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE HousingData
ADD Property_Split_City varchar(255);

UPDATE HousingData
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Owners Address
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM HousingData

ALTER TABLE HousingData
ADD Owners_Split_Address varchar(255),
Owners_Split_City varchar(255),
Owners_Split_State varchar(255)

UPDATE HousingData
SET  Owners_Split_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
Owners_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
Owners_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

ALTER TABLE HousingData
ADD Owners_Split_City varchar(255);

UPDATE HousingData
SET  Owners_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE HousingData
ADD Owners_Split_State varchar(255);

UPDATE HousingData
SET  Owners_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM HousingData

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM HousingData
GROUP BY SoldAsVacant

UPDATE HousingData
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH ROW_COUNTER AS(
Select *, 
ROW_NUMBER() OVER(
PARTITION BY 
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference,
	OwnerName,
	OwnerAddress,
	Acreage 
	ORDER BY UniqueID)
	AS Row_Count
	FROM HousingData)
SELECT *
FROM ROW_COUNTER
WHERE Row_Count>1

ALTER TABLE HousingData
SET

XXXXXXX
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From HousingData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















