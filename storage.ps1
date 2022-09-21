$VMLocalAdminUser = "fortigateuser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'password' -AsPlainText -Force
$LocationName = "australiaeast"
$ResourceGroupName = "RG_Networking"
$ComputerName = "FGT-01"
$VMName = "fgt-01"
$VMSize = "Standard_DS1_v2"
$refid = (Get-AzVMImage -Location australiaeast -PublisherName fortinet -Offer fortinet_fortigate-vm_v5 -Skus fortinet_fg-vm_payg_2022 -Version 7.2.1).Id

$NIC = (Get-AzNetworkInterface).id[0]
$INTNIC = (Get-AzNetworkInterface).id[1]
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

$agreementterms = get-azmarketplaceterms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm"
Set-AzMarketplaceTerms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm" -Terms $agreementTerms -Accept

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize 
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'Fortinet' -Offer "fortinet_fortigate-vm_v5" -Skus 'fortinet_fg-vm' -Version '7.2.1'
$VirtualMachine = Set-AzVMPlan -VM $VirtualMachine -Publisher 'Fortinet' -Product 'fortinet_fortigate-vm_v5' -Name 'fortinet_fg-vm'
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC -Primary
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $INTNIC
new-azvm -ImageReferenceId $refid -ResourceGroupName RG_Networking -Location australiaeast

#NEED
<#
Region
username
password
nameprefix
sku
version
size
external subnet
internal subnet
protected subnet
public ip

#>


####
#$refid = (Get-AzVMImage -Location australiaeast -PublisherName fortinet -Offer fortinet_fortigate-vm_v5 -Skus fortinet_fg-vm_payg_2022 -Version 7.2.1).Id
###

#New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -

#Get-AzVMImage -Location "australiaeast" -PublisherName "Fortinet" -Offer "fortinet_fortigate-vm_v5" -Skus "fortinet_fg-vm_payg_2022" -Version "latest"

<#
GENERAL
Provisioning state Provisioning failed.
Unable to deploy from the Marketplace image or a custom image sourced from Marketplace image. The part number in the purchase information for VM '/subscriptions/e4928e11-7de5-42cf-8972-85368ec589c2/resourceGroups/RG_Networking/providers/Microsoft.Compute/virtualMachines/fgtvm' is not as expected. Beware that the Plan object's properties are case-sensitive..
VMMarketplaceInvalidInput
Provisioning state error code ProvisioningState/failed/VMMarketplaceInvalidInput
Guest agent Unknown
DISKS
fgtvm_OsDisk_1_496bf48ad29842eebb18546d1ad99d8c Provisioning failed.
Unable to deploy from the Marketplace image or a custom image sourced from Marketplace image. The part number in the purchase information for VM '/subscriptions/e4928e11-7de5-42cf-8972-85368ec589c2/resourceGroups/RG_Networking/providers/Microsoft.Compute/virtualMachines/fgtvm' is not as expected. Beware that the Plan object's properties are case-sensitive..
VMMarketplaceInvalidInput
#>

# LATEST ITERATION
#Get-AzVMImage -Location australiaeast -PublisherName "fortinet" -Offer fortinet_fortigate-vm_v5 -Skus fortinet_fg-vm -Version 7.2.1
#$agreementterms = get-azmarketplaceterms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm"
#Set-AzMarketplaceTerms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm" -Terms $agreementTerms -Accept

#Get-AzVMImage -Location "australiaeast" -PublisherName "Fortinet" -Offer "fortinet_fortigate-vm_v5" -Skus "fortinet_fg-vm_payg_2022" -Version 7.2.1