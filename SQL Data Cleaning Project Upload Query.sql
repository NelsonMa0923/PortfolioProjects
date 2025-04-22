/*

Cleaning Data in SQL Queries

*/

Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]


--Populate Property Address data

Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]
Where PropertyAddress is null
Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,  ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning] a
Join [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is NULL


Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning] a
Join [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------


-- Breaking out Address Into Individual Columns(Adress, City, State)

Select PropertyAddress
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]

Alter Table [Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table [Nashville Housing Data for Data Cleaning]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))



Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]



Select OwnerAddress
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]

Select
PARSENAME(Replace(OwnerAddress, ',', '.'),3)
,PARSENAME(Replace(OwnerAddress, ',', '.'),2)
,PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]

Alter Table [Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

Alter Table [Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

Alter Table [Nashville Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)

Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]


---------------------------------------------------------------------------------------------------------


--change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant),count(SoldAsVacant)
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant

Select SoldAsVacant
,case when SoldAsVacant = '0' then 'No'
	  when SoldAsVacant = '1' then 'Yes'
	  End
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]


Update [Nashville Housing Data for Data Cleaning]
set UpdatedSoldAsVacant = case when SoldAsVacant = '0' then 'No'
	  when SoldAsVacant = '1' then 'Yes'
	  End
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]

Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]


-----------------------------------------------------------------------------------------------------------


--Remove Duplicate(Remember, Never do it on the raw data)

With RowNumCTE as(
Select*,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueID
						)Row_Num
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID 
)
Select*
From RowNumCTE
Where Row_Num >1


--

With RowNumCTE as(
Select*,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueID
						)Row_Num
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID 
)
Delete
From RowNumCTE
Where Row_Num >1


----------------------------------------------------------------------------------------------------


--Delete Unused Columns

Select *
From [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]


Alter table [Data Cleaning Project].dbo.[Nashville Housing Data for Data Cleaning]
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant
