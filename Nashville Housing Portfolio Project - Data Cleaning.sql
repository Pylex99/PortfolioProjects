/*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

SELECT saledate, DATE(saledate) AS SaleDate
FROM nashvillehousing;

UPDATE nashvillehousing
SET SaleDate = DATE(SaleDate);


-- Populate Property Address Data


SELECT *
FROM nashvillehousing
WHERE PropertyAddress IS NULL;

SELECT * 
FROM nashvillehousing 
WHERE TRIM(PropertyAddress) = '';

SELECT *
FROM nashvillehousing
WHERE PropertyAddress = '';

-- Identifies all empty property addresses where ParcelIDs are the same
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

-- Populates property addresses into the empty fields with identical ParcelIDs
UPDATE nashvillehousing AS a
JOIN nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IF (a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '';

-------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- PropertyAddress
SELECT PropertyAddress
FROM nashvillehousing;


SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM nashvillehousing;

-- Actual process. Creating new columns and inserting split data in them
ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255),
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
	PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- Double checking the result
SELECT * -- PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM nashvillehousing;
-- Moving newly created columns right after the original one for readability
ALTER TABLE nashvillehousing
MODIFY PropertySplitAddress VARCHAR(255) AFTER PropertyAddress,
MODIFY PropertySplitCity VARCHAR(255) AFTER PropertySplitAddress;

-- OwnerAddress
SELECT OwnerAddress
FROM nashvillehousing;

SELECT OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
	OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
	OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);
    
ALTER TABLE nashvillehousing
MODIFY OwnerSplitAddress VARCHAR(255) AFTER OwnerAddress,
MODIFY OwnerSplitCity VARCHAR(255) AFTER OwnerSplitAddress,
MODIFY OwnerSplitState VARCHAR(255) AFTER OwnerSplitCity;

-- OwnerName
SELECT OwnerName
FROM nashvillehousing;

SELECT OwnerName,
	SUBSTRING_INDEX(OwnerName, ',', 1) AS OwnerLastName,
    SUBSTRING_INDEX(OwnerName, ',', -1) AS OwnerFirstName
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerLastName VARCHAR(255),
ADD OwnerFirstName VARCHAR(255);

UPDATE nashvillehousing
SET OwnerLastName = SUBSTRING_INDEX(OwnerName, ',', 1),
	OwnerFirstName = SUBSTRING_INDEX(OwnerName, ',', -1);
    
ALTER TABLE nashvillehousing
MODIFY OwnerLastName VARCHAR(255) AFTER OwnerName,
MODIFY OwnerFirstName VARCHAR(255) AFTER OwnerLastName;


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END
FROM nashvillehousing;
        
UPDATE nashvillehousing
SET SoldAsVacant = 	CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;
                    
                    
-- Remove Duplicates

SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, COUNT(*) AS Count
FROM NashvilleHousing
GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
HAVING COUNT(*) > 1;

DELETE nh1 FROM NashvilleHousing AS nh1
INNER JOIN nashvillehousing AS nh2
WHERE
	nh1.UniqueID < nh2.UniqueID AND
    nh1.ParcelID = nh2.ParcelID AND
    nh1.SalePrice = nh2.SalePrice AND
    nh1.LegalReference = nh2.LegalReference;

SELECT * FROM nashvillehousing ;


-- Delete Unused Columns

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN SaleDate;
