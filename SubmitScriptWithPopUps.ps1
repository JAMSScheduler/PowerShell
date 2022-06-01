Import-Module JAMS

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

## In the InputBox having the syntax of InputBox(Prompt, Variable, DefaultValue), the last of which you can leave out to have it empty.

$hostList = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the JAMS Server to submit job from (separate multiple with comma):", "JAMS Servers", "localhost")
#write-host "Submitting job to $hostList"

if($hostList.Contains(",")){
    $jamshosts = $hostList.split(",").trim()
}else{
    $jamshosts = $hostList
}
foreach($jamshost in $jamshosts){
    $job = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the Job you would like to submit (include path to job):", "Enter Job Name", "\Samples\SleepJob")
    $SubmitJob = get-item JAMS::$jamshost$job 

    $submitParameters = @{}
    foreach($param in $submitJob.parameters){
        if(!$param.Hide){
            $ParamValue = [Microsoft.VisualBasic.Interaction]::InputBox("$($param.Prompt)", "Enter value for: $($param.ParamName)", "$($param.defaultvalue)")
            $submitParameters.add($($param.ParamName), $ParamValue)
        }
    }

    Submit-JAMSEntry $SubmitJob -Parameters $submitParameters -Server $jamshost
}
