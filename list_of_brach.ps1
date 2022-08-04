Param(
    [Parameter(Mandatory = $False)]
    [string]$connectionToken = "inqqran6t6pq5ehyrc2jch3kzg63mofx3kcrjzs5r2vxqdmbirva",
    
    [Parameter(Mandatory = $False)]
    [string]$Organisation = "demo0773",
    
    [Parameter(Mandatory = $False)]
    [string]$ProjectName = "IAC-Terraform"
    )
$date = Get-Date -UFormat("%m-%d-%y")
$currentDir = $(Get-Location).Path
$oFile = "$($currentDir)\List_Of_breanches_$($date).csv"

if(Test-Path $oFile){
    Remove-Item $oFile -Force
}
 
"BRANCH_NAME" | Out-File $oFile -Append -Encoding ascii

$connectionToken="inqqran6t6pq5ehyrc2jch3kzg63mofx3kcrjzs5r2vxqdmbirva"
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($connectionToken)"))
$ProjectUrl = "https://dev.azure.com/$Organisation/$ProjectName/_apis/git/repositories?api-version=6.1-preview.1" 
$Repo = (Invoke-RestMethod -Uri $ProjectUrl -Method Get -UseDefaultCredential -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)})
$RepoName= $Repo.value.name
Write-Host  $RepoName


$RepoID=$Repo.value.id
Write-Host  $RepoID
ForEach ($Id in $RepoID)
{

$ProjectUrl = "https://dev.azure.com/$Organisation/$ProjectName/_apis/git/repositories/$Id/commits?api-version=6.1-preview.1" 
$CommitInfo = (Invoke-RestMethod -Uri $ProjectUrl -Method Get -UseDefaultCredential -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)})
$CommitID = $CommitInfo.value.commitId | Select-Object -first 1
Write-Host $CommitID
$CommitUrl = "https://dev.azure.com/$Organisation/$ProjectName/_apis/git/repositories/$Id/commits/$($CommitID)?api-version=6.0-preview.1"
$LatestCommitInfo = (Invoke-RestMethod -Uri $CommitUrl -Method Get -UseDefaultCredential -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)})
Write-Host "LatestCommitInfo = $($LatestCommitInfo | ConvertTo-Json -Depth 100)"


$BarchCreatorUrl = "https://dev.azure.com/$Organisation/$ProjectName/_apis/git/repositories/$Id/refs?api-version=6.1-preview.1"
$CreateorInfo = (Invoke-RestMethod -Uri $BarchCreatorUrl -Method Get -UseDefaultCredential -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)})
$CreateorInfo | ForEach-Object{
$branch = ($CreateorInfo.value.name) 
$objectID = $CreateorInfo.value.objectId



$branch | Format-Table -AutoSize | Out-String | Out-File $oFile -Append -Encoding ascii
}
}
