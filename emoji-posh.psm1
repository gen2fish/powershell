function prompt
{
    $origLastExitCode = $?
    $arrows = '>'
    $colon = ':'

    if ( $origLastExitCode -eq $True ){
      $finger = '👉'
      $face = '😎'
    }
    if ( $origLastExitCode -eq $False ){
      $face = '😠'
      $finger = '🔔'
    }

    if ($NestedPromptLevel -gt 0) 
    {
        $arrows = $arrows * ($NestedPromptLevel +1 )
    }

    $currentDirectory = Split-Path (Get-Location) -Leaf
    $done = ''
    $done += Write-Host "$finger$face$finger" -NoNewline
    $done += Write-Host "$colon" -ForegroundColor White -NoNewline
    $done += Write-Host "$currentDirectory" -NoNewline -ForegroundColor Blue
    $done += Write-Host "$arrows" -ForegroundColor White -NoNewline
    $done += ' '  
    $done
}