@echo off
REM Example use of MoveFromPhone.ps1 to move pictures from a phone onto computer
REM
REM This Windows Command Line script is provided 'as-is', without any express or implied warranty.
REM In no event will the author be held liable for any damages arising from the use of this script.
REM
REM Again, please note that when used with the 'MoveFromPhone.ps1' as originally written,
REM files will be MOVED from you phone: they will be DELETED from the sourceFolder (the phone)
REM and MOVED to the targetFolder (on the computer).
REM
powershell Set-ExecutionPolicy RemoteSigned -scope currentuser
REM Camera files
powershell.exe "& '%~dp0CopyFromPhone.ps1' -phoneName 'Huawei P10' -sourceFolder 'Interner Speicher\DCIM\Camera' -targetFolder 'C:\Users\Public\Pictures\Camera'"
pause