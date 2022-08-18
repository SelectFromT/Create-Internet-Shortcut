<#
    .SYNOPSIS
    This small script is designed to take a list of destinations, and create shortcuts.
    Author: Tony Habeger (github.com/selectfromt @TonyHabeger)
    Version: 1.0
#>

# List of web links to create shortcuts for (http://,https://, or similar qualifier is required to prevent errors):
$destinationPaths = 'https://google.com/','https://microsoft.com','http://amazon.com'

# Function to pull registry values
function Get-RegistryValue{
    param(
        [parameter(Mandatory=$true)]
        [string]
        $subKeyValue,

        [parameter(Mandatory=$true)]
        [string]
        $baseKeyValue,

        [parameter(Mandatory=$true)]
        [string]
        $subValueName

    )

    # Set registry hive and subkeys
    $registry = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::$baseKeyValue, [Microsoft.Win32.RegistryView]::Default)
    $registryKey = $registry.OpenSubKey($subKeyValue)
    # Get key value
    $keyValue = $registryKey.GetValue($subValueName)

    return $keyValue
}



# Take default browser setting and set the icon image as the default browser's icon
$browserIcon = (Get-RegistryValue -baseKeyValue "CurrentUser" -subKeyValue "SOFTWARE\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice" -subValueName "ProgId")
switch -wildcard ($browserIcon){
    ("*chrome*"){
        $browserIconPath = Get-RegistryValue -baseKeyValue "LocalMachine" -subKeyValue "SOFTWARE\\Classes\\ChromeHTML\\Application" -subValueName "ApplicationIcon"
        $browserIconPath = $browserIconPath.split(",")[0]
        }
    ("*edge*"){
        $browserIconPath = Get-RegistryValue -baseKeyValue "LocalMachine" -subKeyValue "SOFTWARE\\Classes\\MSEdgeHTM\\Application" -subValueName "ApplicationIcon"
        $browserIconPath = $browserIconPath.split(",")[0]
    }

}

# Itterate through the destination paths and create a shortcut for each one. 
foreach($destinationPath in $destinationPaths)
{
    if($destinationPath -imatch '/'){
        $linkName = $destinationPath.Split('/')[2].replace('.','-') + '.lnk'
    }
    else{
        $linkName = $destinationPath.replace('.','-') + '.lnk'
    }

    # Creation of the shortcut
    $shortcutPath = $env:HOMEDRIVE + $env:HOMEPATH + '\Desktop\' + $linkName

    # Invoke WScript to assist in creation.
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $destinationPath
    $shortcut.IconLocation = $browserIconPath
    $shortcut.Save()
}