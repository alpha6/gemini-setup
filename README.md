
# FLASHING GEMINI

## INSTALL DEBIAN ONLY (only one partition, no other os)

## Prepare firmware

So as planet no provide Linux only firmware you have to do it by yourself.

First of all you need to get a firmware with only one linux partition:

1. Go here :  http://support.planetcom.co.uk/partitionTool.html
1. Select gemini version (4G or wifi)
1. Boot 1 : select Sailfish (no this is not an error)
1. Reserve all partition to linux
1. Download scatter file
1. Download base firmware

Next we need a standard Debian image:
1. Boot 1 : select android standard
1. Boot 2 : select debian
1. Reserve partition for debian & android (exact sizes doesn't matter)
1. Download aditional debian firmware

At this you have 3 files :
* Scatter file for Sailfish OS
* Base firmware
* Debian firmware

Create a folder
* Unzip base firmware inside
* Unzip debian inside
* Copy scatter file inside

Now you have to replace all sailfishos_boot.img to debian_boot.img in the scatter file. 
There is a simple perl oneliner to do it:

    perl -p -i -e "s/sailfishos_boot/debian_boot/g" Gemini_x25_x27_LinuxOnly.txt

## Install and configure FlashTool

- Download FlashTool 
```
    wget http://support.planetcom.co.uk/download/FlashToolLinux.tgz
```
- Install dependecies
```
    sudo apt install libjpeg62 libaudio2
```
- Setup Udev rules

```
    sudo vim /etc/udev/rules.d/20-mm-blacklist-mtk.rules
```
```
    ATTRS{idVendor}=="0e8d", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="6000", ENV{ID_MM_DEVICE_IGNORE}="1"
```
- Restart Udev
```
    sudo service udev restart
```
- Unpack and run FlashTool
```
    tar -zxvf FlashToolLinux.tgz
    cd FlashToolLinux
    sudo ./flash_tool.sh
```

- Go to «Download» tab
-download-Agent : should be set to the file MTK_AllInOne_DA.bin (which is located in the FlashToolWindows or FlashToolLinux folder).
-scatter loading file : choose the scatter file that you have modifyed just before

all the files  in colums must be checked and location not empty

[1.1.3] BACKUP NVRAM
-go to « readback » tab
-click « add » button. A row will appear in the table under.
-click « Read Back » button
connect your PC to the left end USB-C port on your Gemini and restart the Gemini. Once booted, the flash tool will detect the unit and will write the NVRAM partition on a file on your hard disk called NVRAM0. It’s a good idea to keep this file as a backup, together with the customised Scatter file.

[1.1.4] FLASHING FIRMWARE
-click « Download » tab.
-drop-down list : select « Firmware Upgrade » option from the drop down menu
-click big « download » button
-connect your PC to the left end USB-C port on your Gemini and restart the Gemini. Once booting, the flash tool will detect the unit and will start flashing the device with the selected firmware.
-wait the end of flashing
-deconnect gemini of pc


[2] LAUNCH DEBIAN
-press esc button a long time, and wainting for the login page
-on login page, select your country in « layout » drop-down list and enter password « gemini » under the username


[3.5] UPDATE
VERY important -> do not make apt update & upgrade before THIS. If not, you will break all the file system.
[3.5.1] ADD REPOSITORY ARCHIVE KEY
-in qTerminal, on root account enter :
$ wget http://gemian.thinkglobally.org/archive-key.asc
$ apt-key add archive-key.asc
$ apt update
apt install apt-transport-https
$ apt upgrade

[3.5.3] MAJ DEBIAN 9 to 10 & Security updates
[3.5.3.1] SECURITY UPDATES
-in qTerminal, on root account enter :
$ nano /etc/apt/sources.list.d/multistrap-debian.list
-you must have :
deb [arch=arm64] http://http.debian.net/debian stretch main contrib non-free
deb-src [arch=arm64] http://http.debian.net/debian stretch main contrib non-free
-add :
deb [arch=arm64] http://security.debian.org/debian-security stretch/updates main contrib non-free
[3.5.3.2] INSTALL SOME SOFTWARE THAT ARE NOT IN THE STRETCH VERSION
-add :
deb [arch=arm64] http://http.debian.net/debian stretch-backports main contrib non-free

## Disable Wifi MAC generation

Since Android is generating a new mac address for your wifi interface at every reboot and Connman is storing the mac address in its services you would need to enter your wifi passwords every time you reboot.

Fortunately there is a way to lock the mac address.

    install hexedit: sudo apt install hexedit
    sudo hexedit /nvdata/APCFG/APRDEB/WIFI and set a mac address in bytes 04-09 (mind that the base is 0, so it starts at the 5th byte) of the first row (0)
    set the i attr on the file: sudo chattr +i /nvdata/APCFG/APRDEB/WIFI

This will lock down the mac address.

## WiFi eats battery whilst sleeping

You need to install connman-plugin-suspend-wmtwifi to avoid this:

sudo apt install connman-plugin-suspend-wmtwifi

Turns out this plugin just stops the repeated re-connection's to wifi. It still eats lots of battery.

## Libreoffice

Due to some peculiarity in the system image creation by multistrap our libreoffice installs get their diverts muddled, if you get an issue on upgrading with it complaining about libreoffice do the following:

    cd /var/cache/apt/archives
    sudo dpkg --force-all -i libreoffice*.deb

This basically forces a reinstall of all the libreoffice debian packages.

## i3

    sudo apt install i3

## Non-latin characters and meta mepped keys

For keyboard that have both Latin and native characters you pick your language variant, eg for Gemini Russia (Cyrillic):

    setxkbmap -model planetgemini -layout ru

But there is a bug in symbols mapping, so you need to fix it manually:

    sudo vim /usr/share/X11/xkb/symbols/planet_vndr/gemini


Replace word `backslash` to `slash` in lines 377 and 388 with: 
```
    -    key <AC09> { symbols[Group1] = [     Cyrillic_de,      Cyrillic_DE,      backslash,         Lstroke ] };
    +    key <AC09> { symbols[Group1] = [     Cyrillic_de,      Cyrillic_DE,          slash,         Lstroke ] };


    -    key <AC09> { symbols[Group2] = [          l,          L,      backslash,         Lstroke ] };
    +    key <AC09> { symbols[Group2] = [          l,          L,          slash,         Lstroke ] };
```


You then have two groups working with simultaneous pressing of both left and right shift keys being how you swap between which is the active group.


#Disable cert check for repo

    sudo vim /etc/apt/apt.conf.d/99disablesslcheck

    Acquire::https::gemian.thinkglobally.org::Verify-Host "false";
    Acquire::https::gemian.thinkglobally.org::Verify-Peer "false";

* https://www.oesf.org/forum/index.php?topic=36209.0
* https://support.planetcom.co.uk/index.php/Linux_Flashing_Guide
* https://github.com/gemian/gemian/wiki/DebianTP3#connman