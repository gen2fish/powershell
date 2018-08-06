function Get-SAPInstance {
  [cmdletbinding()]
  Param([String] $Name, [Int] $NR,[Parameter(ValueFromPipeline=$true)]$pipe)
  

  Begin {
  $SOAPRequest = @"                                                                           
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SAPControl="urn:SAPControl" xmlns:SAPCCMS="urn:SAPCCMS" xmlns:SAPHostControl="urn:SAPHostControl" xmlns:SAPLandscapeService="urn:SAPLandscapeService" xmlns:SAPMetricService="urn:SAPMetricService" xmlns:SAPOscol="urn:SAPOscol" xmlns:SAPDSR="urn:SAPDSR">
<SOAP-ENV:Body><SAPControl:GetSystemInstanceList></SAPControl:GetSystemInstanceList>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@


  function GetSystemInstanceList($instance){
    $URL = 'http://'+$Name+':5'+$instance+'13?wsdl'
    $proxy = Invoke-WebRequest -Uri $URL -Method Post -Body $SOAPRequest -ContentType "text/xml"
    $testxml = [XML]($proxy.RawContent.Split([Environment]::NewLine) | Select-String -Pattern "<SOAP-ENV:Envelope xmlns")
    $xml2 = [XML]($testxml.Envelope.Body.GetSystemInstanceListResponse.instance.OuterXml)
    $gpl = $xml2.instance.item | Select-Object @{Label="NR"; Expression={$_.instanceNr}}, @{Label="Description"; Expression={$_.features}}, @{Label="Status"; Expression={$_.dispstatus -replace 'SAPControl-',''}}, @{Label="Host"; Expression={$_.hostname}}
    return $gpl

  } 

  if ( $NR.IsPresent -eq $false){
  $NR = 0
  }

  if ( $NR -gt 9){
    $disp = $NR.ToString()
  }else {
    $disp = '0'+$NR.ToString()
  }
}

Process{
  if ($pipe){
    if ($_.Name){ 
      $Name = $_.Name 
    } else {
      $name = $_
    }
  }

    try {
      $dst = GetSystemInstanceList($disp)
    } catch {
      Write-Host "Nothing found on $Name $disp" -ForegroundColor Red
    }
    
    $final = $dst
     
    if ($final) {
      $final | ForEach-Object{
        $obj = "" | Select-Object Host,NR,Description,Status
        $obj.Host = $_.Host
        if ( $_.NR -gt 9){
          $disp = $_.NR.ToString()
        }else {
          $disp = '0'+$_.NR.ToString()
        }

        $obj.NR = $disp
        $obj.Description = $_.Description
        $obj.status = $_.Status
        $obj
      }
    }
  }
End {}
  
}

function Get-SAPProcessList {
  [cmdletbinding()]
  Param([String] $Name, [Int] $NR,[Parameter(ValueFromPipeline=$true)]$pipe)
  

  Begin {
  $SOAPRequest = @"                                                                           
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SAPControl="urn:SAPControl" xmlns:SAPCCMS="urn:SAPCCMS" xmlns:SAPHostControl="urn:SAPHostControl" xmlns:SAPLandscapeService="urn:SAPLandscapeService" xmlns:SAPMetricService="urn:SAPMetricService" xmlns:SAPOscol="urn:SAPOscol" xmlns:SAPDSR="urn:SAPDSR">
<SOAP-ENV:Body><SAPControl:GetProcessList></SAPControl:GetProcessList>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@


  function GetProcessList($instance){
    $URL = 'http://'+$Name+':5'+$instance+'13?wsdl'
    $proxy = Invoke-WebRequest -Uri $URL -Method Post -Body $SOAPRequest -ContentType "text/xml"
    $testxml = [XML]($proxy.RawContent.Split([Environment]::NewLine) | Select-String -Pattern "<SOAP-ENV:Envelope xmlns")
    $xml2 = [XML]($testxml.Envelope.Body.GetProcessListResponse.process.OuterXml)  
    $gpl = $xml2.process.item | Select-Object @{Label="NR"; Expression={$instance}}, @{Label="Description"; Expression={$_.description}}, @{Label="Status"; Expression={$_.dispstatus -replace 'SAPControl-',''}}, @{Label="Text"; Expression={$_.textstatus}}, @{Label="Uptime"; Expression={$_.elapsedtime}}, @{Label="Started";Expression={$_.starttime}}, @{Label="Host"; Expression={$Name}}
    return $gpl

  } 


}
Process{
  if ($pipe){
    if ($_.Name){ 
      $Name = $_.Name 
    } elseif ($_.Host) {
      $Name = $_.Host
    } else {
      $name = $_
    }
    if ($_.NR){
      $NR = $_.NR
    }
  }

    if ( $NR.IsPresent -eq $false){
  $NR = 0
  }

    $disp = '0'+$NR.ToString()

    try {
      $dst = GetProcessList($disp)
    } catch {
      Write-Host "Nothing found on $Name $disp"
    }

    $final = $dst
    
    if ($final) {
      $final | Where-Object {$_.Description} | ForEach-Object{
        $obj = "" | Select-Object Host,NR,Description,Status,Uptime
        $obj.Host = $_.Host
        $obj.NR = $_.NR
        $obj.Description = $_.Description
        $obj.status = $_.Status
        $obj.uptime = $_.Uptime
        $obj
      }
    }
  }
End {}
  
}
