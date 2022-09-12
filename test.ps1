$InternalIPRange = ($internal = Get-AzVirtualNetwork).subnets | Where-Object name -eq sub_External | Select-Object -ExpandProperty addressprefix 
$iir = $InternalIPRange.split(".").Split("/")
$a,$b,$c,$d,$e = $iir[0], $iir[1], $iir[2], $iir[3], $iir[4]
$d = 4
$NextHopIPAddress = $a + "." + $b + "." + $c + "." + $d

$Route = New-AzRouteConfig -Name "test-route" -AddressPrefix 0.0.0.0/0 -NextHopType VirtualAppliance -NextHopIpAddress $NextHopIPAddress
New-AzRouteTable -Name "RouteTable01" -ResourceGroupName "RG_Networking" -Location "australiaeast" -Route $Route

#Set-AzVirtualNetworkSubnetConfig -VirtualNetwork VN_Core