Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
function New-IASetup {

    <#
    .SYNOPSIS
    New-IASetup (New Ignite Azure Setup) will create multiple resource based on an existing best practice configuration.
    You will need the AZ module installed, (Install-Module AZ), and you will need to connect to the subscription with
    Connect-AzAccount.
    For accounts with multiple subscriptions, you will want to check you are connected to the correct subscription
    with Get-AzContext. If you the subscription is wrong you can change to another via Set-AzContext <SubscriptionID>.
    PLEASE CHECK YOU ARE IN THE CORRECT TENANT AND SUBSCRIPTION BEFORE DEPLOYING.
    .DESCRIPTION
    New-IASetup will create 5 resource groups named RG_Networking, RG_Backup, RG_Server, 
    RG_Storage, and RG_VirtualDesktop.
    It will also create a virtual network based on the VNET parameter.
    New-IASetup will create 6 subnets starting either sequentially from the Subnet parameter incrementing by 1 or 
    prompted for each subnet with the Custom parameter. Subnets created are named, sub_Protected,
    sub_External, sub_Internal, sub_Storage, sub_VirtualDesktop, and sub_Server.
    A network security group with 4 rules, Allow Firewall Management on port 11443, Allow Ping,
    Allow VPN, and Deny All.
    Lastly a Route Table is created with address prefix of 0.0.0.0/0 with a next hop to a Virtual Appliance, 
    and sets the next hop IP address to X.X.X.4 based on the subnet sub_Internal's address space. It attaches 
    the following subnets, sub_Internal, sub_Storage, sub_VirtualDesktop, and sub_Server.
    .PARAMETER VNet
    Sets the address space in the resource group RG_Networking named VN_Core. Tab complete for 10.0.0.0/16, 
    172.32.0.0/16, or 192.168.0.0/16 spaces.
    .PARAMETER Subnet
    Sets the first subnet, and then increments following subnets by one in the following order:
    sub_Protected 
    sub_External 
    sub_Internal
    sub_Storage
    sub_VirtualDesktop
    sub_Server
    .PARAMETER Location
    Optional parameter, sets the location, default is currently australiasoutheast. Tab complete enabled for two regions.
    More will be added once our regions come online.
    .PARAMETER Custom
    If you would like to manually specify each subnet, use this parameter, and you will be prompted
    individually for vnet and subnets.
    .EXAMPLE
    New-IASetup -VNet 10.0.0.0/16 -Subnet 10.0.1.0/24 -Location australiaeast

    This will create the following:
    AZURE RESOURCE      NAME                    LOCATION        ADDRESS         RESOURCE GROUP  ROUTETABLE

    Resoure Group       RG_Networking           Australia East  N/A             N/A
    Resoure Group       RG_Backup               Australia East  N/A             N/A
    Resoure Group       RG_Server               Australia East  N/A             N/A
    Resoure Group       RG_Storage              Australia East  N/A             N/A
    Resoure Group       RG_VirtualDesktop       Australia East  N/A             N/A
    
    Virutal Network     VN_Core                 Australia East  10.0.0.0/16     RG_Networking
    Route Table         Route-Table             Australia East  0.0.0.0/0       RG_Networking
    Subnet              sub_Protected           Australia East  10.0.1.0/24     RG_Networking
    Subnet              sub_External            Australia East  10.0.2.0/24     RG_Networking
    Subnet              sub_Internal            Australia East  10.0.3.0/24     RG_Networking   Route-Table
    Subnet              sub_Storage             Australia East  10.0.4.0/24     RG_Networking   Route-Table
    Subnet              sub_VirtualDesktop      Australia East  10.0.5.0/24     RG_Networking   Route-Table
    Subnet              sub_Server              Australia East  10.0.6.0/24     RG_Networking   Route-Table
    NSG                 NSG_Firewall_External   Australia East  N/A             RG_Networking
    
    The Route Table sets a default route of 0.0.0.0/0 with a type of next top as Virtual Appliance
    with the first IP available on the internal subnet. In this case, 10.0.3.4.

    The Network Security Group created will create four rules:
    NAME                ACCESS      PROTOCOL        DIRECTION       PRIORITY        SOURCE-PREFIX       SOURCEPORTRANGE     DESTINATION-PREFIX      DESTINATIONPORTRANGE        DESCRIPTION
    Allow_FW_Management Allow       TCP             Inbound         150             *                   *                   10.0.2.4                11443                       Allows firewall management
    Allow_ICMP          Allow       ICMP            Inbound         151             *                   *                   10.0.2.4                *                           Allows ping
    Fortigate_SSL_VPN   Allow       *               Inbound         180             *                   *                   10.0.2.4                9443                        Allows VPN traffic
    Deny_All            Deny        *               Inbound         4096            *                   *                   *                       *                           Deny all traffic
    .EXAMPLE
    New-IASetup -Custom

    {PROMPT}-"Please enter the IPv4 address space"                      10.0.0.0/16 {USER-ENTERED}
    {PROMPT}-"Please enter the subnet address for sub_Protected"        10.0.1.0/24 {USER-ENTERED}
    {PROMPT}-"Please enter the subnet address for sub_External"         10.0.2.0/24 {USER-ENTERED}
    {PROMPT}-"Please enter the subnet address for sub_Internal"         10.0.3.0/24 {USER-ENTERED}
    {PROMPT}-"Please enter the subnet address for sub_Storage"          10.0.4.0/24 {USER-ENTERED}
    {PROMPT}-"Please enter the subnet address for sub_VirtualDesktop"   10.0.5.0/24 {USER-ENTERED}
    {PROMPT}-"Please enter the subnet address for sub_Server"           10.0.6.0/24 {USER-ENTERED}

    This will create the following:
    AZURE RESOURCE      NAME                    LOCATION        ADDRESS         RESOURCE GROUP  ROUTETABLE

    Resoure Group       RG_Networking           Australia East  N/A             N/A
    Resoure Group       RG_Backup               Australia East  N/A             N/A
    Resoure Group       RG_Server               Australia East  N/A             N/A
    Resoure Group       RG_Storage              Australia East  N/A             N/A
    Resoure Group       RG_VirtualDesktop       Australia East  N/A             N/A
    
    Virutal Network     VN_Core                 Australia East  10.0.0.0/16     RG_Networking
    Route Table         Route-Table             Australia East  0.0.0.0/0       RG_Networking
    Subnet              sub_Protected           Australia East  10.0.1.0/24     RG_Networking
    Subnet              sub_External            Australia East  10.0.2.0/24     RG_Networking
    Subnet              sub_Internal            Australia East  10.0.3.0/24     RG_Networking   Route-Table
    Subnet              sub_Storage             Australia East  10.0.4.0/24     RG_Networking   Route-Table
    Subnet              sub_VirtualDesktop      Australia East  10.0.5.0/24     RG_Networking   Route-Table
    Subnet              sub_Server              Australia East  10.0.6.0/24     RG_Networking   Route-Table
    NSG                 NSG_Firewall_External   Australia East  N/A             RG_Networking
    
    The Route Table sets a default route of 0.0.0.0/0 with a type of next top as Virtual Appliance
    with the first IP available on the internal subnet. In this case, 10.0.3.4.

    The Network Security Group created will create four rules:
    NAME                ACCESS      PROTOCOL        DIRECTION       PRIORITY        SOURCE-PREFIX       SOURCEPORTRANGE     DESTINATION-PREFIX      DESTINATIONPORTRANGE        DESCRIPTION
    Allow_FW_Management Allow       TCP             Inbound         150             *                   *                   10.0.2.4                11443                       Allows firewall management
    Allow_ICMP          Allow       ICMP            Inbound         151             *                   *                   10.0.2.4                *                           Allows ping
    Fortigate_SSL_VPN   Allow       *               Inbound         180             *                   *                   10.0.2.4                9443                        Allows VPN traffic
    Deny_All            Deny        *               Inbound         4096            *                   *                   *                       *                           Deny all traffic
    #>

    [cmdletbinding(DefaultParameterSetName='vnet')]

    param(

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName='vnet',
            HelpMessage = "Please enter region to deploy to, default is Australia East"
        )]
        [ArgumentCompleter({'australiaeast', 'australiasoutheast'})] #add more comma seperated regions here run "get-azlocation | Select-Object location" to get list all regions
        [string]$Location = "australiasoutheast",

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName='vnet',
            HelpMessage = "Please enter the IPv4 address space. Default is 10.0.0.0/16"
        )]
        [ArgumentCompleter({'10.0.0.0/16','172.32.0.0/16','192.168.0.0/16'})]
        [string]$VNet,

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName='vnet',
            HelpMessage = "Subnet starting address, this will increment by one, six times creating new subnets"
        )]
        [ArgumentCompleter({'10.0.1.0/24','172.32.1.0/24','192.168.129.0/24'})]
        [string[]]$Subnet,

        [Parameter(
            ParameterSetName='custom',
            HelpMessage = 'prompt for address space and subnets'
        )]
        [Switch]$Custom

    )

    BEGIN {

        New-AzResourceGroup -Location $Location -Name "RG_Backup"         | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Networking"     | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Server"         | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Storage"        | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_VirtualDesktop" | Out-Null
        
    }

    PROCESS {

        if ($Custom) {
            
            $AddressPrefix        = Read-Host "Please enter the IPv4 address space"
            $sub_ProtectedSN      = Read-Host "Please enter the subnet address for sub_Protected"
            $sub_ExternalSN       = Read-Host "Please enter the subnet address for sub_External"
            $sub_InternalSN       = Read-Host "Please enter the subnet address for sub_Internal"
            $sub_StorageSN        = Read-Host "Please enter the subnet address for sub_Storage"
            $sub_VirtualDesktopSN = Read-Host "Please enter the subnet address for sub_VirtualDesktop"
            $sub_ServerSN         = Read-Host "Please enter the subnet address for sub_Server"

            $VirtualNetwork = New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -Location $Location -AddressPrefix $AddressPrefix

            $RouteTable = New-AzRouteTable -ResourceGroupName 'RG_Networking' -Name 'Route-Table' -Location $Location

            $sub_protected = New-AzVirtualNetworkSubnetConfig -Name 'sub_Protected' -AddressPrefix $sub_ProtectedSN
            $VirtualNetwork.Subnets.Add($sub_Protected)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_External = New-AzVirtualNetworkSubnetConfig -Name 'sub_External' -AddressPrefix $sub_ExternalSN
            $VirtualNetwork.Subnets.Add($sub_External)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_Internal = New-AzVirtualNetworkSubnetConfig -Name 'sub_Internal' -AddressPrefix $sub_InternalSN -RouteTable $RouteTable
            $VirtualNetwork.Subnets.Add($sub_Internal)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_Storage = New-AzVirtualNetworkSubnetConfig -Name 'sub_Storage' -AddressPrefix $sub_StorageSN -RouteTable $RouteTable
            $VirtualNetwork.Subnets.Add($sub_Storage)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_VirtualDesktop = New-AzVirtualNetworkSubnetConfig -Name 'sub_VirtualDesktop' -AddressPrefix $sub_VirtualDesktopSN -RouteTable $RouteTable
            $VirtualNetwork.Subnets.Add($sub_VirtualDesktop)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_Server = New-AzVirtualNetworkSubnetConfig -Name 'sub_Server' -AddressPrefix $sub_ServerSN -RouteTable $RouteTable
            $VirtualNetwork.Subnets.Add($sub_Server)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $InternalSN = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty addressprefix
            $iip = $InternalSN.split(".").split("/")
            $a,$b,$c,$d,$e = $iip[0], $iip[1], $iip[2], $iip[3], $iip[4]
            $d = 4
            $NextHopIP = $a + "." + $b + "." + $c + "." + $d
           
            Get-AzRouteTable -ResourceGroupName "RG_Networking" -Name "Route-Table" | Add-AzRouteConfig -Name "Default-Route" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $NextHopIP | Set-AzRouteTable | Out-Null

            #NSG
            $ExternalIPRange = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix 
            $sei = $ExternalIPRange.split(".").Split("/")
            $a,$b,$c,$d,$e = $sei[0], $sei[1], $sei[2], $sei[3], $sei[4]
            $d = 4
            $DestinationAddressPrefix = $a + "." + $b + "." + $c + "." + $d

            $rule1 = New-AzNetworkSecurityRuleConfig -Name Allow_FW_Management -Description "Allows firewall management" `
                -Access Allow -Protocol Tcp -Direction Inbound -Priority 150 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 11443

            $rule2 = New-AzNetworkSecurityRuleConfig -Name Allow_ICMP -Description "Allow Ping" `
                -Access Allow -Protocol Icmp -Direction Inbound -Priority 151 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange *

            $rule3 = New-AzNetworkSecurityRuleConfig -Name Fortigate_SSL_VPN -Description "Allow VPN traffic" `
                -Access Allow -Protocol * -Direction Inbound -Priority 180 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 9443

            $rule4 = New-AzNetworkSecurityRuleConfig -Name Deny_All -Description "Deny" `
                -Access Deny -Protocol * -Direction Inbound -Priority 4096 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

            New-AzNetworkSecurityGroup -ResourceGroupName "RG_Networking" -Location $Location -Name "NSG_Firewall_External" -SecurityRules $rule1,$rule2,$rule3,$rule4 | Out-Null

            <#PublicIP
            New-AzPublicIpAddress -Name "FGT_PublicIP" -ResourceGroupName "RG_Networking" -Location $Location -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4 | Out-Null

            #Internal FGT interface
            $GetInternalNIC = Get-AzVirtualNetwork
            $SubnetID = $GetInternalNIC.subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty Id
            New-AzNetworkInterface -Name "INT_FGT_NWI" -ResourceGroupName "RG_Networking" -Location $Location -SubnetId $SubnetID -EnableIPForwarding | Out-Null

            #External FGT Interface
            $PublicIP = (Get-AzPublicIpAddress).Id
            $NSG = (Get-AzNetworkSecurityGroup).Id
            $GetExternalNICSubnet = Get-AzVirtualNetwork
            $SubnetID = $GetExternalNICSubnet.subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty Id
            New-AzNetworkInterface -Name "EXT_FGT_NWI" -ResourceGroupName "RG_Networking" -Location $Location -SubnetId $SubnetID -PublicIpAddressId $PublicIP -NetworkSecurityGroupId $NSG -EnableIPForwarding | Out-Null
            #>
        } 
        
        if ($VNet) {
            
            #VNET
            $VirtualNetworks = New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -AddressPrefix $VNet -Location $Location

            #ROUTE-TABLE
            #$Route = New-AzRouteConfig -Name 'Default-Route' -AddressPrefix 0.0.0.0/24 -NextHopType VirtualAppliance -NextHopIpAddress 0.0.0.0
            $RouteTable = New-AzRouteTable -ResourceGroupName 'RG_Networking' -Name 'Route-Table' -Location $Location

            $sub_ProtectedSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_ProtectedSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            #$e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ExternalSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_External -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_ExternalSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null
            

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            #$e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_InternalSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Internal -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_InternalSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            #$e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_StorageSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Storage -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_StorageSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            #$e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_VirtualDesktopSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_VirtualDesktop -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_VirtualDesktopSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            #$e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ServerSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Server -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_ServerSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $InternalSN = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty addressprefix
            $iip = $InternalSN.split(".").split("/")
            $a,$b,$c,$d,$e = $iip[0], $iip[1], $iip[2], $iip[3], $iip[4]
            $d = 4
            $NextHopIP = $a + "." + $b + "." + $c + "." + $d
           
            Get-AzRouteTable -ResourceGroupName "RG_Networking" -Name "Route-Table" | Add-AzRouteConfig -Name "Default-Route" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $NextHopIP | Set-AzRouteTable | Out-Null

            #NSG
            $ExternalIPRange = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix 
            $sei = $ExternalIPRange.split(".").Split("/")
            $a,$b,$c,$d,$e = $sei[0], $sei[1], $sei[2], $sei[3], $sei[4]
            $d = 4
            $DestinationAddressPrefix = $a + "." + $b + "." + $c + "." + $d

            $rule1 = New-AzNetworkSecurityRuleConfig -Name Allow_FW_Management -Description "Allows firewall management" `
                -Access Allow -Protocol Tcp -Direction Inbound -Priority 150 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 11443

            $rule2 = New-AzNetworkSecurityRuleConfig -Name Allow_ICMP -Description "Allow Ping" `
                -Access Allow -Protocol Icmp -Direction Inbound -Priority 151 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange *

            $rule3 = New-AzNetworkSecurityRuleConfig -Name Fortigate_SSL_VPN -Description "Allow VPN traffic" `
                -Access Allow -Protocol * -Direction Inbound -Priority 180 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 9443

            $rule4 = New-AzNetworkSecurityRuleConfig -Name Deny_All -Description "Deny" `
                -Access Deny -Protocol * -Direction Inbound -Priority 4096 -SourceAddressPrefix * `
                -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

            New-AzNetworkSecurityGroup -ResourceGroupName "RG_Networking" -Location $Location -Name "NSG_Firewall_External" -SecurityRules $rule1,$rule2,$rule3,$rule4 | Out-Null

            #PublicIP
            New-AzPublicIpAddress -Name "FGT_PublicIP" -ResourceGroupName "RG_Networking" -Location $Location -Sku Basic -AllocationMethod Static -IpAddressVersion IPv4 | Out-Null

            #ARM TEMPLATE
            New-AzResourceGroupDeployment -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -ResourceGroupName RG_Networking | Out-Null

            #NETWORK INTERFACE TIDY UP
            $NIC1 = (get-azNetworkInterface)[0]
            $NIC2 = (Get-AzNetworkInterface)[1]
            $NSG1 = Get-AzNetworkSecurityGroup | Where-Object name -like "NSG*"
            $NSG2 = Get-AzNetworkSecurityGroup | Where-Object name -notlike "NSG*"
            $NIC1.NetworkSecurityGroup = $NSG1
            $NIC1 | Set-AzNetworkInterface | Out-Null
            $NIC2.NetworkSecurityGroup = $NSG1
            $NIC2 | Set-AzNetworkInterface | Out-Null
            $NSG2 | Remove-AzNetworkSecurityGroup -force

            #Remove Route

            <#
            #Internal FGT interface
            $GetInternalNIC = Get-AzVirtualNetwork
            $SubnetID = $GetInternalNIC.subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty Id
            New-AzNetworkInterface -Name "INT_FGT_NWI" -ResourceGroupName "RG_Networking" -Location $Location -SubnetId $SubnetID -EnableIPForwarding | Out-Null

            #External FGT Interface
            $PublicIP = (Get-AzPublicIpAddress).Id
            $NSG = (Get-AzNetworkSecurityGroup).Id
            $GetExternalNICSubnet = Get-AzVirtualNetwork
            $SubnetID = $GetExternalNICSubnet.subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty Id
            New-AzNetworkInterface -Name "EXT_FGT_NWI" -ResourceGroupName "RG_Networking" -Location $Location -SubnetId $SubnetID -PublicIpAddressId $PublicIP -NetworkSecurityGroupId $NSG -EnableIPForwarding | Out-Null
            #>
            <#
            Get-AzVMImage -Location australiaeast -PublisherName Fortinet -Offer fortinet_fortigate-vm_v5 -Skus fortinet_fg-vm_payg_2022 -Version 7.2.1
            
            #agree to terms
            $agreementTerms = Get-AzMarketplaceterms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm_payg_2022"
            Set-AzMarketplaceTerms -Publisher "Fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm_payg_2022" -Terms $agreementTerms -Accept

            $vmConfig = New-AzVMConfig -VMName "FGT-VM-01" -VMSize Standard_DS1_v2
            $offername = "fortinet_fortigate-vm_v5"
            $skuname = "fortinet_fg-vm_payg_2022"
            $version = "2.7.1"
            $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName Fortinet -Offer $offername -Skus $skuname -Version $version

            #create storage account in sub_server
            {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccounts_tawdiagnostics_name": {
            "defaultValue": "tawdiagnostics",
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2022-05-01",
            "name": "[parameters('storageAccounts_tawdiagnostics_name')]",
            "location": "australiasoutheast",
            "sku": {
                "name": "Standard_LRS",
                "tier": "Standard"
            },
            "kind": "StorageV2",
            "properties": {
                "minimumTlsVersion": "TLS1_2",
                "allowBlobPublicAccess": true,
                "networkAcls": {
                    "bypass": "AzureServices",
                    "virtualNetworkRules": [],
                    "ipRules": [],
                    "defaultAction": "Allow"
                },
                "supportsHttpsTrafficOnly": true,
                "encryption": {
                    "services": {
                        "file": {
                            "keyType": "Account",
                            "enabled": true
                        },
                        "blob": {
                            "keyType": "Account",
                            "enabled": true
                        }
                    },
                    "keySource": "Microsoft.Storage"
                },
                "accessTier": "Hot"
            }
        },
        {
            "type": "Microsoft.Storage/storageAccounts/blobServices",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('storageAccounts_tawdiagnostics_name'), '/default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_tawdiagnostics_name'))]"
            ],
            "sku": {
                "name": "Standard_LRS",
                "tier": "Standard"
            },
            "properties": {
                "cors": {
                    "corsRules": []
                },
                "deleteRetentionPolicy": {
                    "allowPermanentDelete": false,
                    "enabled": false
                }
            }
        },
        {
            "type": "Microsoft.Storage/storageAccounts/fileServices",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('storageAccounts_tawdiagnostics_name'), '/default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_tawdiagnostics_name'))]"
            ],
            "sku": {
                "name": "Standard_LRS",
                "tier": "Standard"
            },
            "properties": {
                "protocolSettings": {
                    "smb": {}
                },
                "cors": {
                    "corsRules": []
                },
                "shareDeleteRetentionPolicy": {
                    "enabled": true,
                    "days": 7
                }
            }
        },
        {
            "type": "Microsoft.Storage/storageAccounts/queueServices",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('storageAccounts_tawdiagnostics_name'), '/default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_tawdiagnostics_name'))]"
            ],
            "properties": {
                "cors": {
                    "corsRules": []
                }
            }
        },
        {
            "type": "Microsoft.Storage/storageAccounts/tableServices",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('storageAccounts_tawdiagnostics_name'), '/default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_tawdiagnostics_name'))]"
            ],
            "properties": {
                "cors": {
                    "corsRules": []
                }
            }
        },
        {
            "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('storageAccounts_tawdiagnostics_name'), '/default/bootdiagnostics-tawazured-8eec9ea9-1f55-41df-be74-d1305bd6c766')]",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts/blobServices', parameters('storageAccounts_tawdiagnostics_name'), 'default')]",
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_tawdiagnostics_name'))]"
            ],
            "properties": {
                "immutableStorageWithVersioning": {
                    "enabled": false
                },
                "defaultEncryptionScope": "$account-encryption-key",
                "denyEncryptionScopeOverride": false,
                "publicAccess": "None"
            }
        },
        {
            "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
            "apiVersion": "2022-05-01",
            "name": "[concat(parameters('storageAccounts_tawdiagnostics_name'), '/default/bootdiagnostics-tawazured-cf5f4c4c-f2d9-446a-a9de-02e7c68b988e')]",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts/blobServices', parameters('storageAccounts_tawdiagnostics_name'), 'default')]",
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_tawdiagnostics_name'))]"
            ],
            "properties": {
                "immutableStorageWithVersioning": {
                    "enabled": false
                },
                "defaultEncryptionScope": "$account-encryption-key",
                "denyEncryptionScopeOverride": false,
                "publicAccess": "None"
            }
        }
    ]
}
            #>
        }

    }

    END {

    }
    
}