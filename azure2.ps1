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
        [string]$Location = "australiaeast"

    )

    BEGIN {

        New-AzResourceGroup -Location $Location -Name "RG_Backup"         | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Networking"     | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Server"         | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_Storage"        | Out-Null
        New-AzResourceGroup -Location $Location -Name "RG_VirtualDesktop" | Out-Null
        
    }

    PROCESS {

    }

    END {

    }
}