Import-Module JAMS -EA Continue

# Get an instance of the JAMS Server
$jamsServer = [MVPSI.JAMS.Server]::GetServer("localhost")

Write-Host "`t`t`tJAMS Object Access Security Report"
Write-host "`t`t`t----------------------------------"

#
# Iterate through the AccessObject Types enumeration
#
foreach($accessType in [Enum]::GetValues([MVPSI.JAMS.AccessObject]))
{
    if($accessType -ne [MVPSI.JAMS.AccessObject]::None)
    {
        #
        # Output AccessObject header
        #
        Write-Host "`n$($accessType.ToString())"
        $accessType.ToString().ToCharArray() | %{Write-Host -NoNewline "-"}
        Write-Host

        #
        # Load the Security for the specified AccessObject
        #
        $sec = New-Object MVPSI.JAMS.Security
        [MVPSI.JAMS.Security]::Load([ref]$sec, $accessType, $jamsServer)

        #
        # Iterate each ACE in the ACL
        #
        foreach ($ace in $sec.Acl.GenericACL)
        { 
            #
            # Append the ACE's access to a string
            #
            $accessNames = ""
            foreach($objectAccess in [Enum]::GetValues([MVPSI.JAMS.ObjectAccess]))
            {
                if (($ace.AccessBits -band $objectAccess) -ne 0)
		{
			$accessNames = $accessNames + "$($objectAccess) "
		}
            }
            
	    #
            # Output the ACE's identifier and access
	    #
	    Write-Host "Identifier: $($ace.Identifier)"
            Write-Host "`tAccess: $($accessNames)"
        }
    }
}
