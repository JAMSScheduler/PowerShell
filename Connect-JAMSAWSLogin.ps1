<#
.Synopsis
   Connect to your instance of Amazon AWS
.DESCRIPTION
   Connect and store an Amazon AWS Session into a PowerShell variable utilizing a stored JAMS User
.SYNTAX
   Connect-JAMSAWSLogin -JAMSCred AmazonAWSLogin -SessionName AmazonAWS
.EXAMPLE
   $AmazonAWS = Connect-JAMSAWSLogin -JAMSCred AmazonAWSLogin -SessionName AmazonAWS
#>
Function Connect-JAMSAWSLogin($JAMSCred, $SessionName) {
     if ($JAMSCred -eq $null) {
        Write-Error "-JAMSCred is a required value"
    }
    if ($SessionName -eq $null) {
        Write-Error "-SessionName is a required value"
    }
    else {
        #
        # Amazon EC2 Stored Credentials
        #
        $secretKey = (Get-JAMSCredential $JAMSCred).GetCredential($null,$null)
        $accessKey = (Get-JAMSCredential $JAMSCred).UserName

        $creds = New-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey.password

        #
        # Cache our credentials for use by AWS.NET API
        #
        Set-AWSCredentials -Credentials $creds -StoreAs $SessionName

        $storedCred = $SessionName
        
        return $creds

    }
}