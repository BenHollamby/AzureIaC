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
        [string]$Location = "australiaeast",

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName='vnet',
            HelpMessage = "Please enter the IPv4 address space. Default is 10.0.0.0/16"
        )]
        [ArgumentCompleter({'10.0.0.0/16','172.32.0.0/16','192.168.128.0/21'})]
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
            
            $AddressPrefix = Read-Host "Please enter the IPv4 address space: "
            $sub_ProtectedSN = Read-Host "Please enter the subnet address for sub_Protected: "
            #$sub_ProtectedSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Protected
            $sub_ExternalSN = Read-Host "Please enter the subnet address for sub_External: "
            #$sub_ExternalSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_External
            $sub_InternalSN = Read-Host "Please enter the subnet address for sub_Internal: "
            #$sub_InternalSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Internal
            $sub_StorageSN = Read-Host "Please enter the subnet address for sub_Storage: "
            #$sub_StorageSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Storage
            $sub_VirtualDesktopSN = Read-Host "Please enter the subnet address for sub_VirtualDesktop: "
            #$sub_VirtualDesktopSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_VirtualDesktop
            $sub_ServerSN = Read-Host "Please enter the subnet address for sub_Server: "
            #$sub_ServerSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Server

            $VirtualNetwork = New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -Location $Location -AddressPrefix $AddressPrefix

            $sub_protected = New-AzVirtualNetworkSubnetConfig -Name 'sub_Protected' -AddressPrefix $sub_ProtectedSN
            $VirtualNetwork.Subnets.Add($sub_Protected)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_External = New-AzVirtualNetworkSubnetConfig -Name 'sub_External' -AddressPrefix $sub_ExternalSN
            $VirtualNetwork.Subnets.Add($sub_External)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_Internal = New-AzVirtualNetworkSubnetConfig -Name 'sub_Internal' -AddressPrefix $sub_InternalSN
            $VirtualNetwork.Subnets.Add($sub_Internal)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_Storage = New-AzVirtualNetworkSubnetConfig -Name 'sub_Storage' -AddressPrefix $sub_StorageSN
            $VirtualNetwork.Subnets.Add($sub_Storage)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_VirtualDesktop = New-AzVirtualNetworkSubnetConfig -Name 'sub_VirtualDesktop' -AddressPrefix $sub_VirtualDesktopSN
            $VirtualNetwork.Subnets.Add($sub_VirtualDesktop)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

            $sub_Server = New-AzVirtualNetworkSubnetConfig -Name 'sub_Server' -AddressPrefix $sub_ServerSN
            $VirtualNetwork.Subnets.Add($sub_Server)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

        
        } 
        
        if ($VNet) {
            
            $VirtualNetworks = New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -AddressPrefix $VNet -Location $Location

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
            $sub_InternalSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Internal -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_InternalSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_StorageSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Storage -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_StorageSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_VirtualDesktopSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_VirtualDesktop -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_VirtualDesktopSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ServerSN1 = New-AzVirtualNetworkSubnetConfig -Name sub_Server -AddressPrefix $Subnet #| Out-Null
            $VirtualNetworks.Subnets.Add($sub_ServerSN1)
            Set-AzVirtualNetwork -VirtualNetwork $VirtualNetworks | Out-Null
            
            
        }

    }

    END {

    }
    
}