
function Connect-VCenter {
  Param($vcenter)
  switch ($vcenter) {
    'tmna' { $creds = $oxyana }
    'trp' { $creds = $oxyana }
    'tx1' { $creds = $oxyana }
    'nj1' { $creds = $ucp }
    'sj1' { $creds = $ucp }
    'ocl' { $creds = $ucp }
  }

  if (!$creds){
    $creds = $oxyana
  }

  $vcenter = "vcenter-$vcenter"
  Connect-VIServer $vcenter -Credential $creds
}

function Disconnect-VCenter {
  Param($vcenter)
  if (!$vcenter) {
    $sessions = (($global:DefaultVIServers | %{$_.Name}))
    foreach ($v in $sessions){
      Disconnect-VIServer $v -Confirm:$false
      Write-Host "Disconnected from $v"
    }
  }
  else {
    $vcenter = "vcenter-$vcenter"
    Disconnect-VIServer $vcenter -Confirm:$false
    Write-Host "Disconnected from $vcenter"
  }

}


function Get-VCenter {
  $num = (($global:DefaultVIServers | %{$_.Name}))
  if (!$num){
    $num = "No active connections"
  }
  $num
}
