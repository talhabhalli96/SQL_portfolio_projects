--Checking the data
select *
from nashville_housing


--Converting SaleDate to date format from Date time format
select SaleDate, CONVERT(date, saledate)
from nashville_housing

Alter table nashville_housing
add SaleDateConverted date

update nashville_housing
set SaleDateConverted = CONVERT(date, saledate)


--Populate Property Address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashville_housing a
join nashville_housing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashville_housing a
join nashville_housing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking address into Individual coloumns
---Property Address
select PropertyAddress,
SUBSTRING(propertyaddress, 1,CHARINDEX(',' ,PropertyAddress)-1) as Address,
substring(propertyaddress, Charindex(',', propertyaddress)+1, LEN(propertyaddress)) as city
from nashville_housing

alter table nashville_housing
add Property_Address nvarchar(255),
PropertyCity nvarchar(255)

update nashville_housing
Set Property_Address = SUBSTRING(propertyaddress, 1,CHARINDEX(',' ,PropertyAddress)-1),
PropertyCity = substring(propertyaddress, Charindex(',', propertyaddress)+1, LEN(propertyaddress))

---Owner Address
select OwnerAddress,
PARSENAME(replace(owneraddress, ',','.'),3),
PARSENAME(replace(owneraddress, ',','.'),2),
PARSENAME(replace(owneraddress, ',','.'),1)
from nashville_housing

alter table nashville_housing
add owner_address nvarchar(255),
owner_address_city nvarchar(255),
owner_address_state nvarchar(255)

update nashville_housing
Set owner_address = PARSENAME(replace(owneraddress, ',','.'),3),
owner_address_city = PARSENAME(replace(owneraddress, ',','.'),2),
owner_address_state = PARSENAME(replace(owneraddress, ',','.'),1)

--Change 'Y' & 'N' to 'Yes' & 'No' in SoldASVacant Coloumn
select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end
from nashville_housing

update nashville_housing
Set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end


--Remove Duplicates
with CteRowNum
as(
select *,
ROW_NUMBER() over(partition by parcelid, PropertyAddress, SaleDate, SalePrice, LegalReference order by uniqueid) as row_num
from nashville_housing)

delete
from CteRowNum
where Row_num > 1


--Remove Unrequired Coloumns
alter table nashville_housing
drop column propertyaddress, saledate, owneraddress, taxdistrict

select *
from nashville_housing

--Note we must open database in which table is located otherwise we would have to change from statement
