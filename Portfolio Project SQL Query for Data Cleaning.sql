/*
CLEANING DATA IN SQL(WITH SQL QUERIES
*/

--VIEWING THE FULL DATA FIRST

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousingData

-- STANDARDIZING DATE FORMAT

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousingData

--POPULATE THE EMPTY PROPERTY ADDRESS FIELDS

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID --some entries have the same parcelid and same address so we want to populate the same address for entries with the same parcelid.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousingData a
JOIN PortfolioProject1.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousingData a
JOIN PortfolioProject1.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--SELECT
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address
--FROM PortfolioProject1.dbo.NashvilleHousingData

--UPDATE NashvilleHousingData
--SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address

--SELECT PropertyAddress
--FROM PortfolioProject1.dbo.NashvilleHousingData

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousingData
--WE WORKED ON PROPERTYADDRESS ABOVE, WE WANT TO WORK ON OWNERADDRESS BELOW.

SELECT OwnerAddress
FROM PortfolioProject1.dbo.NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject1.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousingData

--WE MOVE ON TO CHANGING Y AND N TO 'YES' AND 'NO' IN SOLDASVACANT DATA FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject1.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2
-- WE ARE GOING TO ATTEMPT A CASE STATEMENT FOR THIS
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVAcant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject1.dbo.NashvilleHousingData
--I TESTED WITH ADDING THE BELOW TO SEE IF IT WORKED BEFORE UPDATING THE TABLE
--GROUP BY SoldAsVacant
--ORDER BY 2
UPDATE PortfolioProject1.dbo.NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVAcant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

/*
WE MOVE ON TO REMOVING DUPLICATES FROM OUR DATA
*/

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				 ORDER BY UniqueID) row_num
FROM PortfolioProject1.dbo.NashvilleHousingData
)
/*DELETE
FROM RowNumCTE
WHERE row_num > 1
*/

SELECT *
FROM RowNumCTE
WHERE row_num > 1


/*
NOW WE  DELETE SOME UNUSED COLUMNS....PS. THIS IS JUST FOR PRACTICE, NEVER DELETE ANY RAW DATA FROM YOUR DATABASE
*/

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousingData

