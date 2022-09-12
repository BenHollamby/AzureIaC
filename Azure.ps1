Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
function New-IASetup {

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

            $InternalSN = ($Internal = Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty addressprefix
            $iip = $InternalSN.split(".").split("/")
            $a,$b,$c,$d,$e = $iip[0], $iip[1], $iip[2], $iip[3], $iip[4]
            $d = 4
            $NextHopIP = $a + "." + $b + "." + $c + "." + $d
           
            Get-AzRouteTable -ResourceGroupName "RG_Networking" -Name "Route-Table" | Add-AzRouteConfig -Name "Default-Route" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $NextHopIP | Set-AzRouteTable | Out-Null

            #NSG
            $ExternalIPRange = ($external = Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix 
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
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ExternalSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_External -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_ExternalSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null
            

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_InternalSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Internal -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_InternalSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_StorageSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Storage -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_StorageSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_VirtualDesktopSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_VirtualDesktop -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_VirtualDesktopSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ServerSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Server -AddressPrefix $Subnet -RouteTable $RouteTable #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_ServerSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $InternalSN = ($Internal = Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty addressprefix
            $iip = $InternalSN.split(".").split("/")
            $a,$b,$c,$d,$e = $iip[0], $iip[1], $iip[2], $iip[3], $iip[4]
            $d = 4
            $NextHopIP = $a + "." + $b + "." + $c + "." + $d
           
            Get-AzRouteTable -ResourceGroupName "RG_Networking" -Name "Route-Table" | Add-AzRouteConfig -Name "Default-Route" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $NextHopIP | Set-AzRouteTable | Out-Null

            #NSG
            $ExternalIPRange = ($external = Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix 
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

        }

    }

    END {

    }
    
}


#idiot proof needed in custom

#Custom needs location prompt

<#
$vnet = Get-AzVirtualNetwork
$rt = get-azroutetable
$subnet = New-AzVirtualNetworkSubnetConfig -name 'sub-protty' -AddressPrefix 10.0.2.0/24 -RouteTable $rt
$vnet.Subnets.Add($subnet)
Set-AzVirtualNetwork -VirtualNetwork $vnet





#Get-AzRouteTable -ResourceGroupName "RG_Networking" -Name "Route-Table" | Add-AzRouteConfig -Name "Default-Route1" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $nexthopip | Set-AzRouteTable
#>