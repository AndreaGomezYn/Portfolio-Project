/*
Cleaning Data in SQL Queries
*/

Select *
from PortfolioProject.dbo.NashvilleHousing 

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT (Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing 

Update NashvilleHousing 
SET SaleDate=CONVERT (Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted=CONVERT (Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

-- To see everything where PropertyAdress is null

Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID 

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID =b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID =b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID 

SELECT
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
	--CHARINDEX(',',PropertyAddress) as Address
from PortfolioProject.dbo.NashvilleHousing 

------ CREATE 2 NEW COLUMNS

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


Select*
from PortfolioProject.dbo.NashvilleHousing 

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing 

-- Easier way to do it. However, PARSENAME works with '.', so a replacement of ',' to '.' is needed.
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

	Select*
	From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y'THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y'THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Partition it on things that should be unique to each row.

WITH RowNumCTE AS (
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
--Order by ParcelID 
)

Select *
--Delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select*
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN SaleDate