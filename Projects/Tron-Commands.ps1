# =============================================================================
#  Created on:   6/7/2018 @ 22:08
#  Created by:   Alcha
#  Organization: HassleFree Solutions, LLC
#  Filename:     Tron-Commands.ps1
# =============================================================================

<#
.SYNOPSIS
  Connects to the Tron server as Alcha using SSH. (e.g. ssh alcha@tron.ninja)
#>
function Connect-Tron() {
  [CmdletBinding()]
  [Alias('Tron')]
  param ()

  ssh alcha@tron.ninja
}