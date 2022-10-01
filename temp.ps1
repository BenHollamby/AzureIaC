
$swarmvnetaddressprefix = [string](Get-AzVirtualNetwork).AddressSpace.AddressPrefixes

$swarmexternalsubnetprefix = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix

$StartAddress = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix
$StartAddress = $StartAddress.split(".").split("/")
$StartAddress[3] = '4'
$StartAddress = $StartAddress[0] + '.' + $StartAddress[1] + '.' + $StartAddress[2] + '.' + $StartAddress[3] + '/' + $StartAddress[4]
$swarmexternalsubnetstartaddress = $StartAddress


$swarminternalsubnetprefix = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty addressprefix

$StartAddress = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Internal | Select-Object -ExpandProperty addressprefix
$StartAddress = $StartAddress.split(".").split("/")
$StartAddress[3] = '4'
$StartAddress = $StartAddress[0] + '.' + $StartAddress[1] + '.' + $StartAddress[2] + '.' + $StartAddress[3] + '/' + $StartAddress[4]
$swarminternalsubnetstartaddress = $StartAddress

$swarmprotectedsubnetprefix = (Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_Protected | Select-Object -ExpandProperty addressprefix

$swarmlocation = (Get-AzVirtualNetwork).Location

(Get-Content .\test.txt).replace('SWARMVNETADDRESSPREFIX', $swarmvnetaddressprefix) | Set-Content .\test.txt
(Get-Content .\test.txt).replace('SWARMEXTERNALSUBNETPREFIX', $swarmexternalsubnetprefix) | Set-Content .\test.txt
(Get-Content .\test.txt).replace('SWARMEXTERNALSUBNETSTARTADDRESS', $swarmexternalsubnetstartaddress) | Set-Content .\test.txt
(Get-Content .\test.txt).replace('SWARMINTERNALSUBNETPREFIX', $swarminternalsubnetprefix) | Set-Content .\test.txt
(Get-Content .\test.txt).replace('SWARMINTERNALSUBNETSTARTADDRESS', $swarminternalsubnetstartaddress) | Set-Content .\test.txt
(Get-Content .\test.txt).replace('SWARMPROTECTEDSUBNETPREFIX', $swarmprotectedsubnetprefix) | Set-Content .\test.txt
(Get-Content .\test.txt).replace('SWARMLOCATION', $swarmlocation) | Set-Content .\test.txt