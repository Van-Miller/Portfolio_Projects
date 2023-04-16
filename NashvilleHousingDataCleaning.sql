/*

Cleaning Data with SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing


--Standardized Sale Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortFolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Checking that date conversion worked properly
Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------------

--Breaking Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortFolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortFolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



--Checking to see if worked properly
Select *
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Checking updated implementations
Select *
From PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------


--Change "Sold as Vacant" field to have all Yes and No values

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END



---------------------------------------------------------------------------------------------------------------

--Remove Duplicates (Just to demonstrate; not standard practice)

WITH RowNumCTE AS(
Select *,
	ROW_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1


--Checking implementation was successful

WITH RowNumCTE AS(
Select *,
	ROW_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select *
FROM RowNumCTE
Where row_num > 1
Order By PropertyAddress


---------------------------------------------------------------------------------------------------------------


--Delete Unused Columns (Demonstration not standard practice)

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate