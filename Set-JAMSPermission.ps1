#this script can be used to automate the setting of folder level permissions in JAMS
Import-Module JAMS

#set JAMS server or use your $JAMSDefaultServer
CD JAMS::$JAMSDefaultServer

#this function is designed to apply permission to JAMS Folder defintions
function Set-JAMSPermission
{
    PARAM
    (
        [parameter(Mandatory=$True)]
        [STRING]$folderName,
        [parameter(Mandatory=$True)]
        [bool]$abort = $false,
        [parameter(Mandatory=$True)]
        [bool]$addJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$change = $false,
        [parameter(Mandatory=$True)]
        [bool]$changeJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$control = $false,
        [parameter(Mandatory=$True)]
        [bool]$debugPerm = $false,
        [parameter(Mandatory=$True)]
        [bool]$delete = $false,
        [parameter(Mandatory=$True)]
        [bool]$deleteJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$inquire = $false,
        [parameter(Mandatory=$True)]
        [bool]$inquireJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$manage = $false,
        [parameter(Mandatory=$True)]
        [bool]$monitor = $false,
        [parameter(Mandatory=$True)]
        [bool]$submit = $false,
        [parameter(Mandatory=$True)]
        [STRING]$user
    )

    # Create a new Folder / Get folder that already exists
    if (Test-Path $folderName)
    {
     $newFolder = Get-Item -Path $folderName
    }
    else
    {
     $newFolder = New-Item -ItemType Folder -Name $folderName
    }
    
    #Write-Host $newFolder

    #$newfolder.Description = 'Owner=Platform;Type=Audit'
    #$newfolder.RetainOption = 'Always'

    $ace = New-Object MVPSI.JAMS.GenericACE
    $ace.Identifier = $user
    #$ace.AccessBits = ([MVPSI.JAMS.FolderAccess]::Abort -bor [MVPSI.JAMS.FolderAccess]::AddJobs -bor [MVPSI.JAMS.FolderAccess]::Change -bor [MVPSI.JAMS.FolderAccess]::ChangeJobs -bor [MVPSI.JAMS.FolderAccess]::Control -bor [MVPSI.JAMS.FolderAccess]::Debug -bor [MVPSI.JAMS.FolderAccess]::Delete -bor [MVPSI.JAMS.FolderAccess]::DeleteJobs -bor [MVPSI.JAMS.FolderAccess]::Inquire -bor [MVPSI.JAMS.FolderAccess]::InquireJobs -bor [MVPSI.JAMS.FolderAccess]::Manage -bor [MVPSI.JAMS.FolderAccess]::Monitor -bor [MVPSI.JAMS.FolderAccess]::Submit)

    $ace.AccessBits = [MVPSI.JAMS.FolderAccess]([int][MVPSI.JAMS.FolderAccess]::Abort * $abort +
        [int][MVPSI.JAMS.FolderAccess]::AddJobs * $addJobs +
        [int][MVPSI.JAMS.FolderAccess]::changeJobs * $changeJobs +
        [int][MVPSI.JAMS.FolderAccess]::change * $change +
        [int][MVPSI.JAMS.FolderAccess]::control * $control +
        [int][MVPSI.JAMS.FolderAccess]::debug * $debugPerm +
        [int][MVPSI.JAMS.FolderAccess]::delete * $delete +
        [int][MVPSI.JAMS.FolderAccess]::deleteJobs * $deleteJobs +
        [int][MVPSI.JAMS.FolderAccess]::inquire * $inquire +
        [int][MVPSI.JAMS.FolderAccess]::inquireJobs * $inquireJobs +
        [int][MVPSI.JAMS.FolderAccess]::manage * $manage +
        [int][MVPSI.JAMS.FolderAccess]::monitor * $monitor +
        [int][MVPSI.JAMS.FolderAccess]::submit * $submit)

    $newfolder.ACL.GenericACL.Add($ace)

    $newfolder.Update()

    # Save the Folder
    $newFolder.Update();
}

Set-JAMSPermission -folderName 'Samples' -abort $true -addJobs $true -change $true -changeJobs $true -control $true -debugPerm $true -delete $true -deleteJobs $true -inquire $true -inquireJobs $true -manage $true -monitor $true -submit $true -user 'MVP\Admins' -Verbose
Set-JAMSPermission -folderName 'Samples' -abort $false -addJobs $false -change $false -changeJobs $false -control $false -debugPerm $false -delete $false -deleteJobs $false -inquire $true -inquireJobs $true -manage $false -monitor $true -submit $false -user 'MVP\Readers' -Verbose
