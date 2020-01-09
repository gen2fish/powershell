function Get-Sockets {
  $vms = Get-VM
  $vms | ForEach-Object {
    $physCore = $_ | Get-VMHost | Select-Object -Property NumCPU
    $vmMem = $_.MemoryGB
  }
}
