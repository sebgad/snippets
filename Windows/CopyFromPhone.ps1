# Windows powershell script to automate one-way copy between mobile phone and desktop pc
# Reference: https://www.pstips.net/access-file-system-against-mtp-connection.html
# Reference: https://powershell.org/forums/topic/powershell-mtp-connections/
#
# Disclaimer:
# This Powershell script is provided 'as-is', without any express or implied warranty.
# In no event will the author be held liable for any damages arising from the use of this script.

param([string]$strPhoneName='HUAWEI P10',
      [string]$strSourceFolder='\SanDisk-Speicherkarte\DCIM\Camera',
      [string]$strTargetFolder='C:\Users\sebastian\Desktop\Test')
 
function Get-ShellProxy
<#
#>
{
    if( -not $global:ShellProxy)
    {
        $global:ShellProxy = new-object -com Shell.Application
    }
    $global:ShellProxy
}
 
function Get-Phone
<#
return Phone Object from defined shell proxy and defined phone name as string.
#>
{
    param([string]$str_phone_name)
    $obj_shell = Get-ShellProxy
    # 17 (0x11) = ssfDRIVES from the ShellSpecialFolderConstants (https://msdn.microsoft.com/en-us/library/windows/desktop/bb774096(v=vs.85).aspx)
    # => "My Computer" — the virtual folder that contains everything on the local computer: storage devices, printers, and Control Panel.
    # This folder can also contain mapped network drives.
    $obj_shell_item = $obj_shell.NameSpace(17).self
    $obj_phone = $obj_shell_item.GetFolder.items() | where { $_.name -eq $str_phone_name }
    return $obj_phone
}
 
function Get-SubFolder
<#
Get subfolders from a defined path string
#>
{
    param($obj_parent,
          [string]$str_path)

    $str_path_parts = @( $str_path.Split([system.io.path]::DirectorySeparatorChar) )
    $obj_current = $obj_parent
    
    foreach ($str_path_part in $str_path_parts)
    {
        if ($str_path_part)
        {
            $obj_current = $obj_current.GetFolder.items() | where { $_.Name -eq $str_path_part }
        }
    }
    return $obj_current
}


$objPhone = Get-Phone -str_phone_name $strPhoneName
$objSourceFolder = Get-SubFolder -obj_parent $objPhone -str_path $strSourceFolder

$objItems = $objSourceFolder.GetFolder.Items()
$iCpyItems = 0

if ($objItems)
{
    Write-Output "creating file list... Please wait"
    $iTotalItems = $objItems.count
    Write-Output "Found in Total $($iTotalItems) files on mobile phone"
    
    if ($iTotalItems -gt 0)
    {
        # If destination path doesn't exist, create it only if we have some items to move
        if (-not (test-path $strTargetFolder) )
        {
            $created = new-item -itemtype directory -path $strTargetFolder
            Write-Output "Folder $($strTargetFolder) does not exists, create new."
        }
 
        Write-Verbose "Processing Path : $strPhoneName\$strSourceFolder"
        Write-Verbose "Copy to : $strTargetFolder"
 
        $objShell = Get-ShellProxy
        $objTargetFolder = $objShell.Namespace($strTargetFolder).self
        $iRunCnt = 0;
        foreach ($objItem in $objItems)
        {
            $strFileName = $objItem.Name
 
            ++$iRunCnt
            $fProgress = [int](($iRunCnt * 100) / $iTotalItems)
            Write-Progress -Activity "Processing Files in $strPhoneName\$strSourceFolder" `
                -status "Processing File ${iRunCnt} / ${iTotalItems} (${fProgress}%)" `
                -CurrentOperation $strFileName `
                -PercentComplete $fProgress
 
            # Check the target file doesn't exist:
            $strTargetFilePath = join-path -path $strTargetFolder -childPath $strFileName

            if (test-path -path "$strTargetFilePath*")
            {
                Write-Verbose "Destination file exists - file not copied:`n`t$strTargetFilePath"
            }
            else
            {
                $objTargetFolder.GetFolder.CopyHere($objItem, 20)
                ++$iCpyItems

                if (test-path -path $strTargetFilePath)
                {
                    # Optionally do something
                }
                else
                {
                    write-verbose "file already exists in destination: $strTargetFilePath"
                }
            }
        }
        Write-Output "In total $($iCpyItems) files were copied"
    }
}
