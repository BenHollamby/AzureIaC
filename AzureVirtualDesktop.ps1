#Search through and remove all .rdpw files
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object name -like *.rdpw | Remove-Item -Force
#Add Shortcut to Desktop
$Shell = New-Object -ComObject ("WScript.Shell")
$Favorite = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Azure Virtual Desktop.url")
$Favorite.TargetPath = "https://client.wvd.microsoft.com/arm/webclient/index.html";
$Favorite.Save()