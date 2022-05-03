<#
.SYNOPSIS
  The "Get-ADUserInfo" function is a succinct way to retrieve an AD User object that has a name partially matching the argument given to the "-Name" parameter.

.EXAMPLE
  PS C:\> ADUserInfo 'Jannus'


  CanonicalName     : subd.MyDomain.com/Operators/Employee/Jannus Fugal
  DistinguishedName : CN=Jannus Fugal,OU=Employee,OU=Operators,DC=subd,DC=MyDomain,DC=com
  Enabled           : True
  GivenName         : Jannus
  LogonCount        : 4815
  Mail              : Jannus.Fugal@MyDomain.com
  Name              : Jannus Fugal
  ObjectClass       : user
  ObjectGUID        : ffa3f6e4-dfbe-0174-0547-7f79a171f576
  SamAccountName    : Jannus.Fugal
  SID               : S-1-5-63-649852324-997701286-9817230365-12373
  Surname           : Fugal
  UserPrincipalName : Jannus.Fugal@MyDomain.com
  WhenChanged       : 8/25/2021 11:01:10 AM
  WhenCreated       : 5/25/2016 4:37:31 PM
  PasswordLastSet   : 8/24/2021 10:15:03 AM
  PasswordExpires   : 11/22/2021 9:15:03 AM



  Here we run the "Get-ADUserInfo" function by calling its built-in alias of 'ADUserInfo'.  We reference the substring of 'Jannus' to be used in our default wildcard search for an AD User object that has the given substring in its "Name" property value.  In return we get two AD User objects matching our search.


.NOTES
  Name:  Get-ADUserInfo.ps1
  Author:  Travis Logue
  Version History:  2.4 | 2022-05-02 | Made this tool universally applicable
  Dependencies:  ActiveDirectory module
  Notes:
  - Here we found a way to find the Password Expiration Timestamp for an AD account:  https://docs.microsoft.com/en-us/archive/blogs/poshchap/one-liner-get-a-list-of-ad-users-password-expiry-dates

  - Here is the reference from where we retrieved the idea of using [datetime]::FromFileTime() to convert the timestamp:  https://docs.microsoft.com/en-us/archive/blogs/poshchap/one-liner-get-a-list-of-ad-users-password-expiry-dates
    - Old way using w32tm.exe -ntte:  
        ♣ Temp> w32tm.exe -ntte 132665259961917071
        153547 18:06:36.1917071 - 5/26/2021 11:06:36 AM

    - New way using [datetime]::FromFileTime()
        √ Temp> [datetime]::FromFileTime(132665259961917071)

        Wednesday, May 26, 2021 11:06:36 AM


  .
#>
function Get-ADUserInfo {
  [CmdletBinding()]
  [Alias('ADUserInfo')]
  param (
    [Parameter(Position = 0, Mandatory, ParameterSetName = 'Default Parameter Set', HelpMessage = 'Reference a partial or full Name of the user to retrieve from Active Directory.')]
    [string[]]
    $Name,
    [Parameter(Mandatory, ParameterSetName = 'SamAccountName Parameter Set', HelpMessage = 'Reference a full SamAccountName of the user to retrieve from Active Directory.')]
    [string[]]
    $SamAccountName,
    [Parameter()]
    [string[]]
    $Property,
    [Parameter(HelpMessage = 'Use this switch parameter to ensure the "name" string used in the filter is an exact match for the argument given to the "-Name" parameter')]
    [switch]
    $ExactMatch
  )
  
  begin {}
  
  process {

    if ($Property) {
      $Properties = @('Mail', 'LogonCount', 'WhenCreated', 'WhenChanged', 'CanonicalName', 'PasswordLastSet', 'msDS-UserPasswordExpiryTimeComputed') + @($Property)
    }
    else {
      $Properties = @('Mail', 'LogonCount', 'WhenCreated', 'WhenChanged', 'CanonicalName', 'PasswordLastSet', 'msDS-UserPasswordExpiryTimeComputed')
    }

    # If the "-SamAccountName" parameter is specified, that will be the property that is searched in Active Directory
    if ($SamAccountName) {      
      $Results = foreach ($item in $SamAccountName) {

        if ($ExactMatch) {
          $Filter = "SamAccountName -like '$item'"
        }
        else {
          $Filter = "SamAccountName -like '*$item*'"
        }      
  
        Get-ADUser -Filter $Filter -Properties $Properties
  
      }
    } # Else, the "-Name" parameter is the property that is searched in Active Directory
    else {      
      $Results = foreach ($item in $Name) {

        if ($ExactMatch) {
          $Filter = "Name -like '$item'"
        }
        else {
          $Filter = "Name -like '*$item*'"
        }      
  
        Get-ADUser -Filter $Filter -Properties $Properties
  
      }    
    }

    if ($Property) {      
      Write-Output $Results
    }
    else {      
      # These are the default properties that would be displayed, except that we are transforming the timestamp here for "PasswordExpiration" so that it is in a human-readable format
      $SelectedProperties = @(
        'CanonicalName', 
        'DistinguishedName', 
        'Enabled', 
        'GivenName', 
        'LogonCount', 
        'Mail',
        'Name', 
        'ObjectClass', 
        'ObjectGUID', 
        'SamAccountName', 
        'SID', 
        'Surname', 
        'UserPrincipalName', 
        'WhenChanged', 
        'WhenCreated',
        'PasswordLastSet',
        @{n = 'PasswordExpires'; e = { [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed') } }
      )

      $Results | Select-Object -Property $SelectedProperties
    }

  }
  
  end {}
}
