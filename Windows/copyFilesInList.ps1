# Define File List location
# absolute Path, e.g. "C:\Users\fileList.txt", or just filename ( then script and filename must be at the same location )
$strFileListLoc="C:\ExampleFileList.txt";

# Shall files in target be overwritten? (please insert $true or $false)
$b_overwrite_Target=$false;

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
            # Add slash ("\") to the target folder if not exist 
            if (-not($strTarget[-1] -eq "\")){
                $strTarget="$strTarget\"
            }
            
            # Check if TargetFolder already exists
            if (-not(Test-Path $strTarget -PathType Container)){
                # Create Target Folder, Output-Text should not be displayed (Out-Null)
                mkdir $strTarget | Out-Null;
            }

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
            $strTargetPath = (Split-Path $strTarget);
            # Check if TargetFolder already exists
            if (-not(Test-Path $strTargetPath -PathType Container)){
                # Create Target Folder, Output-Text should not be displayed (Out-Null)
                mkdir $strTargetPath | Out-Null;
                Write-Host -ForegroundColor Green "Copy $strSource to $strTarget"
                Copy-Item $strSource -Destination $strTarget;
            
            # TargetFolder already exist    
            } else {
                # Check if target file already exists
                if ((-not(Test-Path $strTarget -PathType Leaf)) -or $b_overwrite_Target){
                    Write-Host -ForegroundColor Green "Copy $strSource to $strTarget, overwriting file if exists";
                    Copy-Item $strSource -Destination $strTarget;
                } else {
                    Write-Host -ForegroundColor Yellow "$strTarget already exists, NOT overwriting it";
                }
            }
        }
        
    } else {
        Write-Host -ForegroundColor Yellow "Source File Location $($strSource) does not exists!";
    }
}

