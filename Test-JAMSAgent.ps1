#
# Utilized to test whether or not a JAMS Agent is currently online
#

function Test-JAMSAgent ([string]$Name = "*", [string]$Server = "localhost"){
    #
    #  Create a list of JAMS Agents
    #
    $agentList = [MVPSI.JAMS.Agent]::Find($Name,$Server)
    #
    #  Loop through agent list
    #
    Foreach($agent in $agentList){
        #
        #   Write out message to console
        #
        Write-Host 'Checking Agent on' $agent.AgentName
        #
        #   Check agent's Platform property
        #
        if($agent.Platform -eq 'Windows'){
            #
            # Check if the Agent Machine is Online
            #
            if(Test-Connection -ComputerName $agent.AgentName –Quiet –Count 2){
                #
                #   Get service Object
                #
                $agentObject = Get-Service *JAMSAgent -ComputerName $agent.AgentName
                #
                #   Check if JAMSAgent is Stopped
                #
                if($agentObject.Status -eq 'Stopped'){
                    Return "Offline"
                    Write-Host "Enabling JAMS Agent Service on $agentObject.MachineName"
                    #
                    #   Start service with Object as input
                    #
                    Start-Service -InputObject $agentObject
                }
                Return "Online"
            } else {
                Return "Offline"
            }
        }else{
            #
            #   Non-windows do a Test-Connection to see if it responds
            #
            if(Test-Connection -ComputerName $agent.AgentName –Quiet –Count 2){
                Return "Online"
            }else{
                #
                #   Write message to console that server is down
                #
                Return "Offline"
            }
        }
    }
}
