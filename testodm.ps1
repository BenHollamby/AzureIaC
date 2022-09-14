$ErrorActionPreference = 'SilentlyContinue'

#H-Drive
if (!(Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop")) {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Desktop -ItemType Directory
}
if (!(Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\My Documents")) {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Documents -ItemType Directory
}
if (!(Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads")) {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Downloads -ItemType Directory
}
Copy-Item -Path H:\Desktop\* -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop\" -Recurse
Copy-Item -Path H:\Downloads\* -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads\" -Recurse
Get-ChildItem "My Documents" | Copy-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\"
Get-ChildItem | Where-Object {$_.Name -notin 'Desktop','Downloads','My Documents'} | Copy-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\"

#Desktop
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Desktop -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop"
Get-ChildItem $env:USERPROFILE\Desktop | Move-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop\"

#Documents
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents"
Get-ChildItem $env:USERPROFILE\Documents | Move-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\"

#Downloads
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name '{374DE290-123F-4565-9164-39C4925E467B}' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads"
Get-ChildItem $env:USERPROFILE\Downloads | Move-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads\"

#Pictures
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Pictures' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\My Pictures"
Get-ChildItem $env:USERPROFILE\Documents\Pictures | Move-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\My Pictures\"

#Videos
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Videos' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\My Videos"
Get-ChildItem $env:USERPROFILE\Documents\Videos | Move-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\My Videos\"

#Favorites
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'Favorites' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites"
Get-ChildItem $env:USERPROFILE\Favorites | Move-Item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites\"

#Music
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Music' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Music"
Get-ChildItem $env:USERPROFILE\Documents\Music | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\My Music\"


Start-Sleep 10
Restart-Computer -Force