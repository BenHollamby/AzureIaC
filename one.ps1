#H-DRIVE
$HDrive = (Get-PSDrive -Name H).DisplayRoot
$UserOD = Get-Item -Path $env:USERPROFILE\'OneDrive - South Waikato District Council'\
Copy-Item -Path $HDrive -Destination $UserOD -Recurse -ErrorAction SilentlyContinue

#Documents
$Documents = "$env:USERPROFILE\Documents"
$ODDocuments = "C:\Users\$env:USERNAME\OneDrive - South Waikato District Council\Documents"
Move-Item $Documents $ODDocuments -force -ErrorAction SilentlyContinue

#Desktop
$Desktop = "$env:USERPROFILE\Documents"
$ODDesktop = "C:\Users\$env:USERNAME\OneDrive - South Waikato District Council\Desktop"
Move-Item $Desktop $ODDesktop -force -ErrorAction SilentlyContinue

#Pictures
$Pictures = "$env:USERPROFILE\Documents"
$ODPictures= "C:\Users\$env:USERNAME\OneDrive - South Waikato District Council\Pictures"
Move-Item $Pictures $ODPictures -force -ErrorAction SilentlyContinue

#Downloads
$Downloads = "$env:USERPROFILE\Documents"
$ODDownloads= "C:\Users\$env:USERNAME\OneDrive - South Waikato District Council\Downloads"
Move-Item $Downloads $ODDownloads -force -ErrorAction SilentlyContinue


Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Desktop -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}" -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop"

Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Favorites -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name "My Pictures" -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Pictures"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name "My Videos" -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Videos"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents"