<#
.Synopsis
   Send a message to an ActiveMQ queue.
.DESCRIPTION
   Sends a single message to an ActiveMQ queue. The message must be formatted
   as the reader of the queue expects. You should not include the "body=" tag.
.EXAMPLE
   Send-ActiveMessage -user joe -queue invoice -server sample.bigco.com -message $invoiceData
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   None.
#>

function Send-ActiveMQMessage
{
    [CmdletBinding(SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specify user
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $User,

        # specify server
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $MQserver,

        # specify queue
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Queue,

        # specify message
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Message
    )
    Begin
    {
    }
    Process
    {
        $cd = [PSCredential](Get-JAMSCredential $User)
        $fullBody = "body=" + $Message
        Invoke-RestMethod "http://${MQserver}:8161/api/message?destination=queue://${Queue}" -body $fullBody -Method POST -Credential $cd
    }
    End
    {
    }
}

<#
.Synopsis
   Receive a message from an ActiveMQ queue.
.DESCRIPTION
   Readss a single message from an ActiveMQ queue.
.EXAMPLE
   $newData = Receive-ActiveMessage -user joe -queue invoice -server sample.bigco.com -message $invoiceData
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   None.
#>

function Receive-ActiveMQMessage
{
    [CmdletBinding(SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specify user
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $User,

        # specify server
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $MQserver,

        # specify queue
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Queue,

        # specify clientID
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $ClientID=''
    )
    Begin
    {
        if($ClientID -ne '')
        {
            $ConsumeMethod = "clientID=${ClientID}"
        }
        else
        {
            $ConsumeMethod = "oneShot=true"
        }
    }
    Process
    {
        $cd = [PSCredential](Get-JAMSCredential $User)
        $msg = Invoke-RestMethod "http://${MQserver}:8161/api/message?destination=queue://${Queue}&${ConsumeMethod}" -Method Get -Credential $cd
        write-output $msg
    }
    End
    {
    }
}