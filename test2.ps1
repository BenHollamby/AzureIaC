$VMLocalAdminUser = "fortigateuser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "DEft0nes" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$ComputerName = "FGT-01"

$agreementTerms = Get-AzMarketplaceterms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm_payg_2022"
Set-AzMarketplaceTerms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm_payg_2022" -Terms $agreementTerms -Accept


$NIC = (Get-AzNetworkInterface).id[0]
$INTNIC = (Get-AzNetworkInterface).id[1]

$vmConfig = New-AzVMConfig -VMName "FGT-VM-01" -VMSize Standard_DS1_v2
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $NIC -Primary
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $INTNIC
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $ComputerName -Credential $Credential
$offername = "fortinet_fortigate-vm_v5"
$skuname = "fortinet_fg-vm_payg_2022"
$version = "2.7.1"
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName Fortinet -Offer "fortinet_fortigate-vm_v5" -Skus "fortinet_fg-vm_payg_2022" -Version 7.1.2

New-AzVM -ResourceGroupName 'RG_Networking' -Location australiaeast -VM $vmConfig