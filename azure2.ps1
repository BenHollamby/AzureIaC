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

            New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -Location $Location -AddressPrefix $AddressPrefix -Subnet $sub_ProtectedSN, $sub_ExternalSN, $sub_InternalSN, $sub_StorageSN, $sub_VirtualDesktopSN, $sub_ServerSN -Force:$true | Out-Null
            #$updatevnet | Set-AzVirtualNetwork | Out-Null
        
        } 
        
        if ($VNet) {
            
            New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -AddressPrefix $VNet -Location $Location | Out-Null

        }

        if ($Subnet) {

            $sub_ProtectedSN = New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $Subnet | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ExternalSN = New-AzVirtualNetworkSubnetConfig -Name sub_External -AddressPrefix $Subnet | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_InternalSN = New-AzVirtualNetworkSubnetConfig -Name sub_Internal -AddressPrefix $Subnet | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_StorageSN = New-AzVirtualNetworkSubnetConfig -Name sub_Storage -AddressPrefix $Subnet | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_VirtualDesktopSN = New-AzVirtualNetworkSubnetConfig -Name sub_VirtualDesktop -AddressPrefix $Subnet | Out-Null

            $sc = $Subnet.Split(".").Split("/")
            $a,$b,$c,$d,$e = $sc[0],$sc[1],$sc[2],$sc[3],$sc[4]
            $c = [int]$c + 1
            $e = 24
            $subnet = $a + "." + $b + "." + $c + "." + $d + "/" + $e
            $sub_ServerSN = New-AzVirtualNetworkSubnetConfig -Name sub_Server -AddressPrefix $Subnet | Out-Null

            $updatevnet = New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -Location $Location -AddressPrefix $VNet -Subnet $sub_ProtectedSN, $sub_ExternalSN, $sub_InternalSN, $sub_StorageSN, $sub_VirtualDesktopSN, $sub_ServerSN -Force:$true | Out-Null
            $updatevnet | Set-AzVirtualNetwork | Out-Null
            }
        
    }

    END {

    }
}