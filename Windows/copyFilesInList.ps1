# Define File List location
# absolute Path, e.g. C:\Users\sebastian\Desktop\fileList.txt, or just filename ( then script and filename must be at the same location )
$strFileListLoc="C:\ExampleFileList.txt";

# Shall files in target be overwritten (please insert $true or $false)
$b_overwrite_Target=$true;

# Read out FileList and ignoring Lines starting with "#" (=Comment Lines)
$lstFileList=(Get-Content -Path $strFileListLoc) -notmatch '^#';

foreach($strLine in $lstFileList){
    # $strLocations from type array,  $strLocations[0] = Source, $strLocations[1] = Target
    # Possible sources are file locations or SourcePath/* for copy the hole directory including all subtrees and files
    $strLocations = $strLine.Split("=");
    $strSource = $strLocations[0].Trim('"');
    $strTarget = $strLocations[1].Trim('"');
    

    # Check if source file or source location exists
    if (Test-Path $strSource -PathType Leaf){
        # Check if Source is a folder
        if ($strSource[-1] -eq "*"){
            # Check if overwrite-mode is turned on
            if ($b_overwrite_Target){
                Write-Host -ForegroundColor Green "Copy $strSource to $strTarget, overwriting files if exists";
                Copy-Item -Path $strSource -Destination $strTarget -Recurse;
            } else {
                # Exclude files in Target if overwrite-mode is turned off
                Write-Host -ForegroundColor Green "Copy $strSource to $strTarget, if files not exists in Target";
                Copy-Item -Path $strSource -Destination $strTarget -Recurse -Exclude (Get-ChildItem $strTarget);
            }
        
        # Source must be a single file
        } else {
            # Check if overwrite-mode is turned on
            if ($b_overwrite_Target){
                Write-Host -ForegroundColor Green "Copy $strSource to $strTarget, overwriting file if exists";
                Copy-Item $strSource -Destination $strTarget;
             
             # Overwrite-mode is turned off
             } else {
                # Check if target file already exists
                if (-not(Test-Path $strTarget -PathType Leaf)){
                    $strTargetPath = (Split-Path $strTarget);
                    # Check if TargetFolder already exists
                    if (-not(Test-Path $strTargetPath -PathType Container)){
                        # Create Target Folder, Output-Text should not be displayed (Out-Null)
                        mkdir $strTargetPath | Out-Null;
                        Write-Host -ForegroundColor Green "Copy $strTarget to $strTarget"
                    }
                    Copy-Item $strSource -Destination $strTarget;
                # File already exists 
                } else {
                    Write-Host -ForegroundColor Yellow "$strTarget already exists, NOT overwriting it";
                }
             }
         }
        
    } else {
        Write-Host -ForegroundColor Yellow "Source File Location $($strSource) does not exists!";
    }
}
