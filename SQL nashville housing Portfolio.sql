
Select *
From Portfolio.dbo.Housing

-- Standardize Date Format

Select saledate, saleDate2, CONVERT(Date,SaleDate)
From Portfolio.dbo.Housing
 
Update Housing
SET SaleDate2 = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Housing
Add SaleDate2 Date;

Update Housing
SET SaleDate2 = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Portfolio.dbo.Housing
-- Where PropertyAddress is null
order by ParcelID
 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) -- WHAT IF ITS NULL, CHECK IF ITS NULL THEN...
From Portfolio.dbo.Housing a
JOIN Portfolio.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.Housing a
JOIN Portfolio.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolio.dbo.Housing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Portfolio.dbo.Housing


ALTER TABLE PORTFOLIO.dbo.Housing
Add PropertySplitAddress Nvarchar(255);

Update PORTFOLIO.dbo.Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PORTFOLIO.dbo.Housing
Add PropertySplitCity Nvarchar(255);

Update PORTFOLIO.dbo.Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select PropertySplitAddress, PropertySplitCity
From Portfolio.dbo.Housing

 
Select OwnerAddress
From Portfolio.dbo.Housing
where OwnerAddress is not null

Select --paresname only works with period not commas and positioning is backwards  
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio.dbo.Housing
where OwnerAddress is not null


ALTER TABLE PORTFOLIO.dbo.Housing
Add OwnerSplitAddress Nvarchar(255);

Update PORTFOLIO.dbo.Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PORTFOLIO.dbo.Housing
Add OwnerSplitCity Nvarchar(255);

Update PORTFOLIO.dbo.Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PORTFOLIO.dbo.Housing
Add OwnerSplitState Nvarchar(255);

Update PORTFOLIO.dbo.Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Portfolio.dbo.Housing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio.dbo.Housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio.dbo.Housing


Update Portfolio.dbo.Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 Saledate2,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PORTFOLIO.dbo.Housing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (not recommeded to delete data from file)


Select *
From Portfoliot.dbo.Housing


ALTER TABLE Portfolio.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


