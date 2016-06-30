<#PSScriptInfo 
.TITLE Send-XCommand
.VERSION 0.1
.GUID 95e1ac25-a403-44ee-9616-6f2ae9133976
.AUTHOR Stephen Welsh @stephenwelsh
.COMPANYNAME UnifiedFX 
.COPYRIGHT 2016 UnifiedFX. All rights reserved.
.TAGS Cisco Collaboration UnifiedFX xCommand xConfiguration
.LICENSEURI https://opensource.org/licenses/MIT
.PROJECTURI https://github.com/unifiedfx/Send-XCommand
.ICONURI http://www.unifiedfx.com/logo.png 
.RELEASENOTES 
V0.1 Initial publication 
#>

<# 
.SYNOPSIS 
   Send xConfiguraiton & xCommand to Cisco TelePresence Endpoints i.e. DX70 & DX80

.DESCRIPTION 
   Cisco TelePresence endpoints run Collaboration Endpoint (CE) operating system and provide an PushXML API to update
   the configuration of the endpoint as well as sending commands for remote operation of the device.
   If no username/password is specified the default 'admin/<blank>' is used

.PARAMETER IPAddress
   The IP Address of the Cisco TelePresence Endpoint

.PARAMETER XCommand
   The xConfiguraiton or xCommand to send to the Cisco TelePresence Endpoint

.PARAMETER UserName
   The Username to use when authenticating to the Cisco TelePresence Endpoint, default ="admin"

.PARAMETER Password
   The Password to use when authenticating to the Cisco TelePresence Endpoint, default =""

.EXAMPLE 
   #Restart the TelePresence endpoint with IP Address '10.40.0.19' using username: "admin" and password: "pass1"
   send-XCommand "10.40.0.19" "xCommand SystemUnit Boot Action: Restart" "admin" "pass1"
 
.EXAMPLE 
   #Set the Provisioning Mode to CUCM on device "10.40.0.19" using default credentials
   send-XCommand "10.40.0.19" "xConfiguration Provisioning Mode: CUCM"

.NOTES
   This script was written by UnifiedFX (http://www.unifiedfx.com)
   Author: Stephen Welsh @stephenwelsh
   Company: UnifiedFX
   Website: http://www.unifiedfx.com
   Copyright: 2016 UnifiedFX. All rights reserved.
   License: https://opensource.org/licenses/MIT
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=0)]$IPAddress,
    [Parameter(Mandatory=$True,Position=1)]$XCommand,
    [Parameter(Mandatory=$False,Position=2)][string]$UserName="admin",
    [Parameter(Mandatory=$False,Position=3)][string]$Password="")
Process
{
    $sections = $XCommand -split ":"
    $parts = $sections[0] -split " "
    $xml = "<{0}/>" -f $parts[0].TrimStart("x")
    $doc = [System.Xml.Linq.XDocument]::Parse($xml)
    $parent = $doc.Root
    $parts | select -skip 1 | ? {$_} | %{$parent.Add([System.Xml.Linq.XElement]::Parse("<{0}/>" -f $_)); $parent = $parent.Descendants($_)[0]}
    $parent.Add($sections[1].TrimStart(" ").TrimEnd(" ")) 
    $xml = $doc.ToString()
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f $UserName,$Password)))
    $headers = @{"Authorization" = "Basic "+ $base64AuthInfo;}
    $url = "http://"+ $IPAddress +"/putxml";
    $resp = try { Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ContentType "text/xml" -Body $xml; } catch { $_.Exception.Response }    
}

