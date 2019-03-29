function Start-ArtifactDownload([string]$jobName, [string]$fileName, [string]$apiKey)
{
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-type" = "application/json"
    }

    $project = Invoke-RestMethod -Uri "https://ci.appveyor.com/api/projects/$env:APPVEYOR_ACCOUNT_NAME/$env:APPVEYOR_PROJECT_SLUG" -Headers $headers -Method GET
    $job = $project.build.jobs | Where-Object {$_.name -eq $jobName}  
    $success = $job.status -eq "success"
    $jobId = $job.jobId;

    if (!$jobId) 
    {
        throw "Unable to get job ID for the job `"$jobName`""
    }

    if (!$success) 
    {
        throw "Job `"$jobName`" was not finished successfully. State is $($job.status)."
    }

    try 
    {
        Start-FileDownload https://ci.appveyor.com/api/buildjobs/$jobId/artifacts/$fileName.txt
    }
    catch 
    {
        $host.SetShouldExit($LastExitCode) 
    }
}