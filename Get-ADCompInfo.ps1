<#
.SYNOPSIS
  The "Get-ADCompInfo" function is a succinct way to retrieve an AD Computer object that has a name partially matching the argument given to the "-Name" parameter.

.EXAMPLE
  PS C:\> ADCompInfo RemDesk

  Certificates         : {System.Security.Cryptography.X509Certificates.X509Certificate} 
  DistinguishedName    : CN=RemDesktopPC,OU=Desktop,OU=Devices,DC=subd,DC=MyDomain,DC=com
  DNSHostName          : RemDesktopPC.subd.MyDomain.com
  Enabled              : True
  LastLogonDate        : 12/2/2021 9:37:03 AM
  Name                 : RemDesktopPC
  ObjectClass          : computer
  ObjectGUID           : ea388eb1-4872-1385-a532-ee298c9e56ab
  OperatingSystem      : Windows 10 Enterprise
  SamAccountName       : RemDesktopPC$
  servicePrincipalName : {WSMAN/RemDesktopPC.subd.MyDomain.com, WSMAN/RemDesktopPC, TERMSRV/RemDesktopPC.subd.MyDomain.com, TERMSRV/RemDesktopPC...}
  SID                  : S-1-5-21-104866274-201234818-8745921783-62159
  UserPrincipalName    :



  Here we run the "Get-ADCompInfo" function by calling its built-in alias of 'ADCompInfo'.  We reference the substring of 'RemDesk' to be used in our default wildcard search for an AD Computer object that has the given substring in its "Name" property value.  In return we get the only matching computer object along with various properties pertaining to that computer object.

.NOTES
  Name:  Get-ADCompInfo.ps1
  Author:  Travis Logue
  Version History:  1.4 | 2022-01-12 | Updated documentation
  Dependencies:  ActiveDirectory module
  Notes:


  .
#>
function Get-ADCompInfo {
  [CmdletBinding()]
  [Alias('ADCompInfo')]
  param (
    [Parameter(Mandatory, HelpMessage = 'Reference a partial or full computer name to retrieve from Active Directory.')]
    [string[]]
    $Name,
    [Parameter()]
    [string[]]
    $Property,
    [Parameter(HelpMessage = 'Use this switch parameter to ensure the "name" string used in the filter is an exact match for the argument given to the "-Name" parameter')]
    [switch]
    $ExactMatch
  )
  
  begin {}
  
  process {

    # Additional Properties to request
    $DefaultPropsToRetrieve = @('OperatingSystem', 'LastLogonDate', 'Certificates', 'servicePrincipalName')
    
    if ($Property) {
      $Properties = $DefaultPropsToRetrieve + @($Property)
    }
    else {
      $Properties = $DefaultPropsToRetrieve
    }

    # For loop and computer object retrieval from AD
    foreach ($item in $Name) {

      if ($ExactMatch) {
        $Filter = "Name -like '$item'"
      }
      else {
        $Filter = "Name -like '*$item*'"
      }      

      Get-ADComputer -Filter $Filter -Properties $Properties

    }

  }
  
  end {}
}