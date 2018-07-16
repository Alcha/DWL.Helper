# =============================================================================
#  Created on:   2018/06/07 @ 22:41
#  Created by:   Alcha
#  Organization: HassleFree Solutions, LLC
#  Filename:     Get-FileEncoding.ps1
# =============================================================================

# .EXTERNALHELP .\Help_Files\Get-FileEncoding-Help.xml
function Get-FileEncoding () {
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(ParameterSetName = 'PathSet',
      Mandatory = $true,
      ValueFromPipeline = $true,
      Position = 0)]
    [System.String[]]$Path,

    [Parameter(ParameterSetName = 'FileInfoSet',
      Mandatory = $true,
      ValueFromPipeline = $true,
      Position = 0)]
    [System.IO.FileInfo[]]$FileInfo
  )

  begin {
    if ($Path) {
      $FilePaths = Get-ChildItem $Path | ForEach-Object FullName
    }
    else {
      #$FileInfo
      $FilePaths = $FileInfo.FullName
    }

    if (!($FilePaths)) { throw "No filepaths found." }
  }

  process {
    foreach ($FilePath in $FilePaths) {
      [System.Byte[]]$Byte = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $FilePath

      if ($Byte[0] -eq 0xef -and $Byte[1] -eq 0xbb -and $Byte[2] -eq 0xbf) {
        # EF BB BF	(UTF8)
        $Encoding = 'UTF8'
      }
      elseif ($Byte[0] -eq 0xfe -and $Byte[1] -eq 0xff) {
        # FE FF		(UTF-16 Big-Endian)
        $Encoding = 'Unicode UTF-16 Big-Endian'
      }
      elseif ($Byte[0] -eq 0xff -and $Byte[1] -eq 0xfe) {
        # FF FE		(UTF-16 Little-Endian)
        $Encoding = 'Unicode UTF-16 Little-Endian'
      }
      elseif ($Byte[0] -eq 0 -and $Byte[1] -eq 0 -and $Byte[2] -eq 0xfe -and $Byte[3] -eq 0xff) {
        # 00 00 FE FF	(UTF32 Big-Endian)
        $Encoding = 'UTF32 Big-Endian'
      }
      elseif ($Byte[0] -eq 0xfe -and $Byte[1] -eq 0xff -and $Byte[2] -eq 0 -and $Byte[3] -eq 0) {
        # FE FF 00 00	(UTF32 Little-Endian)
        $Encoding = 'UTF32 Little-Endian'
      }
      elseif ($Byte[0] -eq 0x2b -and $Byte[1] -eq 0x2f -and $Byte[2] -eq 0x76 -and ($Byte[3] -eq 0x38 -or $Byte[3] -eq 0x39 -or $Byte[3] -eq 0x2b -or $Byte[3] -eq 0x2f)) {
        # 2B 2F 76 (38 | 38 | 2B | 2F)
        $Encoding = 'UTF7'
      }
      elseif ($Byte[0] -eq 0xf7 -and $Byte[1] -eq 0x64 -and $Byte[2] -eq 0x4c) {
        # F7 64 4C	(UTF-1)
        $Encoding = 'UTF-1'
      }
      elseif ($Byte[0] -eq 0xdd -and $Byte[1] -eq 0x73 -and $Byte[2] -eq 0x66 -and $Byte[3] -eq 0x73) {
        # DD 73 66 73	(UTF-EBCDIC)
        $Encoding = 'UTF-EBCDIC'
      }
      elseif ($Byte[0] -eq 0x0e -and $Byte[1] -eq 0xfe -and $Byte[2] -eq 0xff) {
        # 0E FE FF	(SCSU)
        $Encoding = 'SCSU'
      }
      elseif ($Byte[0] -eq 0xfb -and $Byte[1] -eq 0xee -and $Byte[2] -eq 0x28) {
        # FB EE 28 	(BOCU-1)
        $Encoding = 'BOCU-1'
      }
      elseif ($Byte[0] -eq 0x84 -and $Byte[1] -eq 0x31 -and $Byte[2] -eq 0x95 -and $Byte[3] -eq 0x33) {
        # 84 31 95 33	(GB-18030)
        $Encoding = 'GB-18030'
      }
      else { $Encoding = 'Unknown' }

      return [PSCustomObject]@{ "File" = $FilePath; "Encoding" = $Encoding }
    }
  }
  end { }
}
