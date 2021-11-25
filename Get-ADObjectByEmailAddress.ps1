<#
.SYNOPSIS
  The "Get-ADObjectByEmailAddress" function takes a given email address and searches Active Directory for AD Object(s) for which that email address applies.

.EXAMPLE
  PS C:\> Get-ADObjectByEmailAddress -Mail 'HelpDesk@MyDomain.com'


  DistinguishedName : CN=Help Desk,OU=SharedMB,OU=Resources,DC=subd,DC=MyDomain,DC=com
  Mail              : HelpDesk@MyDomain.com
  Name              : Help Desk
  ObjectClass       : user
  ObjectGUID        : 321cd148-4fa0-440d-aa5f-54e4a942094d
  SamAccountName    : HelpDesk



  Here we run the function by referencing a certain email address.  In return we get the AD Object that is associated with that email address.

.NOTES
  Name:  Get-ADObjectByEmailAddress.ps1
  Author:  Travis Logue
  Version History:  1.1 | 2021-11-24 | Initial Version
  Dependencies:  
  Notes:
  - 

  .
#>
function Get-ADObjectByEmailAddress {
  [CmdletBinding()]
  [Alias('ADObjectByEmailAddress')]
  param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]
    $Mail,
    [Parameter()]
    [switch]
    $PartialMatch
  )
  
  begin {}
  
  process {

    foreach ($Email in $Mail) {
      
      if ($PartialMatch) {
        Get-ADObject -Filter "Mail -like '*$Email*'" -Properties Mail, SamAccountName
      }
  
      Get-ADObject -Filter { Mail -eq $Email } -Properties Mail, SamAccountName

    }

  }
  
  end {}
}