function Get-SAPInstance {
    <#
    .SYNOPSIS
    Gets the Instances for a Remote SAP System.
    
    .DESCRIPTION
    Uses SAPControl WSDL to get the Instance List of a Remote SAP System. 
    Can accept a pipe input of Host or Name

    .EXAMPLE
    PS C:\Users\Administrator> Get-SAPInstance hhd-tys4hx01
    
    Host         NR Description            Status                                   
    ----         -- -----------            ------                                   
    hhd-tys4hx01 00 ABAP|GATEWAY|ICMAN|IGS GREEN                                    
    hhd-tys4hx01 01 MESSAGESERVER|ENQUE    GREEN

    Gets SAP System at Instance number of 00

    .EXAMPLE
    PS C:\Users\Administrator> Get-SAPInstance hhd-tys4hd01 -NR 01

    Host         NR Description            Status                                   
    ----         -- -----------            ------                                   
    HHD-TYS4HD01 02 MESSAGESERVER|ENQUE    GREEN                                    
    HHD-TYS4HD01 01 ABAP|GATEWAY|ICMAN|IGS GREEN

    Gets SAP System at Instance number of 01
    
    .EXAMPLE
    PS C:\Users\Administrator> Get-VM -Name HHD-TYWEBD01 | Get-SAPInstance

    Host         NR Description Status                                              
    ----         -- ----------- ------                                              
    hhd-tywebd01 00 WEBDISP     GREEN

    Gets SAP System at Instance number of 00 of the found VM 

    .NOTES
    Author: Christopher D Forkner
    Date:  5 August 2018

    Must be able to connect to the sapsystem

    #>
  [cmdletbinding()]
  Param([String] $Name, [Int] $NR,[Parameter(ValueFromPipeline=$true)]$pipe)
  
  Begin {
    function GetSystemInstanceList($instance){
      $URL = 'http://'+$Name+':5'+$instance+'13t?wsdl'
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
    } else {
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

    $SOAPRequest = _GetSOAP('GetSystemInstanceList')

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
function _GetSOAP($function){
  #This formats the SOAP Request to SAPControl. Not meant to be called directly.
  $Request = @"                                                                           
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SAPControl="urn:SAPControl" xmlns:SAPCCMS="urn:SAPCCMS" xmlns:SAPHostControl="urn:SAPHostControl" xmlns:SAPLandscapeService="urn:SAPLandscapeService" xmlns:SAPMetricService="urn:SAPMetricService" xmlns:SAPOscol="urn:SAPOscol" xmlns:SAPDSR="urn:SAPDSR">
<SOAP-ENV:Body><SAPControl:$function></SAPControl:$function>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@
  return $Request
}
  
function Get-SAPProcessList {
    <#
    .SYNOPSIS
    Gets the Process List for a Remote SAP System.
    
    .DESCRIPTION
    Uses SAPControl WSDL to get the Process List of a Remote SAP System.
    Can accept a pipe from Get-SAPInstance.

    .EXAMPLE
    PS C:\Users\Administrator> Get-SAPProcessList hhd-tys4hx01 -nr 00

    Host        : hhd-tys4hx01
    Description : Dispatcher
    Status      : GREEN
    Uptime      : 105:53:13

    Host        : hhd-tys4hx01
    NR          : 00
    Description : IGS Watchdog
    Status      : GREEN
    Uptime      : 105:53:13

    Host        : hhd-tys4hx01
    NR          : 00
    Description : Gateway
    Status      : GREEN
    Uptime      : 105:52:42

    Host        : hhd-tys4hx01
    NR          : 00
    Description : ICM
    Status      : GREEN
    Uptime      : 105:52:42

    Gets the Process List of the SAP System at Instance number 00

    .EXAMPLE
    PS C:\Users\Administrator> Get-SAPInstance hhd-tys4hx01 | Get-SAPProcessList

    Host        : hhd-tys4hx01
    NR          : 00          
    Description : Dispatcher
    Status      : GREEN
    Uptime      : 117:50:45

    Host        : hhd-tys4hx01
    NR          : 00
    Description : IGS Watchdog
    Status      : GREEN
    Uptime      : 117:50:45

    Host        : hhd-tys4hx01
    NR          : 00
    Description : Gateway
    Status      : GREEN
    Uptime      : 117:50:14

    Host        : hhd-tys4hx01
    NR          : 00
    Description : ICM
    Status      : GREEN
    Uptime      : 117:50:14

    Host        : hhd-tys4hx01
    NR          : 01
    Description : MessageServer
    Status      : GREEN 
    Uptime      : 117:50:57

    Host        : hhd-tys4hx01
    NR          : 01
    Description : EnqueueServer
    Status      : GREEN
    Uptime      : 117:50:57

    Gets the Instance List from hhd-tys4hx01 then all processes for all found SAP Systems
    
    .NOTES
    Author: Christopher D Forkner
    Date:  5 August 2018

    Must be able to connect to the sapsystem

    #>

  [cmdletbinding()]
  Param([String] $Name, [Int] $NR,[Parameter(ValueFromPipeline=$true)]$pipe)
  
  
  Begin {
    function GetProcessList($instance){
      $SOAPRequest = _GetSOAP('GetProcessList')
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
    $SOAPRequest = _GetSOAP('GetProcessList')
    try {
      $dst = GetProcessList($disp)
    } catch {
      Write-Host "$Error - Nothing found on $Name $disp"
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
  End { 
  }
}
