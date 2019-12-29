 ############################# Copy New folders only ############################################
#
# Purpose: This script facilitates to ensure that the folder hierarchy is in sync from local
# backup folder structure, to a destination folder structure. If this is not done, on a periodic
# basis, your backup files copy script or job will fail or not write files to destination due to 
# folder doesn't exist issue.
#
# This script ensures that backup folders (top level and sub folders below) on primary (SQL) server,
# are created on the secondary server as well. The folder hierarchy is created by Ola's backup
# jobs. In order for the backup files to be copied to secondary server, or a network file server,
# the secondary server (or the NAS / file server) needs to have exact same folder structure.
# This script traverses the folders on the source server and creates the folder structure (skeleton)
# on the secondary or network file server.
#
# How to Setup?
# There are two variables to setup
# $localBackupPath - This is the folder where SQL jobs are writing to.
#    Note: LocalBackupPath Variable must end in \ - example: C:\Backup\
# $dest - This variable takes the drive letter (example S:\), or you could use
#    UNC path, to your destination folder where backup files from your local backup folder will be copied to.
#    Note: This variable needs to be entered inside of single quotes.  
# Please make sure that there is a \ at the end of folder path or the UNC path
#    Example - S:\ or \\server\share\
# Please make sure that the destination folder has share/NTFS permissions setup to allow local service that  
# runs the SQL Agent service can write to remote folders. If you run in a workgroup environment without AD, 
# ensure that remote folder share has read/write share permissions allowed for Everyone group. or something better.
# 
# This script will only create folders at destination, when there is no equivalent folder found at destination 
# The script will skip creating folders at destination, if destination already has the folders
#
# When to run this script?
# Ideally, you could run this script once a week or even once a day or whenever you add/change your SQL backup jobs.
# Remember that this script copies just the folder structure (only changed ones that doesnt exist in destination)
# so that the script that copies files from local to remote server share can run without issues. so its important to
# to run this as often as you expect changes. We recommend at least once a week or daily once.
# You should run this script, before running the sql backup copy script because this creates the folder structure
# at the destination server so that the sql backup copy job can run effectively.
#
# ####################### Configurable Parameters ####################################
#
$localBackupPath=""
$dest = "\\PROD-WCS-APP02\SQL-Ola\"
#
# ###################################################################################
#
Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "Folder Mover - Script Started." -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "START -> Date and Time: " (Get-Date -DisplayHint Date) -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor White -BackgroundColor DarkCyan
$hname= hostname
$source = "$localBackupPath"+"$hname"
$count = 0
Write-Host "Comparing $source folder, and its subfolders with $dest" -ForegroundColor White -BackgroundColor DarkGray
Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor White -BackgroundColor DarkCyan
dir $source -Recurse | ForEach-Object {
    
    $sourcefile = $_.FullName
    #"sourcefile = $sourcefile"
    $destfolder = split-path -path $sourcefile
    #"destfolder = $destfolder"
    $destpath = $dest + $destfolder.Remove(0,10)
    #"dest path = $destpath"
    $chkdest = Test-Path -Path $destpath 
    #"check dest $chkdest"
    
    if($chkdest) {
        Write-Host "Folder $destpath already exists in destination, moving onto next" -ForegroundColor White -BackgroundColor DarkGray
        }
    else {
        $count+=1

        Write-Host "Folder $destpath doesn't exist. So, Creating the folder." -ForegroundColor White -BackgroundColor DarkGray
        new-item $destpath -itemtype directory -Force
    }
}
If(-Not $count -eq 0){
Write-Host "Total $count folders were created. " -ForegroundColor White -BackgroundColor DarkGray
}
Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "Folder Mover Script Processing complete." -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "Completed -> Date and Time: " (Get-Date -DisplayHint Date) -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor White -BackgroundColor DarkCyan

 
