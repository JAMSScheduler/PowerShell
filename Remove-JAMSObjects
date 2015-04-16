<#
.Synopsis
   Deletes all objects in a JAMS Folder
.DESCRIPTION
   Deletes all objects in a JAMS Folder including subfolders.
.EXAMPLE
   Remove-AllJAMSObjects JAMS::localhost\Folder1\Folder2\
.EXAMPLE
   Remove-AllJAMSObjects JAMS::localhost\Folder1\Folder2\ -Verbose
#>
function Remove-JAMSObjects
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $path
    )

    Begin
    {
        Import-Module JAMS
    }
    Process
    {
        $ConfirmPreference = "None"
        $previousItemCount = 0;
        $loopCount = 0
        do
        {
            $items = Get-ChildItem $path -Recurse
            if ($items.Count -eq $previousItemCount)
            {
                $loopCount = $loopCount + 1
            }
            else
            {
                $loopCount = 0
            }
            $previousItemCount = $items.Count
            foreach($item in $items)
            {
                Write-Verbose "Deleting $item - $($item.QualifiedName)"
                $item | Remove-Item -Recurse -ErrorAction Continue -Confirm:$false
            }
            write-verbose "Item count: $($items.Count), loop count: $loopCount"
        } while (($items.Count -gt 0) -and ($loopCount -lt 10))
    }
    End
    {
    }
}
