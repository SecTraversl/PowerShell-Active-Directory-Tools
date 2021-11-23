<#
.SYNOPSIS
  The "Get-ADDirectReportsTally" function takes the value of the 'DirectReports' property from an AD User object and returns pertinent information about each of 'DirectReports' AD User accounts.

.EXAMPLE
  PS C:\> Get-ADUser -Identity Victour.Parr -Properties DirectReports | Get-ADDirectReportsTally -ExecutiveManagerName 'None Specified'

  Name          SamAccountName Mail                       ExecutiveManager
  ----          -------------- ----                       ----------------
  Darin Pittin  Darin.Pittin   Darin.Pittin@MyDomain.com  None Specified
  Sheri Boise   Sheri.Boise    Sheri.Boise@MyDomain.com   None Specified
  Marve Smirnov Marve.Smirnov  Marve.Smirnov@MyDomain.com None Specified



  Here we take a reference AD User object with the 'DirectReports' property, and pipe that object into the "Get-ADDirectReportsTally" function.  The '-ExecutiveManagerName' parameter is a free-text field allowing us to put any value we wish, and in this case we used 'None Specified'.  The results we receive back pertain to any other AD User objects that report to the original AD User account we referenced.

.NOTES
  Name:  Get-ADDirectReportsTally.ps1
  Author:  Travis Logue
  Version History:  1.1 | 2021-10-08 | Initial Version
  Dependencies:  
  Notes:
  - 

  .
#>
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
  
  begin {}
  
  process {
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
  
  end {}
}