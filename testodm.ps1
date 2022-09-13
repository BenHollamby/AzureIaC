$ErrorActionPreference = 'SilentlyContinue'

#H-Drive
$HDrive = (Get-PSDrive -Name H).DisplayRoot
$UserOD = Get-Item -Path $env:USERPROFILE\'OneDrive - South Waikato District Council'\
Copy-Item -Path $HDrive -Destination $UserOD -Recurse

#Desktop
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Desktop -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop"
    Get-ChildItem $env:USERPROFILE\Desktop | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Desktop -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Desktop -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop"
    Get-ChildItem $env:USERPROFILE\Desktop | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Desktop\"

}

#Documents
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents"
    Get-ChildItem $env:USERPROFILE\Documents | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Documents -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Personal -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents"
    Get-ChildItem $env:USERPROFILE\Documents | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\"

}

#Downloads
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name '{374DE290-123F-4565-9164-39C4925E467B}' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads"
    Get-ChildItem $env:USERPROFILE\Downloads | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Downloads -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads"
    Get-ChildItem $env:USERPROFILE\Downloads | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Downloads\"

}

#Pictures
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Pictures") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Pictures' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Pictures"
    Get-ChildItem $env:USERPROFILE\Documents\Pictures | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Pictures\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\" -Name Pictures -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Pictures' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Pictures"
    Get-ChildItem $env:USERPROFILE\Documents\Pictures | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Pictures\"

}

#Videos
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Videos") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Videos' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Videos"
    Get-ChildItem $env:USERPROFILE\Documents\Videos | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Videos\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\" -Name Videos -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Videos' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Videos"
    Get-ChildItem $env:USERPROFILE\Documents\Videos | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Videos\"

}

#Favorites
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'Favorites' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites"
    Get-ChildItem $env:USERPROFILE\Favorites | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\" -Name Favorites -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'Favorites' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites"
    Get-ChildItem $env:USERPROFILE\Favorites | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Favorites\"

}

#Music
if (Test-Path -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Music") {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Music' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Music"
    Get-ChildItem $env:USERPROFILE\Documents\Music | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Music\"

} else {
    New-Item -Path "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\" -Name Music -ItemType Directory
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name 'My Music' -Value "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Music"
    Get-ChildItem $env:USERPROFILE\Documents\Music | move-item -Destination "$env:USERPROFILE\OneDrive - South Waikato District Council\Documents\Music\"

}

Start-Sleep 10
Restart-Computer -Force