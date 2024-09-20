Select * From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

--Populate Property Address
Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a 
Join PortfolioProject..NashvilleHousing b On a.ParcelID = b.ParcelID And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a 
Join PortfolioProject..NashvilleHousing b On a.ParcelID = b.ParcelID And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into individual columns (Address, City, State)
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing;

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject..NashvilleHousing;

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select * From PortfolioProject..NashvilleHousing

--Change Y and N as Yes and No in Sold as Vacant Field
Select Distinct(SoldAsVacant) ,Count(*) From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order By 2;

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End


--Remove Duplicates
With RowNumCTE as
(
Select *,
ROW_NUMBER() Over (Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order By ParcelID) row_num
From PortfolioProject..NashvilleHousing
)
--Row number gives same value if the columns that it is partitioned by have different values, if the values are same then it give same results

Delete
From RowNumCTE
Where row_num > 1;


--Delete Unused Columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
