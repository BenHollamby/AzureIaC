$VMLocalAdminUser = "fortigateuser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "DEft0nes" -AsPlainText -Force
$LocationName = "australiaeast"
$ResourceGroupName = "RG_Networking"
$ComputerName = "FGT-01"
$VMName = "fgtvm"
$VMSize = "Standard_F2s_v2"

$NIC = (Get-AzNetworkInterface).id[0]
$INTNIC = (Get-AzNetworkInterface).id[1]
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

$agreementTerms = Get-AzMarketplaceterms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm_payg_2022"
Set-AzMarketplaceTerms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm_payg_2022" -Terms $agreementTerms -Accept

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize 
$VirtualMachine = Set-AzVMPlan -VM $VirtualMachine -Publisher 'Fortinet' -Product 'fortinet_fortigate-vm_v5' -Name 'fortinet_fg-vm_payg_2022'
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC -Primary
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $INTNIC
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'Fortinet' -Offer 'fortinet_fortigate-vm_v5' -Skus 'fortinet_fg-vm_payg_2022' -Version '7.2.1'

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine

#Get-AzVMImage -Location "australiaeast" -PublisherName "Fortinet" -Offer "fortinet_fortigate-vm_v5" -Skus "fortinet_fg-vm_payg_2022" -Version "latest"