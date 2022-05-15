# arm-mac-setup
Personal notes on setting up Mac with Apple's chip to be usable

### Disclaimer
This helper repo has been created for my own benefit when I setup my new Mac to have some sort of "checkbook" on what was done to make the machine usable **from my perspective**. You are free to use this as reference, but I would recommend that you mainly use the linked sources that I used to setup everything. Those "how-tos" are much better than my collection.

## Accessories, i.e., dock for the Mac
The computer that I got was MBP 16" M1 Pro and I wanted to get a dock that:
- Was able to connect 2 4k monitors at 60Hz via HDMI (DisplayPorts in use by gaming PC)
- Was able to feed power to the Mac
- Had enough (for me) different ports
- Preferably needed only 1 cable to the Mac
- Had RJ-45 port

After some searching around the net, the Corsair TBT100 Thunderbolt 3 -dock seemed to tick all the boxes. So if you end up here based on trying to find info regarding that combo:
- All of the above ☑️

Some caveats however, I have been able to get only ~600Mbps through the RJ-45 port, by using separate RJ-45-USB-C -dongle (simultaneously with the dock) I've been getting what can be get through 1Gbps connection. So I have to connect 2 cables instead of one, bearable for me.

Also, my main monitor is Acer Predator XB271HU. With that one, if I let the monitors go to sleep and attempt to use the computer, the main display occasionally fails to start, occasionally gets assigned wrong profile and locked to max FullHD and annoy me to the excess. What I've found that if I power the monitor when I'm not using the computer, I usually get it to start normally. Again, mentioning it here just in case someone finds this through Google, I feel your pain but haven't found a definitive fix so far.

## Immediate stuff right after logging in for the first time
The first thing I did once logging in was to drop in to terminal and installed Rosetta:
`softwareupdate –install-rosetta`

After that, I jumped in to the excellent guide (remember the disclaimer? I recommend using the original sources) by Sourabh Bajaj (https://github.com/sb2nov) that can be found from here: https://sourabhbajaj.com/mac-setup/

1. Settings -> Trackpad
    -> Point&Click
    - Look up & data detectors enabled
    - Secondary click enabled
    - Tap to click enabled
    - Force Click and haptic feedback enabled
    -> Scroll&Zoom
    - Only Zoom in or out enabled
2. Settings -> Dock&Menu Bar
    - Size just under half-way, position on left, double-clock to zoom, minimize windows into application, animate opening, show indicators for open applications, automatically hide and show the menu bar in full screen
    -> Bluetooth
    - unselect Show in menu bar
    -> Battery
    - Show in Menu bar, Show percentage
    -> Clock
    - Show the day of the week, show date, digital, 24-hour clock
    -> Spotlight
    - deactivate show in menu bar
3. Finder
  -> General
  - Hard disks, external disks, CDs, DVDs and iPods on desktop
  - New Finder windows show home folder
  - disable Open folders in tabs instead of new windows
  -> Sidebar
  - Applicatgions, Desktop, Documents, Downloads, home-folder, hard disks, external disks, CDs DVDs.., Cloud storage, Bonjour, Connected servers
  -> Advanced
  - enable everything except "Folders on top On Desktop" - search to "Search This Mac"
4. Spotlight
  - uncheck unnecessary stuff
5. Keyboard
  - Use F1, F2 etc. as standard function...
6. Network
  - Drag WiFi to lowest
7. Battery
  -> Battery
  - enable optimized battery charging
  - enable show battery status in menu bar
  -> Power adapter
  - Prevent your Mac from automatically sleeping when the display is off
8. User defaults from terminal
  - Enable repeating keys by pressing and holding down keys: `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false`
  - Change the default folder for screensohts (create the folder first): `defaults write com.apple.screencapture location /path/to/screenshots/ && killall SystemUIServer`
