An attempt to bring basic functionality of custom USB sounds that should come with every DM/distro by default at this point. Looking at you, GNOME.
Although in theory you can change those out of the box sometimes (For GNOME: /usr/share/sounds/freedesktop/stereo/), generally there are a variety of restrictions, such as .mav file size.

**Requirements**
systemd
aplay

**Installation process**
1. git clone https://github.com/esoterikwa/ucsn
2. cd usb-udev-notifications
3. sudo chmod +x USB_custom_alerts.sh
4. Change both .mav sound files to your liking
5. sudo ./USB_custom_alerts.sh

**Tested on**
-EndeavourOS+GNOME
