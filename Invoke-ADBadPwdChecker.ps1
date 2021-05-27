<#
.SYNOPSIS
  The "Invoke-ADBadPwdChecker" takes a given SamAccountName and queries each domain controller within that domain (the default domain can be changed with the "-Domain" parameter) in order to return the "badPwdCount" and the "badPasswordTime" for that user account.

.DESCRIPTION
.EXAMPLE
  PS C:\> BadPwdChecker -SamAccountName Jannus.Fugal

  DC_Status        : Reachable
  Domain           : subd.MyDomain.com
  DomainController : 10.30.76.28
  SamAccountName   : Jannus.Fugal
  badPwdCount      : 0
  badPasswordTime  : 153547 18:06:36.1585710 - 5/26/2021 11:06:36 AM

  DC_Status        : Reachable
  Domain           : subd.MyDomain.com
  DomainController : 10.30.76.33
  SamAccountName   : Jannus.Fugal
  badPwdCount      : 0
  badPasswordTime  : 153547 18:06:36.1917071 - 5/26/2021 11:06:36 AM

  DC_Status        : Reachable
  Domain           : subd.MyDomain.com
  DomainController : 10.44.11.22
  SamAccountName   : Jannus.Fugal
  badPwdCount      : 0
  badPasswordTime  : missing parameter



  Here we run the function using the built-in alias of 'BadPwdChecker'.  In return we get the information back from each of the domain controllers for the given domain (the default domain that is queried can be changed using the "-Domain" parameter).

.INPUTS
.OUTPUTS
.NOTES
  Name: Invoke-ADBadPwdChecker.ps1
  Author: Travis Logue
  Version History: 1.1 | 2021-05-26 | Initial Version
  Dependencies:
  Notes:


  .
#>
function Invoke-ADBadPwdChecker {
  [CmdletBinding()]
  [Alias('BadPwdChecker')]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]
    $SamAccountName,
    [Parameter()]
    [ValidateSet("corp.coinstar.com", "coinstar.com", "prodhal.com", "stagehal.com")]
    [string]
    $Domain = "corp.coinstar.com"
  )
  
  begin {}
  
  process {
    $IPs = (Resolve-DnsName -Name $Domain).IPAddress

    foreach ($IP in $IPs) {
      try {
        $UserInfo = Get-ADuser -Identity $SamAccountName -Properties badPwdCount, badPasswordTime <#,LastBadPasswordAttempt#>  -Server $IP

        $prop = [ordered]@{

          DC_Status        = 'Reachable'
          Domain           = $Domain
          DomainController = $IP
          SamAccountName   = $SamAccountName
          badPwdCount      = $UserInfo.badPwdCount
          badPasswordTime  = w32tm.exe /ntte $UserInfo.badPasswordTime

        }
      }
      catch {
        $prop = [ordered]@{

          DC_Status        = 'Reachable'
          Domain           = $Domain
          DomainController = $IP
          SamAccountName   = $SamAccountName
          badPwdCount      = $UserInfo.badPwdCount
          badPasswordTime  = w32tm.exe /ntte $UserInfo.badPasswordTime

        }        
      }
      finally {
        $obj = New-Object -TypeName psobject -Property $prop
        Write-Output $obj        
      }
    }
  }
  
  end {}
}