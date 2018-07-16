# =============================================================================
#  Created On:   2018/06/24 @ 00:08
#  Created By:   Alcha
#  Organization: HassleFree Solutions, LLC
#  Filename:     Get-PrettyHTMLTable.ps1
#  Description:  Helps create a better HTML table by using Bootstrap 4.
# =============================================================================
# Contains the headings for the table
$ColumnHeadings = @()

# Contains row data
[System.Collections.ArrayList]
$Rows = New-Object -TypeName System.Collections.ArrayList

function Add-Headings () {
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [System.String[]]
    $Headings
  )

  foreach ($Heading in $Headings) {
    $ColumnHeadings.Add($Heading)
  }
}

function Add-Row () {
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [System.Collections.Hashtable]
    $RowIn
  )

  $Rows.Add($RowIn)
}

function Get-Rows () {
  param ()

  foreach ($Row in $Rows) {
    Write-Host $Row
  }
}

function New-PrettyHTMLTable {
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [System.String[]]
    $Headings,

    [Parameter(Mandatory = $true, Position = 1)]
    [System.Collections.ArrayList]
    $RowData
  )
}

Out-File E:\Log.log -InputObject "Things are working!"
