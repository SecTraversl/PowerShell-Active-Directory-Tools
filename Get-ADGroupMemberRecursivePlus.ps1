<#
.SYNOPSIS
  The "Get-ADGroupMemberRecursivePlus" function takes a given AD Group identity and itemizes all of the AD User accounts that fall within that group (even AD User account within nested groups of the referenced AD Group).  If there are nested groups, then the "ReferrerGroup" property will show the name of that nested group.

.EXAMPLE
  PS C:\> $test = Get-ADGroupMemberRecursivePlus -GroupIdentity "Exchange Admins" -Verbose
  VERBOSE: The function called itself.
  VERBOSE: The function called itself.
  PS C:\> $test | ft

  GroupName       Name                  SamAccountName    objectClass ReferrerGroup              DistinguishedName
  ---------       ----                  --------------    ----------- -------------              -----------------
  Exchange Admins Abe Turse             abe.turse         user        Exchange Enterprise Admins CN=Abe Turse,OU=Admin,OU=Operators,...
  Exchange Admins Sean Connorry         sean.connorry     user        Exchange Enterprise Admins CN=Sean Connorry,OU=Admin,OU=Operat...
  Exchange Admins Mark Marquett         mark.marquett     user        Exchange Enterprise Admins CN=Mark Marquett,OU=Admin,OU=Operat...
  Exchange Admins Abe Turse             abe.turse         user        Exchange Admins            CN=Abe Turse,OU=Admin,OU=Operators,...
  Exchange Admins Sean Connorry         sean.connorry     user        Exchange Admins            CN=Sean Connorry,OU=Admin,OU=Operat...
  Exchange Admins Mark Marquett         mark.marquett     user        Exchange Admins            CN=Mark Marquett,OU=Admin,OU=Operat...



  Here we run the function by specifying the AD Group name of "Exchange Admins".  In return we get the members of that group as well as the members of any nested AD Groups within that referenced group.  We use the "-Verbose" flag which let's us know that recursion occured twice, again indicating that there are two groups nested within the original AD Group.

.NOTES
  Name:  Get-ADGroupMemberRecursivePlus.ps1
  Author:  Travis Logue
  Version History:  1.3 | 2022-01-12 | Updated documentation
  Dependencies:  
  Notes:
  - This was helpful as a recursion reference, but even more so for "Get-PSCallStack":  https://4sysops.com/archives/recursive-powershell-functions-and-get-pscallstack/

  .
#>
function Get-ADGroupMemberRecursivePlus {
  [CmdletBinding()]
  [Alias('ADGroupMemberRecursivePlus','RecurseADGroupMember')]
  param (
    [Parameter(Mandatory, HelpMessage="Reference the name of the AD Group.")]
    [string]
    $GroupIdentity
  )
  
  begin {}
  
  process {
    $Results = @()
    
    $Group = Get-ADGroup -Identity $GroupIdentity

    # Here we are tracking if recursion is at play.  We use this to ensure what keep the group name that was originally queried, so that we can add that as a property in the final output.
    # - See the notes for the Adam Bertram article detailing this technique
    if ( (Get-PSCallStack)[1].Command -eq "Get-ADGroupMemberRecursivePlus"  ) {
      # Write-Host "The function called itself.`n" -BackgroundColor Black -ForegroundColor Yellow
      Write-Verbose "The function called itself." 

    }
    else {
      $MasterQueriedGroupName = $Group.Name
    }

    $Members = $Group | Get-ADGroupMember

    # Here, if one of the AD Group members is itself a group, we will use recursion to call the function again to inventory the members of that nested group
    foreach ($Member in $Members) {
      if ($Member.objectClass -eq 'group') {
        Get-ADGroupMemberRecursivePlus -GroupIdentity $Member.Name
      }
      else {
        $prop = [ordered]@{
          Name = $Member.Name
          SamAccountName = $Member.SamAccountName
          objectClass = $Member.objectClass
          ReferrerGroup = $Group.Name
          DistinguishedName = $Member.DistinguishedName
        }
        $obj = New-Object -TypeName psobject -Property $prop
        $Results += $obj
      }
    }

    # Here, for each of the final results we are adding in the AD Group name that was found from the original query... the 'trunk' of the tree before we recursed through the branches
    foreach ($result in $Results) {
      Add-Member -InputObject $result -MemberType NoteProperty -Name GroupName -Value $MasterQueriedGroupName
    }

    # Then we make the original group the first property that is shown
    $Results | Select-Object -Property GroupName, * -ErrorAction SilentlyContinue

  }
  
  end {}
}