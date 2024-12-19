#!/bin/bash

pink_c='\e[38;5;212m'
default_c='\033[0m'

grep_users () {
  local nou
  nou=$(ls /home | wc -l)

  if [ "$nou" -eq "1" ]; then
    username=$(ls /home)
    echo -e "Only one user was found - ${pink_c}$username${default_c}"
      else {
        echo "More than one user found."
      }
  fi
  
  echo -e "Options:"
  [ "$nou" -eq 1 ] &&
  echo -e "0 - Use user as a username"
  echo -e "1 - Manually input username"
  echo -e "2 - Exit"
  echo ""

  while true; do
    read -p "Choose an option: " answer
    case $answer in
      0)
        if [ "$nou" -eq 1 ]; then
          echo -e "Using username ${pink_c}$username${default_c}"
          break
        else
          echo "Invalid option for the current context."
        fi
        ;;
      1)
        echo "Enter your username:"
        read -r username
        echo ""
        echo -e "Continuing with ${pink_c}$username${default_c} username"
        break
        ;;
      2)
        echo "Exiting."
        exit 0
        ;;
      *)
        echo "Please pick a valid option (0, 1, or 2)."
        ;;
    esac
  done
}

# main install function
install_function () {
  echo ""
  echo "The Installation will now proceed"

  # creating systemd services
  if [ ! -d "/etc/sounds" ]; then
    echo "Directory /etc/sounds does not exist, creating."
    mkdir  /etc/sounds
  fi

  # Copy sound files
  if [ -f "USB-unplug.wav" ] && [ -f "USB-plug.wav" ]; then
    cp USB-unplug.wav /etc/sounds/USB-unplug.wav
    cp USB-plug.wav /etc/sounds/USB-plug.wav
  else
    echo "Required sound (.wav) files are either absent or have incorrect names. Exiting."
    exit 1
  fi

  # Create systemd service files
  touch /etc/systemd/system/usb-plug.service
  touch /etc/systemd/system/usb-unplug.service

  {
    echo '[Unit]'
    echo 'Description = Play USB sound'
    echo ""
    echo '[Service]'
    echo "User = ${username}"
    echo 'Type = oneshot'
    echo 'Environment = "XDG_RUNTIME_DIR=/run/user/1000"'
    echo 'ExecStart = -/usr/bin/aplay /etc/sounds/USB-plug.wav'
  } > /etc/systemd/system/usb-plug.service

  {
    echo '[Unit]'
    echo 'Description = Play USB sound'
    echo ""
    echo '[Service]'
    echo "User = ${username}"
    echo 'Type = oneshot'
    echo 'Environment = "XDG_RUNTIME_DIR=/run/user/1000"'
    echo 'ExecStart = -/usr/bin/aplay /etc/sounds/USB-unplug.wav'
  } > /etc/systemd/system/usb-unplug.service

  # Create udev rules
  touch /etc/udev/rules.d/100-usb.rules

  echo 'ACTION=="add", SUBSYSTEM=="usb", KERNEL=="*:1.0", RUN+="/bin/systemctl start usb-plug"' > /etc/udev/rules.d/100-usb.rules
  echo 'ACTION=="remove", SUBSYSTEM=="usb", KERNEL=="*:1.0", RUN+="/bin/systemctl start usb-unplug"' >> /etc/udev/rules.d/100-usb.rules

  # Reload systemd and udev rules
  systemctl daemon-reload
  systemctl restart systemd-udevd

  echo ""
  echo -e "Successful Installation. Plug in a USB device to test."
  echo ""
}

# Uninstall function
uninstall_function ()
{
  echo "Removing audio files..."
  rm -f /etc/sounds/USB-plug.wav
  rm -f /etc/sounds/USB-unplug.wav
  
    if [ ! -f "/etc/sounds/USB-unplug.wav" ] && [ ! -f "/etc/sounds/USB-plug.wav" ]; then
      echo "Both plug and unplug notif. were removed."
    fi
  
  echo ""
  echo "Removing systemd.services..."
  rm -f /etc/systemd/system/usb-unplug.service
  rm -f /etc/systemd/system/usb-plug.service

    if [ ! -f "/etc/systemd/system/usb-unplug.service" ] && [ ! -f "/etc/systemd/system/usb-plug.service" ]; then
      echo "Both plug and unplug services. were removed."
    fi

  echo ""
  echo "Removing udev rule..."
  rm -f /etc/udev/rules.d/100-usb.rules

    if [ ! -f "/etc/udev/rules.d/100-usb.rules" ]; then
    echo "udev rule was removed as well."
    fi
    
  systemctl daemon-reload
  systemctl restart systemd-udevd

  echo ""
  echo "Done."
}

init_menu() {
  echo "An attempt to bring basic functionality of custom USB sounds that should come with every DM by default. Looking at you, GNOME."

  # Check for root
  if [ $EUID -ne 0 ]; then
      echo "Please run as root"
      exit 1
  fi

  #check dependency: systemd, aplay
  echo ""
  echo "Checking dependencies..."
  if ! command -v systemctl &>/dev/null; then
    echo "Systemd is not installled. Exiting."
    exit 1
  else
    echo "Systemd is installled."
  fi

  if ! command -v aplay &>/dev/null; then
    echo "Aplay is not installed. Exiting."
    exit 1
  else
    echo "Aplay is installed."
  fi
  echo ""

  echo "Options:"
  echo -e "0 - Install USB sounds"
  echo -e "1 - Start uninstall process"
  echo -e "2 - Exit"
  echo ""

  while true; do
      read -e -p "Pick one of actions: " action
      case $action in
          0)
            echo ""
            echo "Start Installation of Sounds"
            echo ""
            grep_users
            echo ""
            install_function
            break;;
          1)
            echo ""
            echo "Start Uninstall"
            echo ""
            uninstall_function
            break;;
          2)
            echo ""
            echo "Exiting."
            echo 0
            exit;;
          *)
            echo "Invalid action. Please pick 0, 1, or 2."
            ;;
      esac
  done
}

init_menu