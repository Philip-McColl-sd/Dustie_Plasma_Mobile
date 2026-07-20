# We got to get some shit working
## How to begin to flex if there is no screenfetch?
### Install screenfetch with:
```bash
sudo apt install screenfetch
```
## Then flex with:
```bash
stardust@halley:~ $ screenfetch
         _,met$$$$$gg.           stardust@halley
      ,g$$$$$$$$$$$$$$$P.        OS: Debian 13 trixie
    ,g$$P""       """Y$$.".      Kernel: aarch64 Linux 6.12.47+rpt-rpi-v8
   ,$$P'              `$$$.      Uptime: 8m
  ',$$P       ,ggs.     `$$b:    Packages: 1802
  `d$$'     ,$P"'   .    $$$     Shell: bash 5.2.37
   $$P      d$'     ,    $$P     Disk: 9.0G / 61G (16%)
   $$:      $$.   -    ,d$$'     CPU: ARM Cortex-A72 @ 4x 1.8GHz
   $$\;      Y$b._   _,d$P'      GPU:
   Y$$.    `.`"Y$$$$P"'          RAM: 2036MiB / 7820MiB
   `$$b      "-.__
    `Y$$
     `Y$$.
       `$$b.
         `Y$$b.
            `"Y$b._
                `""""
```
## Install brave Nightly a good web browser free of advertisement
### Just run the following command if curl is installed
```bash
curl -fsS https://dl.brave.com/install.sh | CHANNEL=nightly sh
```
## Install Flatpack Software
### Install flatpack
```bash
sudo apt install flatpak
```
Install the Software Flatpak plugin:
```bash
sudo apt install plasma-discover-backend-flatpak
```
Add the Flathub repository:
```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
Then restart!!
### Install Whatsapp