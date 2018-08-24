function Get-AWXProjects {                                                             
  $awx = (tower-cli project list)
  $pro = $awx -replace '=','' -replace '(^\s+|\s+$)','' -replace '\s+',' ' -split ' ',[System.StringSplitOptions]::RemoveEmptyEntries | Select-String -Pattern 'id|name|scm_type|scm_url|local_path|\s$' -NotMatch
  if ($pro){
    $pro | ForEach-Object {

        $ar = $_.ToString().Split(' ')
        $obj = "" | Select-Object ID,Name,Source,URL,Path
        $obj.ID = $ar[0]
        $obj.Name = $ar[1]
        $obj.Source = $ar[2]
        $obj.URL = $ar[3]
        $obj.Path= $ar[4]
        $obj | Where-Object {$_.ID -ne ""}
    }
  }
}
  