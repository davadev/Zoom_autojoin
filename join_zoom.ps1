##=============================================================================================================================================================
## Author: daniel.vavrik@yahoo.com
## Version: 1.21 Beta
## Compatibility: windows 10, windows 11
## Last Update: 10.01.2022 06:55
## Purpose: This scripts automatize login into zoom Meeting for those who are less technically able, or simpy want automatize it.
##          With this script you only need to press power button and within few seconds you will be automatically joined in zoom meeting.
##
## Dependencies: Windows Autologin -> must be setup (for windows 11 you must edit registry to see this option)
##                                 -> Press "win + R" and type regedit 
##                                 -> navigate to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device
##                                 -> Double-click "DevicePasswordLessBuildVersion" to open. Then change the value to 0 and close out.
##                                 -> Press "win + R" and type "netplwiz"
##                                 -> "Users must type password" uncheck, and then type your username and password
##                                 -> If there are more Windows profiles you need to edit registry default username 
##                                 -> navigate to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
##                                 -> Double-click "DefaultUserName” to open and type the username with which Windows should auto login
##
##               KEEPASS2 -> You must have keepass2 installed and created database which uses windows login
##                        -> you can download keepass here: https://keepass.info/   
##                        -> disable keepass check for update
##                        -> Create a keepass entry; username shoulf be "Meeting ID" and password "Meeting password"
##                        -> add custome autotype sequence:
##                        -> {TAB}{ENTER}{DELAY 4500}{USERNAME}{TAB}{TAB}{CLEARFIELD}MyName{ENTER}{DELAY 3500}{PASSWORD}{ENTER}{DELAY 1500}{ENTER}  
##                        -> set autotype shortcut in Keepass options to "alt + n"  
##
##               winget -> to use powershell packate manager you must install/update App-Installer via Windows Store (this is necessary for zoom autoupdates)
##                      -> start powershell and type "winget upgrade" to test the availability of the command (you should not get any errors)
##
##               ZOOM -> Install zoom via windows store therwise the autoupdate does not work
##                    -> You must at lease once join a zoom meeting without using this script
##                    -> set PC audio as default option when joining Zoom meeting and uncheck the dialog so that its wont be displayed anymore
##                    -> diable video preview when joining zoom meeting
##                    
##
## HOW2RUN: 1) Place the script into convinient location
##          2) Create a Task With Task scheduler which is run on windows login
##             Action -> Program/script:  PowerShell.exe
##                       Arguments (optional): -ExecutionPolicy Bypass -File C:\Users\Benutzer\Documents\join_zoom.ps1 1
##                       !! If you dont use usbstick modem or dont want to kill app at startup remove the last "1" from the line above !!
##             uncheck in conditions/power "start task only of computer is on AC Power" (for laptops necessary)
##          3) restart PC and check that the script and autotype is correctly timed. On slow PCs you might need increase the delay.
##             This requires some trial and error.
##             
##

##=============================================================================================================================================================
$run_on_win_login=$args[0]



##====================================================Get rid of  interference=================================================================================
## In ordet that this script works please disable or delay app/programs which are starting with windows. (unless the app starts in backgroung, than it is
## not necessary because it does not create any interferearing window.

## Example:
## You might be using USB Modem to connect your PC to internet. This usbstick might be oppening its configuration website in a web browser. As this website does
## not appear anywhere on the list of windows apps which starts with windows you might need to kill it with following command

## waiting for Microsoft edge to start and then kill it
    if ($run_on_win_login -eq 1)
    {
        while((get-process "msedge" -ea SilentlyContinue) -eq $Null){ 
       	 	echo "Waiting for USB Modem initialization. (Open Web configuration Interface)" 
        sleep 1
        }
        Stop-Process -Name "msedge"
    }
##====================================================avoid already started keepass or zoom===================================================================
## Keepass and zomm will be killed (if running) in order to start them in the correct order    
    if((get-process "Keepass" -ea SilentlyContinue) -ne $Null){ 
        Stop-Process -Name "Keepass"
    }
    if((get-process "Zoom" -ea SilentlyContinue) -ne $Null){ 
        Stop-Process -Name "Zoom"
    }
    

##====================================================Start keepass2 and login with Windows account=============================================================

## Start Keepass:
    Start-Process -FilePath "C:\Program Files\KeePass Password Safe 2\KeePass.exe"
    sleep 2  #waiting for at least two seconds is necessary to not send ENTER before the login dialog appears

## Open the database with pressing ENTER
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") 

##====================================================Start/Download zoom=======================================================================================

## Upgrade Zoom with winget 
    winget upgrade Zoom

## Start zoom and wait for GUI to appaer
    Start-Process -FilePath "C:\Users\User\AppData\Roaming\Zoom\bin\Zoom.exe" 
    sleep 8 #waiting at least 8 seconds is necessary as it takes some time for zoom to lunch the GUI
## !!! Adjust the path to reflect your username !!!

##====================================================Keepass autofill activation===============================================================================

## start keepass autotype sequence (alt + N)
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') 
    [System.Windows.Forms.SendKeys]
