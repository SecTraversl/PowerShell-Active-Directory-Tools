<#
.SYNOPSIS
  The "Get-ADUserBySamAccountName" function takes the SamAccountName of Active Directory users and retrieves additional information pertaining to that User Object in Active Directory.

.DESCRIPTION
.EXAMPLE
  PS C:\> Get-ADUserBySamAccountName -SamAccountName 'Cyan.Foss'

  DistinguishedName : CN=Cyan Foss,OU=Employee,OU=Operators,DC=subd,DC=Roxboard,DC=com
  Enabled           : True
  GivenName         : Cyan
  Mail              : Cyan.Foss@Roxboard.com
  Name              : Cyan Foss
  ObjectClass       : user
  ObjectGUID        : 60e3b20a-4952-2094-83ac-e47de5aae5a2
  SamAccountName    : Cyan.Foss
  SID               : S-1-5-21-104866274-201234818-8745921783-64132
  Surname           : Foss
  UserPrincipalName : Cyan.Foss@Roxboard.com


  PS C:\> ADUserBySamAccount 'Cyan.Foss'

  DistinguishedName : CN=Cyan Foss,OU=Employee,OU=Operators,DC=subd,DC=Roxboard,DC=com
  Enabled           : True
  GivenName         : Cyan
  Mail              : Cyan.Foss@Roxboard.com
  Name              : Cyan Foss
  ObjectClass       : user
  ObjectGUID        : 60e3b20a-4952-2094-83ac-e47de5aae5a2
  SamAccountName    : Cyan.Foss
  SID               : S-1-5-21-104866274-201234818-8745921783-64132
  Surname           : Foss
  UserPrincipalName : Cyan.Foss@Roxboard.com



  Here we demonstrate the verbose and the fast way to run this function.  'ADUserBySamAccount' is the built-in alias for "Get-ADUserBySamAccountName" and we show here how we can use it to get the same results as we did when running the function using the full name (the first example) along with an explicit reference to the "-SamAccountName" parameter

.EXAMPLE
  PS C:\> Invoke-ADUserNameChecker -Name 'Cyan Foss'

  Name      AccountFound SamAccountName Mail
  ----      ------------ -------------- ----
  Cyan Foss         True Cyan.Foss      Cyan.Foss@Roxboard.com


  PS C:\> ADNameChecker 'Cyan Foss'

  Name      AccountFound SamAccountName Mail
  ----      ------------ -------------- ----
  Cyan Foss         True Cyan.Foss      Cyan.Foss@Roxboard.com


  PS C:\> ADNameChecker 'Cyan Foss' | ADUserBySamAccount

  DistinguishedName : CN=Cyan Foss,OU=Employee,OU=Operators,DC=subd,DC=Roxboard,DC=com
  Enabled           : True
  GivenName         : Cyan
  Mail              : Cyan.Foss@Roxboard.com
  Name              : Cyan Foss
  ObjectClass       : user
  ObjectGUID        : 60e3b20a-4952-2094-83ac-e47de5aae5a2
  SamAccountName    : Cyan.Foss
  SID               : S-1-5-21-104866274-201234818-8745921783-64132
  Surname           : Foss
  UserPrincipalName : Cyan.Foss@Roxboard.com



  Here we demonstrate the use of a chain of functions and how they can be used together.  We first demonstrate the use of "Invoke-ADUserNameChecker" and its built-in alias 'ADNameChecker' in order to retrieve the SamAccountName for a specic user's Name.  From there, we are able to pipe that object to 'ADUserBySamAccount' (the built-in alias for "Get-ADUserBySamAccountName") in order to gain additional information about the user.

.INPUTS
.OUTPUTS
.NOTES
  Name:  Get-ADUserBySamAccountName.ps1
  Author:  Travis Logue
  Version History:  1.2 | 2022-01-12 | Updated Documentation
  Dependencies:  Active Directory Module
  Notes:


  .  
#>
function Get-ADUserBySamAccountName {
  [CmdletBinding()]
  [Alias('ADUserBySamAccount')]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]
    $SamAccountName
  )
  
  begin {}
  
  process {
    
    foreach ($SamAccount in $SamAccountName) {

      $UserObject = Get-ADUser -Identity $SamAccount -Properties Mail
      Write-Output $UserObject

    }

  }
  
  end {}
}