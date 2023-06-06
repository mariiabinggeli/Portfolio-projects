/*
Cleaning data in SQL Queries
*/
SELECT*
FROM CleaningDataPP.dbo.Sheet1$

--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM CleaningDataPP.dbo.Sheet1$

Update Sheet1$
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

SELECT*
FROM CleaningDataPP.dbo.Sheet1$
--WHERE PropertyAddress is Null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CleaningDataPP.dbo.Sheet1$ a
JOIN CleaningDataPP.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM CleaningDataPP.dbo.Sheet1$ a
JOIN CleaningDataPP.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM CleaningDataPP.dbo.Sheet1$
--WHERE PropertyAddress is Null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) as Address

FROM CleaningDataPP.dbo.Sheet1$

ALTER TABLE Sheet1$
ADD PropertySplitAddress Nvarchar(255);

Update Sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Sheet1$
ADD PropertySplitAddress Nvarchar(255);

Update Sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))

SELECT*
FROM CleaningDataPP.dbo.Sheet1$

--new columns are at the end of the table

-- a different way to breaking the address into different project

SELECT OwnerAddress
FROM CleaningDataPP.dbo.Sheet1$

--- three columns for street, town and state
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From CleaningDataPP.dbo.Sheet1$

ALTER TABLE Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Sheet1$
Add OwnerSplitState Nvarchar(255);

Update Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From CleaningDataPP.dbo.Sheet1$

--- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
From CleaningDataPP.dbo.Sheet1$
Group by SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From CleaningDataPP.dbo.Sheet1$

Update Sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


---Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
	             SalePrice,
	             SaleDate,
	             LegalReference
	             ORDER BY 
					UniqueID
					) row_num

From CleaningDataPP.dbo.Sheet1$
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- to check the result
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
---

--Delete Unused Columns

SELECT*
FROM CleaningDataPP.dbo.Sheet1$

ALTER TABLE CleaningDataPP.dbo.Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE CleaningDataPP.dbo.Sheet1$
DROP COLUMN SaleDate

