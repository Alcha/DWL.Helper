# ===========================================================================
#  Created on:   06/16/2018 @ 10:38
#  Created by:   Alcha
#  Organization: HassleFree Solutions, LLC.
#  Filename:     Test-DownloadSpeed.ps1
#  Notes: This script is horrendous. I pulled it from the PowerShell Gallery and
#  attempted to clean it up but every change I make only breaks it. It functions
#  so I'm leaving it as is, despite it's hideous nature.
# ===========================================================================

# .EXTERNALHELP .\Help_Files\Test-DownloadSpeed-Help.xml
function Test-DownloadSpeed() {
  [CmdletBinding()]
  param ()

  Write-Progress -Activity 'Download Speed Test' -Status 'Testing download speed...' -PercentComplete 0

  <#
  Using this method to make the submission to speedtest. Its the only way i could figure out how to interact with the page since there is no API.
  More information for later here: https://support.microsoft.com/en-us/kb/290591
  #>
  $objXmlHttp = New-Object -ComObject MSXML2.ServerXMLHTTP
  $objXmlHttp.Open("GET", "http://www.speedtest.net/speedtest-config.php", $False)
  $objXmlHttp.Send()

  #Retrieving the content of the response.
  [xml]$content = $objXmlHttp.responseText

  <#
  Gives me the Latitude and Longitude so i can pick the closer server to me to actually test against. It doesnt seem to automatically do this.
  Lat and Longitude for tampa at my house are $orilat = 27.9238 and $orilon = -82.3505
  This is corroborated against: http://www.travelmath.com/cities/Tampa,+FL - It checks out.
  #>
  $oriLat = $content.settings.client.lat
  $oriLon = $content.settings.client.lon

  #Making another request. This time to get the server list from the site.
  $objXmlHttp1 = New-Object -ComObject MSXML2.ServerXMLHTTP
  $objXmlHttp1.Open("GET", "http://www.speedtest.net/speedtest-servers.php", $False)
  $objXmlHttp1.Send()

  #Retrieving the content of the response.
  [xml]$ServerList = $objXmlHttp1.responseText

  $cons = $ServerList.settings.servers.server

  #Below we calculate servers relative closeness to you by doing some math against latitude and longitude.
  foreach ($val in $cons) {
    $R = 6371;
    [float]$dlat = ([float]$oriLat - [float]$val.lat) * 3.14 / 180;
    [float]$dlon = ([float]$oriLon - [float]$val.lon) * 3.14 / 180;
    [float]$a = [math]::Sin([float]$dLat / 2) * [math]::Sin([float]$dLat / 2) + [math]::Cos([float]$oriLat * 3.14 / 180 ) * [math]::Cos([float]$val.lat * 3.14 / 180 ) * [math]::Sin([float]$dLon / 2) * [math]::Sin([float]$dLon / 2);
    [float]$c = 2 * [math]::Atan2([math]::Sqrt([float]$a ), [math]::Sqrt(1 - [float]$a));
    [float]$d = [float]$R * [float]$c;

    $ServerInformation +=
    @([PSCustomObject]@{Distance = $d; Country = $val.country; Sponsor = $val.sponsor; Url = $val.url })
  }

  $ServerInformation = $ServerInformation | Sort-Object -Property distance

  #Runs the functions 4 times and takes the highest result.
  Write-Progress -Activity 'Download Speed Test' -Status 'Testing download speed...' -PercentComplete 25
  $DLResults1 = DownloadSpeed($ServerInformation[0].url)
  $SpeedResults += @([PSCustomObject]@{Speed = $DLResults1; })

  Write-Progress -Activity 'Download Speed Test' -Status 'Testing download speed...' -PercentComplete 50
  $DLResults2 = DownloadSpeed($ServerInformation[1].url)
  $SpeedResults += @([PSCustomObject]@{Speed = $DLResults2; })

  Write-Progress -Activity 'Download Speed Test' -Status 'Testing download speed...' -PercentComplete 75
  $DLResults3 = DownloadSpeed($ServerInformation[2].url)
  $SpeedResults += @([PSCustomObject]@{Speed = $DLResults3; })

  Write-Progress -Activity 'Download Speed Test' -Status 'Testing download speed...' -PercentComplete 100
  $DLResults4 = DownloadSpeed($ServerInformation[3].url)
  $SpeedResults += @([PSCustomObject]@{Speed = $DLResults4; })

  $UnsortedResults = $SpeedResults | Sort-Object -Property speed
  $WanSpeed = $UnsortedResults[3].speed

  Write-Output "Wan Speed is $($Wanspeed) Mbit/Sec"
}

<#
.SYNOPSIS
  Used internally by the Test-DownloadSpeed script to test against a URL.

.PARAMETER strUploadUrl
  The url to of the Speedtest.net server we're testing against.

.NOTES
  Should never be called directly as it's done by the Test-DownloadSpeed func.
#>
function DownloadSpeed($strUploadUrl) {
  $topServerUrlSpilt = $strUploadUrl -split 'upload'
  $url = $topServerUrlSpilt[0] + 'random2000x2000.jpg'
  $col = new-object System.Collections.Specialized.NameValueCollection
  $wc = new-object system.net.WebClient
  $wc.QueryString = $col
  $downloadElaspedTime = (measure-command {$webpage1 = $wc.DownloadData($url)}).totalmilliseconds
  $string = [System.Text.Encoding]::ASCII.GetString($webpage1)
  $downSize = ($webpage1.length + $webpage2.length) / 1Mb
  $downloadSize = [Math]::Round($downSize, 2)
  $downloadTimeSec = $downloadElaspedTime * 0.001
  $downSpeed = ($downloadSize / $downloadTimeSec) * 8
  $downloadSpeed = [Math]::Round($downSpeed, 2)
  return $downloadSpeed
}
