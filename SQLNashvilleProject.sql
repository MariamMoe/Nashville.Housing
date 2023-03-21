-- Cleaning data queries


SELECT *
FROM [portfolio project].[dbo].[Nashville.Housing]


-- Removing the timestamps on the SaleDate column



ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
ADD SaleDateNew Date


UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET SaleDateNew = CONVERT(Date,SaleDate)


-- cleaning the property address column getting rid of the NULLs
-- realizing that the ParcelID and the PropertyAddress have a relation we can self join the table to see if we can fill all the NULLs
-- AT THE SAME TIME UniqueID should stay unique to each row
SELECT *
FROM [portfolio project].[dbo].[Nashville.Housing]
WHERE PropertyAddress IS NULL

SELECT T1.ParcelID, T2.ParcelID, T1.Propertyaddress, T2.PropertyAddress, ISNULL (T1.PropertyAddress, T2.PropertyAddress)
FROM [portfolio project].[dbo].[Nashville.Housing] T1
JOIN [portfolio project].[dbo].[Nashville.Housing] T2
ON T1.ParcelID = T2.ParcelID
AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress is null

UPDATE T1
SET PropertyAddress = ISNULL (T1.PropertyAddress, T2.PropertyAddress)
FROM [portfolio project].[dbo].[Nashville.Housing] T1
JOIN [portfolio project].[dbo].[Nashville.Housing] T2
ON T1.ParcelID = T2.ParcelID
AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress is null

-- Address into individual columns for city, state, and address

SELECT PropertyAddress
FROM  [portfolio project].[dbo].[Nashville.Housing]

--use the comma as the delimiter to seperate the city



SELECT 
SUBSTRING(PropertyAddress ,1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, lEN(PropertyAddress)) AS Address
FROM [portfolio project].[dbo].[Nashville.Housing]



ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
ADD PropertyAddressSplit NVARCHAR(255)


UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET PropertyAddressSplit = SUBSTRING(PropertyAddress ,1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
ADD PropertyCitySplit NVARCHAR(255)


UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET PropertyCitySplit = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, lEN(PropertyAddress))



-- NOW I will clean up the owneraddress by seperating the address into 3 columns so its easy to work with

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM [portfolio project].[dbo].[Nashville.Housing]


ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
ADD OwnerAddressSplit NVARCHAR(255)


UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET OwnerAddressSplit =PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
ADD OwnerCitySplit NVARCHAR(255)


UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)



ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
ADD OwnerStateSplit NVARCHAR(255)


UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



-- In the SoldAsVacant chaning the y and n to Yes and No because some use Y and N in the column and some use Yes and No


SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM [portfolio project].[dbo].[Nashville.Housing]
GROUP BY (SoldAsVacant)
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [portfolio project].[dbo].[Nashville.Housing]

UPDATE [portfolio project].[dbo].[Nashville.Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- removing duplicates Use CTE


SELECT *
FROM [portfolio project].[dbo].[Nashville.Housing]


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID)row_num
FROM [portfolio project].[dbo].[Nashville.Housing])

SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress



WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID)row_num
FROM [portfolio project].[dbo].[Nashville.Housing])

DELETE
FROM RowNumCTE
WHERE row_num >1



-- Deleting unused columns

SELECT *
FROM  [portfolio project].[dbo].[Nashville.Housing]

ALTER TABLE [portfolio project].[dbo].[Nashville.Housing]
DROP COLUMN SaleDate, TaxDistrict