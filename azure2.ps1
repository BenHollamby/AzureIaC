function New-IASetup {

    [cmdletbinding()]

    param(

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = "Please enter region to deploy to, default is Australia East"
        )]
        [ArgumentCompleter({'australiaeast', 'australiasoutheast'})] #add more comma seperated regions here run "get-azlocation | Select-Object location" to get list all regions
        [string]$Location = "australiaeast",

        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = "Please enter the IPv4 address space. Default is 10.0.0.0/16"
        )]
        [ArgumentCompleter({'10.0.0.0/16','172.32.0.0/16','192.168.128.0/21'})]
        [string]$VNet = "10.0.0.0/16"

    )

    BEGIN {

        New-AzResourceGroup -Location $Location -Name "RG_Backup"         | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Networking"     | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Server"         | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Storage"        | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_VirtualDesktop" | Out-Null
        
    }

    PROCESS {

        $AddressPrefix = Read-Host "Please enter the IPv4 address space: "
        New-AzVirtualNetwork -Name VN_Core -ResourceGroupName RG_Networking -AddressPrefix $AddressPrefix -Location $Location | Out-Null
        $sub_Protected = Read-Host "Please enter the subnet address for sub_Protected within $AddressPrefix range: "
        New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Protected | Out-Null
        $sub_External = Read-Host "Please enter the subnet address for sub_External within $AddressPrefix range: "
        New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_External | Out-Null
        $sub_Internal = Read-Host "Please enter the subnet address for sub_Ixternal within $AddressPrefix range: "
        New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Internal | Out-Null
        $sub_Storage = Read-Host "Please enter the subnet address for sub_Storage within $AddressPrefix range: "
        New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Storage | Out-Null
        $sub_VirtualDesktop = Read-Host "Please enter the subnet address for sub_VirtualDesktop within $AddressPrefix range: "
        New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_VirtualDesktop | Out-Null
        $sub_Server = Read-Host "Please enter the subnet address for sub_Server within $AddressPrefix range: "
        New-AzVirtualNetworkSubnetConfig -Name sub_Protected -AddressPrefix $sub_Server | Out-Null
    }

    END {

    }
}