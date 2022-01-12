<#
.SYNOPSIS
  The "Get-ADUserByEmailAddress" function takes a given email address and searches Active Directory for User object(s) for which that email address applies.

.EXAMPLE
  PS C:\> Get-ADUserByEmailAddress -Mail HelpDesk@MyDomain.com


  DistinguishedName : CN=Help Desk,OU=SharedMB,OU=Resources,DC=subd,DC=MyDomain,DC=com
  Enabled           : False
  GivenName         :
  Mail              : HelpDesk@MyDomain.com
  Name              : Help Desk
  ObjectClass       : user
  ObjectGUID        : 321cd148-4fa0-670d-aa5f-54e4a942094d
  SamAccountName    : HelpDesk
  SID               : S-1-5-21-201432503-109117752-3773961456-81094
  Surname           :
  UserPrincipalName : HelpDesk@MyDomain.com



  Here we run the function by referencing a certain email address.  In return we get the AD User that is associated with that email address.

.NOTES
  Name:  Get-ADUserByEmailAddress.ps1
  Author:  Travis Logue
  Version History:  1.3 | 2021-08-25 | Added support for: Pipeline use and an Array of arguments; and changed Parameter name to "Mail"
  Dependencies:  Active Directory Module
  Notes:


  .  
#>
function Get-ADUserByEmailAddress {
  [CmdletBinding()]
  [Alias('ADUserByEmailAddress')]
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
        Get-ADUser -Filter "Mail -like '*$Email*'" -Properties Mail
      }
  
      Get-ADUser -Filter { Mail -eq $Email } -Properties Mail

    }

  }
  
  end {}
}