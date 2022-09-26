New-AzStorageAccount -ResourceGroupName "RG_Storage" -Location 'australiaeast' -Name "teststora19851507" -SkuName Standard_LRS -Kind StorageV2 -MinimumTlsVersion TLS1_2


#Get-AzVMImage -Location "australiaeast" -PublisherName "Fortinet" -Offer "fortinet_fortigate-vm_v5" -Skus "fortinet_fg-vm_payg_2022" -Version 7.2.1 | New-AzVM

<#
       0.013 . "c:\Users\Kallor\devops\AzureIaC\Azure.ps1"
   2     1:20.586 new-iaSetup -VNet 10.0.0.0/16 -Subnet 10.0.1.0/24 -Location australiaeast
   3       30.062 . "c:\Users\Kallor\devops\AzureIaC\test.ps1"
   4        0.006 $VMLocalAdminUser = "fortigateuser"
   5        0.007 $VMLocalAdminSecurePassword = ConvertTo-SecureString "password" -AsPlainText -Force
   6        0.007 $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
   7        0.251 $virutalmachine =  New-AzVMConfig -VMName "FGT-001" -VMSize "Standard_DS1_v2"
   8        0.931 $NIC = (Get-AzNetworkInterface).id[0]
   9        0.650 $INTNIC = (Get-AzNetworkInterface).id[1]
  10        0.069 $virutalmachine = Set-AzVMOperatingSystem -VM $virtualmachine -Linux -ComputerName "fgt-002" -Credential $Credential
  11        0.309 $virtualmachine =  New-AzVMConfig -VMName "FGT-001" -VMSize "Standard_DS1_v2"
  12        0.253 $virutalmachine = Set-AzVMOperatingSystem -VM $virtualmachine -Linux -ComputerName "fgt-002" -Credential $Credential
  13        0.224 $virutalmachine = Add-AzVMNetworkInterface -VM $virtualmachine -Id $NIC -Primary
  14        0.197 $virutalmachine = Add-AzVMNetworkInterface -VM $virtualmachine -Id $INTNIC
  15        0.244 $virutalmachine = Set-AzVMSourceImage -VM $virutalmachine -PublisherName 'Fortinet' -Offer 'fortinet_fortigate-vm_v5' -Skus 'fortinet_fg-vm' -Version latest
  16       13.518 New-AzVM -ResourceGroupName 'RG_Networking' -Location 'australiaeast' -VM $virtualmachine -Verbose
  17        3.866 $agreementterms = get-azmarketplaceterms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm"
  18        0.020 $virutalmachine
  19        0.223 $virutalmachine | Set-AzVMPlan -Name 'fortinet_fg-vm' -Product 'fortinet_fortigate-vm_v5' -Publisher 'Fortinet'
  20       18.532 New-AzVM -ResourceGroupName 'RG_Networking' -Location 'australiaeast' -VM $virtualmachine -Verbose
  21        0.012 $virutalmachine.plan
  22        0.012 $virutalmachine.plan | gm
  23        0.004 $virutalmachine
  24        0.475 $virutalmachine = Set-AzVMSourceImage -VM $virutalmachine -PublisherName 'Fortinet' -Offer 'fortinet_fortigate-vm_v5' -Skus 'fortinet_fg-vm' -Version 7.2.1
  25        0.003 $virutalmachine
  26       17.835 New-AzVM -ResourceGroupName 'RG_Networking' -Location 'australiaeast' -VM $virtualmachine -Verbose
  27        0.432 $virutalmachine = Set-AzVMSourceImage -VM $virutalmachine -PublisherName 'Fortinet' -Offer 'fortinet_fortigate-vm_v5' -Skus 'fortinet_fg-vm' -Version 7.0.6
  28        0.025 get-history
  29       16.970 New-AzVM -ResourceGroupName 'RG_Networking' -Location 'australiaeast' -VM $virtualmachine -Verbose
  #>


  #https://mcpmag.com/articles/2019/07/16/powershell-for-parametrized-arm-templates.aspx