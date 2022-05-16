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

## Getting necessary apps aka HomeBrew
I like packet managers and I cannot lie.

Get HomeBrew, use it.

First install XCode command line tools: `sudo xcode-select --install`

After that, go to HomeBrew's website https://brew.sh/ and you can use the one-liner to install it, **AFTER YOU HAVE AT LEAST GLANCED THROUGH THE SCRIPT** don't just copy&paste that kind of installer script just because someone on GitHub says so.

After that, here's a list of stuff I've found useful for me:

```
brew install \
  tree \
  berkeley-db \
  git \
  mpdecimal \
  perl \
  sqlite \
  ca-certificates \
  ipcalc \
  ncurses \
  vim \
  gdbm \
  libyaml \
  readline \
  xz \
  gettext \
  lua \
  pcre2 \
  ruby \
  nmap 
  
brew install --cask \
  xquartz \
  cheatsheet \
  rectangle \
  vlc \
  betterzip \
  qlcolorcode \
  quicklook-json \
  chromium \
  qlmarkdown \
  spotify \
  drawio \
  qlprettypatch \
  suspicious-package \
  google-chrome \
  qlstephen \
  visual-studio-code \
  keepassxc \
  quicklook-csv \
  webpquicklook \
  wireshark \
  balenaetcher \
  paintbrush
```
And to get virt-manager and virt-viewer I used this Brew tap + instructions https://github.com/Damenly/homebrew-virt-manager

## Terminal stuff
I opted for using Apple provided zsh (you can get one from brew also) and iTerm2 from their website https://iterm2.com/ - if you like, you can get iTerm2 also via brew.

As for iTerm2 settings I recommend finding what suits you. To move between machines use these instructions: https://gitlab.com/gnachman/iterm2/-/wikis/Move-Settings-Between-Machines

iTerm2 cheatsheet: https://gist.github.com/squarism/ae3613daf5c01a98ba3a

As for zsh, I opted to use my legacy zshrc and combination with https://github.com/peterhil/zen - at this stage I again repeat my original point, I recommend the original source over my modifications for others expect me.

If you still want to continue and use my setup, head to the zsh folder.

### ssh + vim
Also included here are example ssh-config for useful stuff and also my current vimrc which is in horrible shape as I haven't given it the attention it needs. Go for The Ultimate vimrc and save yourself a lot of trouble.

Add your ssh key(s) to the Keychain, instructions here: https://rob.cr/blog/using-ssh-agent-mac-os-x/#:~:text=SSH%20agent%20allows%20a%20user,the%20pass%20phrase(s).




## Virtualization
In my work, I usually want to connect to multiple different networks at the same time and test various connectivity related stuff and make sure that the traffic goes through the network under test and not locally. As such, one simple way to achieve this is to use VMs connected to different VLAN IDs.

Obviously, things are never so simple as I just couldn't attaching VM interface to VLAN interface to work. During debugging, I noticed that egress packets were fine but ingress packets were malformed. More details are currently available at https://github.com/utmapp/UTM/issues/3902

So local VMs for this task are a no-go. Let's just setup Linux machine and run the VMs there are connect to them using Spice? Yeah, otherwise it's nice but I didn't get copy&paste working between my Mac and the target VM.

Eventually, I got annoyed and decided to do a ugly shell-script to help me in:
  - connecting to the VMs using virt-viewer (we get ssh-connection to connect, no need to hazzle with Spice security setup)
  - able to paste stuff to the VM either from cli or file on my Mac.

It can be found in bin/vm-helper.sh 

Useful links and source for the above:
https://johnsiu.com/blog/macos-kvm-remote-connect/
https://gist.github.com/nhoriguchi/9425402


## Docker
I'll be using colima

```
brew install docker
brew install docker-compose
brew install colima
```

Example of starting it with reasonable\* (\*YMMV) parameters:
`colima start --cpu 4 --memory 4 --mount /Users/$USER/git:w --mount /Users/$USER/.ssh:w --mount /Users/$USER/.ansible:w --mount /Users/$USER/Downloads:w`



