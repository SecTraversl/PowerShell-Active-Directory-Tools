<#
.SYNOPSIS
  The "Get-OrgChart" function iterates over Active Directory, starting at the given array of "-ExecutiveManagerSamAccountNames", in order to populate a list with pertitent information of AD Users and to which Executive Manager they ultimately report.

.DESCRIPTION
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
.OUTPUTS
.NOTES
  Name:  Get-OrgChart.ps1
  Author:  Travis Logue
  Version History:  2.2 | 2021-11-05 | Total refactoring of the tool
  Dependencies:  Active Directory Module
  Notes:


  .
#>
function Get-OrgChart {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string[]]
    $ExecutiveManagerSamAccountNames # Specify an array containing the SamAccountNames of the executive managers; These will be used as the 'stopping points' as we iterate through chain-of-command, and as the 'reference points' for whom we are collecting the direct reports.  To get an idea of who the Executive Managers are, you can use the "Find-ADExecutiveManagers" function; although if there are nuances in your organization's Executive Management structure {such as if one Executive Manager actually reports to another}, you may just want to use the output of the "Find-ADExecutiveManagers" function as a starting point.  It is recommended that you hardcode these values to this parameter, like so: $ExecutiveManagerSamAccountNames = @('alice.samson', 'bob.connelly', 'cynthia.stegman')
  )
  
  begin {
    # Here we define an embedded function that is called in the process {} block
    # - To see the full version of the "Get-ADDirectReportsTally" with examples, see the help associated with that function / the .ps1 file by the same name

    function Get-ADDirectReportsTally {
      [CmdletBinding()]
      [Alias('ADDirectReportsTally')]
      param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $DirectReports,
        [Parameter()]
        [string]
        $ExecutiveManagerName,
        [Parameter()]
        [string]
        $NotLikeSearchBaseOU = "*☺*", # This is generally used to omit from our results any accounts within certain OUs, where part of the OU name is represented by ☺ (Alt + 1);  If you aren't excluding any OUs, keep this default value as-is
        [Parameter()]
        [string]
        $NotMatchSamAccountName = "^☺|^☻",  # This is used to omit from our results any accounts containing certain SamAccountName values, where ☺ (Alt + 1) or ☻ (Alt + 2) are the first characters in SamAccountNames we want to omit;  If you aren't excluding any accounts that contain certain characters/substrings in the SamAccountName, keep this default value as-is
        [Parameter()]
        [string[]]
        $SamAccountNameStopHereList 
      )
      
      $Results = @()
    
      foreach ($ReporteeSearchBaseFormat in $DirectReports) {
    
        # If the current item is '-notlike' the exclusion string found in $NotLikeSearchBaseOU 
        if ($ReporteeSearchBaseFormat -notlike "$NotLikeSearchBaseOU") { 
        
          $ReporteeADObject = Get-ADUser -SearchBase $ReporteeSearchBaseFormat -Filter * -Properties DirectReports, Mail
    
          # If the current AD User object is enabled and the SamAccountName does '-notmatch' the exclusion string found in $NotMatchSamAccountName
          if ($ReporteeADObject.Enabled -eq $true -and $ReporteeADObject.SamAccountName -notmatch "$NotMatchSamAccountName") {
            
            # We create a new object with custom properties...
            $prop = [ordered]@{
              Name = $ReporteeADObject.Name
              SamAccountName = $ReporteeADObject.SamAccountName
              Mail = $ReporteeADObject.Mail
              ExecutiveManager = $ExecutiveManagerName
            }
            $obj = New-Object -TypeName psobject -Property $prop
            # ... and add that to the $Results array
            $Results += $obj
            
            ############################################
            # This next block is to decide whether or not to continue down the chain / branch or to stop
            if ($ReporteeADObject.SamAccountName -in $SamAccountNameStopHereList) {            
              # Because the AD User Object is in the $SamAccountNameStopHereList we will not go further down the chain
            }
            else {   
              # If the current AD User object has a populated value for the 'DirectReports' property, we use recursion to call this function itself, and continue down the chain of command, adding the results to the $Results array
              if ($ReporteeADObject.DirectReports) {
                Get-ADDirectReportsTally -DirectReports $ReporteeADObject.DirectReports -ExecutiveManagerName $ExecutiveManagerName -NotLikeSearchBaseOU $NotLikeSearchBaseOU -NotMatchSamAccountName $NotMatchSamAccountName
              }
            }
    
          }
    
        }
    
      }
      # Once all of the chain has been processed, return the $Results array
      Write-Output $Results
      
    }
    

  }
  
  process {

    $FinalResults = @()
    
    foreach ($ExecManagerSamAccount in $ExecutiveManagerSamAccountNames) {
      $ExecManagerADObject = Get-ADUser -Identity $ExecManagerSamAccount -Properties DirectReports, Mail

      $TempResults = Get-ADDirectReportsTally -DirectReports $ExecManagerADObject.DirectReports -ExecutiveManagerName $ExecManagerADObject.Name -SamAccountNameStopHereList $ExecutiveManagerSamAccountNames

      $FinalResults += $TempResults
    }

    Write-Output $FinalResults

  }
  
  end {}
}