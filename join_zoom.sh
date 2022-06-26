#!/bin/bash
##==================================================================================================================================================
## Author: daniel.vavrik@yahoo.com
## Version: 0.6 Beta
## Compatibility: Ubuntu Budgie (Tested), Debian based distributions
## Last Update: 26.6.2022 10:10
## Purpose: This scripts automatize login into zoom Meeting for those who are less technically able, or simpy want automatize it.
##          With this script you only need to press power button and within few seconds you will be automatically joined in zoom meeting.
##
## Dependencies: Passwordless Linux -> This setting is strongly compromising security of your system and therefore use it mindfully
##                                  -> open Terminal and type: "sudo visudo"
##                                     find line beginning: "root..." and change it to "root    ALL=(ALL) NOPASSWD: ALL"
##                                     find line beginning: "%admin..." and change it to "%admin ALL=(ALL) NOPASSWD: ALL"
##                                     find line beginning: "%sudo..." and change it to "%sudo ALL=(ALL) NOPASSWD: ALL"
##                                     optionally you can add your user following the same pattern "My_user ALL=(ALL) NOPASSWD: ALL"
##                                     save with "ctrl + o" and confirm "ctrl +x" to close (ths applies only for "nano" text editor)
##                                  -> find in the settings of your distribution an option for autologin and activate it
##                                  -> In Energy settings disable logout and screen dimming after inactivity
##                                  -> To disable all GUI Password promts you need to create .pkla file in
##                                     "/etc/polkit-1/localauthority/50-local.d/" for example: "99-nopassword.pkla"
##                                     Note this is not possible with "sudo" and you need to login as "root".
##                                     Create file with "nano /etc/polkit-1/localauthority/50-local.d/99-nopassword.pkla"
##                                     Insert following lines:
##                                                            [No password prompt]
##                                                            Identity=unix-group:sudo
##                                                            Action=*
##                                                            ResultActive=yes
##                                     save with "ctrl + o" and confirm "ctrl +x" to close
##
##               zoom -> it is possible to install zoom from snaps but snap has usually older zoom version that might be problem
##                       when joining zoom meetings where latest zoom version is required. Therefore you should download deb packages
##                       diectly from zoom webpage. You can download and install zoom with following commands:
##                                  "wget -N https://zoom.us/client/latest/zoom_amd64.deb"
##                                  "sudo dpkg -i zoom_amd64.deb"
##                    -> Installing zoom on debian based distributions might result in missing dependencies. You have to download missing
##                       library "from https://packages.ubuntu.com/bionic/amd64/libxcb-xtest0/download" and install it with
##                       following command: "sudo dpkg -i libxcb-xtest0_1.13-1_amd64.deb" then fix zoom installation with "sudo apt install -f"
##
##
##               xdotool -> might be very likely already available on your system, if not you can install it with "sudo apt install xdotool"
##                       -> This tool allows to simulate key pressse that we will need for the automation
##==================================================================================================================================================
##
##
## Please provide Zoom credentials here:
                                        ZoomID="123456789"
                                        Username="My_Name"
                                        Password="Meeting_Password"
##
## Set up this script for autostart in your os. If you can/not set up delay in the os settings
## you can un/comment and adjust following line:
                                                sleep 25
## Timeouts needs to be adjusted to the performance of your system
##
##====================================================Update Zoom===================================================================================

## Update zoom before running. Only download if there was a change to the file on the server

cd ~/Dokumente

## if the local zoom version is outdated new version will be downloaded

wget -N https://zoom.us/client/latest/zoom_amd64.deb
LastDownload=$(stat zoom_amd64.deb | grep Geburt) # Note "Geburt" referes to file creatin time -> you might need to adjust this according the language you use in your OS
LastDownloadDATE_text=$(echo $LastDownload | awk '{print $2}')
LastDownloadDATE=$(date -d $LastDownloadDATE_text +%s)
TodayDATE_text=$(date -I)
TodayDATE=$(date -d $TodayDATE_text +%s)

## Compare dates. If installation file (zoom_amd64.deb) has todays date, then it was downloaded by wget
## which means that Update is available. If this is true installation will follow.

if [ $TodayDATE -eq $LastDownloadDATE ];
then
    echo Update available! Installing...
    sudo dpkg -i zoom_amd64.deb
    echo Update was successfully installed.
else
    echo No update available!
fi


##====================================================Start zoom and joib the meeting================================================================
##                         start zoom in background and initiate process "join meeting"
##                         Please note you need to join the meeting at least once without script and
##                         confirm automatically joing to audio and other dialogs

zoom &
sleep 6 #delay might vary depending on performance of your system
windowID1=$(xdotool getwindowfocus)
xdotool key --window $windowID1 Tab
sleep 1
xdotool key --window $windowID1 Return
sleep 4

## fill up Meeting ID and Username
windowID2=$(xdotool getwindowfocus)
xdotool key --window $windowID2 Tab
xdotool key --window $windowID2 Tab
xdotool type --window $windowID2 "$ZoomID"
xdotool key --window $windowID2 Tab
xdotool key --window $windowID2 Tab
xdotool key --window $windowID2 ctrl+a
xdotool key --window $windowID2 BackSpace
xdotool type --window $windowID2 "$Username"
xdotool key --window $windowID2 Return
xdotool key --window $windowID2 Return
sleep 7 # Here is internet speed limitation - adjust accordingly if connecting to meeting takes too long

## Enter Password
windowID3=$(xdotool getwindowfocus)
sleep 3
xdotool type --window $windowID3 "$Password"
sleep 3
xdotool key --window $windowID3 Return
