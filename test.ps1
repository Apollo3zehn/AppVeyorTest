if ($env:APPVEYOR_JOB_NAME -eq $env:JobToWait)
{
    Get-Date > date.txt  
    Push-AppveyorArtifact ./date.txt
}

if ($env:APPVEYOR_JOB_NAME -ne $env:JobToWait) 
{
    write-host "Waiting for job `"$env:JobToWait`" to complete"
    
    $headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-type" = "application/json"
    }

    $stop = ([DateTime]::Now).AddMinutes($env:TimeOutMins)
    $success = $false  
    
    while(!$success -and ([DateTime]::Now) -lt $stop) 
    {
        $project = Invoke-RestMethod -Uri "https://ci.appveyor.com/api/projects/$env:APPVEYOR_ACCOUNT_NAME/$env:APPVEYOR_PROJECT_SLUG" -Headers $headers -Method GET
    
        $JobToWaitJson = $project.build.jobs | where {$_.name -eq $env:JobToWait}  
        $success = $JobToWaitJson.status -eq "success"
        $JobToWaitId = $JobToWaitJson.jobId;
        if (!$success) {Start-sleep 5}
    }
    
    if (!$success) {throw "Job `"$env:JobToWait`" was not finished in $env:TimeOutMins minutes"}
    if (!$JobToWaitId) {throw "Unable to get JobId for the job `"$env:JobToWait`""}
    
    Start-FileDownload  https://ci.appveyor.com/api/buildjobs/$JobToWaitId/artifacts/date.txt
}