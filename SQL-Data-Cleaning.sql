/*
Cleaning Data in SQL Queries
*/

SELECT *
	FROM PortfolioProject..NashvilleHousing


--------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, 
       CONVERT(Date, SaleDate)
	FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
	SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
	ADD SaleDateConverted Date

UPDATE NashvilleHousing
	SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Initially spelled the column name wrong that was adding as SaleDataConverted, so going to remove that column.

ALTER TABLE NashvilleHousing
	DROP COLUMN SaleDataConverted


--------------------------------------------------

-- Standardize Acreage

SELECT Acreage,
	   CAST(Acreage AS Decimal(5, 2))
	   FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
	SET Acreage = CAST(Acreage AS Decimal(5, 2))

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
	ADD AcreageConverted Decimal(5,2)

UPDATE NashvilleHousing
	SET AcreageConverted = CAST(Acreage AS Decimal(5, 2))


--------------------------------------------------

-- Populate Property Address data

SELECT *
	FROM PortfolioProject..NashvilleHousing
	--WHERE PropertyAddress is null
	ORDER BY ParcelID

SELECT a.ParcelID, 
       a.PropertyAddress, 
	   b.ParcelID, 
	   b.PropertyAddress, 
	   ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL


--------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- First up the Property Address, using Substrings

SELECT PropertyAddress
	FROM PortfolioProject..NashvilleHousing
	--WHERE PropertyAddress is null
	--ORDER BY ParcelID

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
	FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
	ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
	FROM PortfolioProject..NashvilleHousing

-- Next Up the Owner Address, using Parse Name instead of Substrings
,
SELECT OwnerAddress
	FROM PortfolioProject..NashvilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
	FROM PortfolioProject..NashvilleHousing


--------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), 
       COUNT(SoldAsVacant)
	FROM PortfolioProject..NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	     WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
	FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
	SET SoldAsVacant = 
		CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	    WHEN SoldAsVacant = 'N' THEN 'NO'
	    ELSE SoldAsVacant
	    END


--------------------------------------------------

-- Remove Duplicates - Not standard to remove data from a table, put practicing the action of.
-- Using a CTE. Can't use Order By within one.

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY ParcelID 
			 ) row_num
FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID
)
DELETE
	FROM RowNumCTE
	WHERE row_num > 1
	--ORDER BY PropertyAddress


--------------------------------------------------

-- Delete Unused Columns. You don't do this to raw data that you put into your database.
-- Again, just the practice of doing so.

SELECT *
	FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress, SaleDate

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN Acreage