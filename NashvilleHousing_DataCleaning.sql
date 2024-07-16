-- STANDARDIZE DATE FORMAT

--SELECT SaleDateConverted, convert(Date, SaleDate) as DateofSale
--FROM NashvilleHousing

--ALTER TABLE NashvilleHousing
--ADD SaleDateConverted Date;

--UPDATE NashvilleHousing
--SET SaleDateConverted = CONVERT(Date, SaleDate)

-- POPULATE PROPERTY ADDRESS DATA

SELECT nh1.ParcelID, nh1.PropertyAddress,nh2.ParcelID,nh2.PropertyAddress, ISNULL(nh1.PropertyAddress, nh2.PropertyAddress) 
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
	ON nh1.parcelID = nh2.ParcelID and
	nh1.[UniqueID ] != nh2.[UniqueID ]
where nh1.PropertyAddress is null

-- TO UPDATE THE TABLE HERE YOU HAVE TO USE THE ALIAS

UPDATE nh1
SET  PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress) 
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
	ON nh1.parcelID = nh2.ParcelID and
	nh1.[UniqueID ] != nh2.[UniqueID ]
where nh1.PropertyAddress is null

-- FORMATTING STRINGS IN PROPERTY ADDRESS

select 
	 substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)- 1) as address,
	 substring(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1 ,len(PropertyAddress)) as address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)- 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1 ,len(PropertyAddress))

select CONCAT(PropertySplitAddress, ' ', PropertySplitCity)
FROM NashvilleHousing

-- ANOTHER WAY TO ALTER THE ADDRESS STRING USING PARSENAME--
SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

select *
from NashvilleHousing

-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD 

select distinct(soldasvacant), count(*)
from NashvilleHousing 
group by SoldAsVacant
order by 2 

SELECT soldasvacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing 

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing 

-- REMOVING DUPLICATES (not standard practice)

with duplicates as (
select *, 
	ROW_NUMBER() over(PARTITION BY	parcelID, propertyAddress, saleprice, saledate, legalreference order by uniqueid) as row_num
from NashvilleHousing
--ORDER BY row_num
)

DELETE 
from duplicates
where row_num > 1 

select * 
from duplicates
where row_num > 1 
order by propertyaddress

-- DELETING COLUMNS (USUALLY THIS IS DONE BY USING VIEWS)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, SaleDate

select top 100 *
from NashvilleHousing

