function Get-SAP {
  [cmdletbinding()]
  Param([String] $Host, [Int] $NR,[Parameter(ValueFromPipeline=$true)]$pipe)
  

Begin {
  $SOAPRequest = @"                                                                           
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SAPControl="urn:SAPControl" xmlns:SAPCCMS="urn:SAPCCMS" xmlns:SAPHostControl="urn:SAPHostControl" xmlns:SAPLandscapeService="urn:SAPLandscapeService" xmlns:SAPMetricService="urn:SAPMetricService" xmlns:SAPOscol="urn:SAPOscol" xmlns:SAPDSR="urn:SAPDSR">
<SOAP-ENV:Body><SAPControl:GetProcessList></SAPControl:GetProcessList>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@


  function GetProcessList($instance){
    $URL = 'http://'+$Host+':5'+$instance+'13?wsdl'
    $proxy = Invoke-WebRequest -Uri $URL -Method Post -Body $SOAPRequest -ContentType "text/xml"
    $testxml = [XML]($proxy.RawContent.Split([Environment]::NewLine) | Select-String -Pattern "<SOAP-ENV:Envelope xmlns")
    $xml2 = [XML]($testxml.Envelope.Body.GetProcessListResponse.process.OuterXml)
    $gpl = $xml2.process.ChildNodes | Format-Table
    return $gpl

  } 

  if ( $NR.IsPresent -eq $false){
  $NR = 0
  }

  if ( $NR -gt 9){
    $disp = $NR.ToString()
    $as = ($NR + 1).ToString()
  }else {
    $disp = '0'+$NR.ToString()
    $as = '0'+ ($NR + 1).ToString()
  }
}
Process{
  if ($pipe){
    $Host = $_
  }
  $Host.ToUpper()
    try {
      GetProcessList($as) 
    } catch { }
    
      GetProcessList($disp)
  }
End {}
  
}
