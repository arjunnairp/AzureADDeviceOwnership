param (
[string]$DeviceName = (Read-Host -prompt 'Enter Device name'),
[string]$CurrentOwner = (Read-Host -prompt 'Enter Current Owner of $DeviceName'),
[string]$NewOwner = (Read-Host -prompt 'Enter New Owner of $DeviceName')
)

<#
$Device_Object = 'LAPTOP-AzureAD1'
$CurrentRegOwner = 'someone.departed@contoso.com'
$NewRegOwner = 'newuser@contoso.com'
#>

$Device_Object = $DeviceName
$CurrentRegOwner = $CurrentOwner
$NewRegOwner = $NewOwner

#Install Module enable this on new system
Install-module AzureADPreview -AllowClobber

#connect with Azure AD
Connect-AzureAD 

#get object ID of all Azure AD joined devices in your tenant
$DeviceObjectID = Get-AzureADDevice -SearchString $Device_Object |select id
$Device = Get-AzureADDevice -SearchString $Device_Object
$Device

#Get current owner of device objectid
$CurrentOwnerRefObjectId = get-azureaduser -All $true | Where-Object {$_.UserPrincipalName -eq $CurrentRegOwner}
#$CurrentOwnerRefObjectId
$CurrentOwnerName = $CurrentOwnerRefObjectId.DisplayName

#Get new owner of device objectid
$NewOwnerRefObjectId = get-azureaduser -All $true | Where-Object {$_.UserPrincipalName -eq $NewRegOwner}
#$NewOwnerRefObjectId
$NewOwnerName = $NewOwnerRefObjectId.DisplayName

#getting device ownership
$GetRegCurrentOwner = Get-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId

<#
add new owner to device Where,
-ObjectId is to specify the object id of the device
-RefObjectId is to specify the object ID of the user you want to add as registered owner.
#>

If ($GetRegCurrentOwner.UserPrincipalName -eq $NewOwnerRefObjectId.UserPrincipalName){
Write-Host "$NewOwnerName is already the the owner of $Device_Object. Not $CurrentOwnerName" -ForegroundColor red -BackgroundColor white
Exit
} 
Else {
Write-Host "Adding $NewOwnerName as owner of $Device_Object" -ForegroundColor Blue -BackgroundColor white
$AddnewOwner = Add-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId -RefObjectId $NewOwnerRefObjectId.ObjectId
}


<#
Remove Current owner from device Where,

-ObjectId is to specify the object id of the device

-OwnerId is to specify the Current registered owner
#>
$Device = Get-AzureADDevice -SearchString $Device_Object
$Owner = Get-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId #| Where-Object {$_.UserPrincipalName -eq $CurrentRegOwner}
If ($Owner.UserPrincipalName -match $CurrentRegOwner){
$RemCurrentOwner = Remove-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId -OwnerId $CurrentOwnerRefObjectId.ObjectId

  Write-Host "$CurrentOwnerName removed as owner of $Device_Object" -ForegroundColor red -BackgroundColor white
 } Else {
     Write-Host "$CurrentOwnerName not owner of $Device_Object. Quitting..." -ForegroundColor Blue -BackgroundColor white
}