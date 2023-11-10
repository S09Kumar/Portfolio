/*


SQL Queries- Data Cleaning


*/



select * 
from PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

--Standardizing Date Format


select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate) 

--If it doesn't work properly

Alter Table NashvilleHousing
add SaleDateConverted date; 

update NashvilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------

--Populating Property address data  


select *
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
		on a.ParcelID=b.ParcelID
		and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

update a 
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)--if a.propertyaddress is null then make it b.propertyaddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
		on a.ParcelID=b.ParcelID
		and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 






--------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)


select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by PropertyAddress

select
SUBSTRING(PropertyAddress,1, charindex(',',PropertyAddress)-1) as Address-- -1 excludes the last chareacter ','.										
 , SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress)) as city-- +1 starting after ',' and printing till end of len(address) 

from PortfolioProject..NashvilleHousing



Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255); 

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1, charindex(',',PropertyAddress)-1)


Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255); 

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing


--Now for Owner address

Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
ParseName(Replace(OwnerAddress,',','.'),3),
ParseName(Replace(OwnerAddress,',','.'),2),
ParseName(Replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255); 

update NashvilleHousing
set OwnerSplitAddress=ParseName(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255); 

update NashvilleHousing
set OwnerSplitCity=ParseName(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255); 

update NashvilleHousing
set OwnerSplitState=ParseName(Replace(OwnerAddress,',','.'),1)

Select *
from PortfolioProject..NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------

--Change Y and N as Yes and No in 'SoldAsVacant' field


Select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2
 

Select SoldAsVacant
,Case when SoldAsVacant='Y' then 'Yes'
	  when SoldAsVacant= 'N' then 'No'
	  Else SoldAsVacant
	  end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant= Case when SoldAsVacant='Y' then 'Yes'
	  when SoldAsVacant= 'N' then 'No'
	  Else SoldAsVacant
	  end




--------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by 
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE 
from RowNumCTE
where row_num>1
--order by PropertyAddress 





-------------------------------------------------------------------------------------------------------------------------- 

--Delete Unused Columns


Select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column OwnerAddress,TaxDistrict, propertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop column SaleDate