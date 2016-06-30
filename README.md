# Send-XCommand
Powershell Cmdlet 'Send-XCommand' for sending xConfiguraiton &amp; xCommand to Cisco TelePresence Endpoints i.e. DX70 &amp; DX80

Cisco TelePresence endpoints run Collaboration Endpoint (CE) operating system and provide an PushXML API to update the configuration of the endpoint as well as send commands for remote operation of the device. This script is used to execute xCommands on one or more Cisco TelePresence endpoints using HTTP.

The script is published on the [Powershell Gallery](https://www.powershellgallery.com/packages/Send-XCommand) and can be easily installed on any Windows machine with **ONE** of the followng pre-requisites:

* Windows 10
* [Windows Management Foundation 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)
* [MSI Installer for Powershell 3 & 4](https://www.microsoft.com/en-us/download/details.aspx?id=51451)

## Installation
Use the following command to download and install the 'Send-XCommand' powershell Cmdlet:

```
Install-Script -Name Send-XCommand -Scope CurrentUser
```
Note: You may be prompted to install Nuget and/or permit the download from the Powershell Gallery repository
Note: You may need to run the powershell console as an administrator i.e. 'Run As'

## Sending xCommands

Restart the TelePresence endpoint with IP Address '10.40.0.19' using username: "admin" and password: "pass1"
```
send-XCommand "10.40.0.19" "xCommand SystemUnit Boot Action: Restart" "admin" "pass1"
```

Set the Provisioning Mode to CUCM on device "10.40.0.19" using default credentials
```
send-XCommand "10.40.0.19" "xConfiguration Provisioning Mode: CUCM"
```
Note: If no username/password is specified the default 'admin/<blank>' is used

## Setting Service Mode Remotely
When converting the DX70 & DX80 models from Android to Collaboration Endpoint (CE) operating system the endpoint will be in a default state when initally upgraded to CE. In this default state the end user normally has to select the service mode via the touch interface, however the following set of powershell commands can be used to remotely select the service mode allowing the endpoint to re-register.

```
Send-XCommand "10.40.0.19" "xConfiguration Experimental SystemUnit RunStartupWizard : false"
Send-XCommand "10.40.0.19" "xConfiguration Provisioning Mode: CUCM"
Send-XCommand "10.40.0.19" "xCommand SystemUnit Boot Action: Restart"
```

## Setting CUCM Server
If there is no DHCP Option 150 availalbe then it is nessary to specify the IP Address of the CUCM TFPT server the endpoint should register with. The followng can be used to set the CUCM TFTP Server address to '10.40.0.211':

```
Send-XCommand "10.40.0.19" "xConfiguration Provisioning ExternalManager Address: 10.40.0.211"
```

## Setting Service Mode & CUCM Server Remotely
If you do not have DHCP Option 150 set you can combine setting the CUCM TFTP Server and the Service mode in a single set of commands as follows:

```
Send-XCommand "10.40.0.19" "xConfiguration Experimental SystemUnit RunStartupWizard : false"
Send-XCommand "10.40.0.19" "xConfiguration Provisioning Mode: CUCM"
Send-XCommand "10.40.0.19" "xConfiguration Provisioning ExternalManager Address: 10.40.0.211"
Send-XCommand "10.40.0.19" "xCommand SystemUnit Boot Action: Restart"
```

## Converting DX70 & DX80 from Android to CE
[UnifiedFX](http://www.unifiedfx.com) provide the ability to migrate the device configuration in CUCM taking care of converting all the complex device settings from the Cisco DX to Cisco TelePresence DX model types. Two UnifiedFX products [MigrationDX](http://www.unifiedfx.com/migrationdx) & [MigrationFX](http://www.unifiedfx.com/migrationfx) greatly simplify the migration from one device/model to another. MigrationDX is only for converting DX endpoints to/from Android/CE, MigrationFX includes the capability of MigrationDX but can also be used to replace and/or provision standard Cisco IP desk phones (i.e. replace a Cisco 7940 with a Cisco 8841).

## Setting Service Mode on multiple devices
Using [MigrationDX](http://www.unifiedfx.com/migrationdx) you can export a CSV file from the 'Phones' page that includes the last seen IP Address of the DX endpoints. You can use the following Powershell commands to set the service mode in bulk, which will allow the endpoints to attempt re-register with CUCM without having to visit the device. Once the endpoints attempt to re-register you will typically see 'Model Mismatch' within the 'Phones' page of [MigrationDX](http://www.unifiedfx.com/migrationdx), at that point you can use [MigrationDX](http://www.unifiedfx.com/migrationdx) to convert the model type from 'Cisco DX' to 'Cisco TelePresence DX' enabling the newly converted endpoints to register with the new model type.

```
$devices = import-csv -Path "Phone List.csv"
$devices."IP Address" | ?{$_} | %{
Send-XCommand $_ "xConfiguration Experimental SystemUnit RunStartupWizard : false"
Send-XCommand $_ "xConfiguration Provisioning Mode: CUCM"
Send-XCommand $_ "xCommand SystemUnit Boot Action: Restart"
}
```
