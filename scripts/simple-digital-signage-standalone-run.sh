#!/bin/bash

################################################################################################
#Konfigurierendes Skript zu Client und Standalone version der RaspberryPi Simple DigitalSignage#
################################################################################################


#Farbeinstellungen
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # Keine Farbe


#Willkommensnachricht
clear
echo -e "Willkommen beim RaspberryPi SIMPLE DigitalSignage Installations- und Konfigurationsassistenten!
Zuerst prüfen wir alle benötigten Pakete ..."

#Pakete prüfen
echo -e "${YELLOW}Pakete überprüfen ...${NC}"
echo -e "Liste der benötigten Pakete: wget, curl"

read -r -p "Möchten Sie Pakete überprüfen? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installiert")
  if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installiert") -eq 0 ];
  then
    echo -e "${YELLOW}Installieren wget${NC}"
    apt-get install wget --yes;
    elif [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installiert") -eq 1 ];
    then
      echo -e "${GREEN}wget ist installiert!${NC}"
  fi

CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installiert")
  if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installiert") -eq 0 ];
  then
    echo -e "${YELLOW}Installieren curl${NC}"
    apt-get install curl --yes;
    elif [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installiert") -eq 1 ];
    then
      echo -e "${GREEN}curl ist installiert!${NC}"	  
  fi

  ;;

    *)

  echo -e "${RED}
  Paketprüfung wird ignoriert!
  Bitte beachten Sie, dass wget, curl und andere Software wird möglicherweise nicht installiert!
  ${NC}"

  ;;
esac

# Verwendung von Remotedesktop installieren
echo -e "${YELLOW}Verwendung von Remotedesktop"

read -r -p "Wollen Sie von Windows System aus, ein Remotedesktop Verbindung zu RaspberryPi Simple DigitalSignage herstellen?  [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
	
sudo apt-get purge realvnc-vnc-server -y	
sudo apt-get install xrdp -y

echo -e "Remote Desktop Protokoll installiert, bitte lesen Sie dazu Wiki-Page!"


#Gleich los legen
echo -e "${YELLOW}Vorbereitung...${NC}"

read -r -p "Wollen Sie gleich loslegen und RaspberryPi SIMPLE DigitalSignage starten? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
  
cat >/home/pi/.config/marketing.sh<<EOL
#!/bin/bash
xset -dpms
xset s off
xset s noblank

export DISPLAY=:0
unclutter &

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

/usr/bin/chromium-browser --noerrdialogs --kiosk --incognito http://raspberrypi/?foyer_display=standalone &

while (true)
 do
  xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
  sleep 15
done
EOL

echo -e "${GREEN}RaspberryPi SIMPLE DigitalSignage eingerichtet!${NC}"

        ;;
    *)

  echo -e "${RED}RaspberryPi SIMPLE DigitalSignage könnte nicht eingerichtet werden!${NC}"

        ;;
esac

#creating of swap
echo -e "Im nächsten Schritt werden wir SWAP erstellen"

read -r -p "Brauchen Sie SWAP? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  RAM="`free -m | grep Mem | awk '{print $2}'`"
  swap_allowed=$(($RAM * 2))
  swap=$swap_allowed"M"
  fallocate -l $swap /var/swap.img
  chmod 600 /var/swap.img
  mkswap /var/swap.img
  swapon /var/swap.img

  echo -e "${GREEN}RAM erkannt: $RAM
  Swap wurde erstellt: $swap${NC}"
  sleep 5

        ;;
    *)

  echo -e "${RED}Sie haben keinen Swap für eine schnellere Systemarbeit erstellt. Sie können dies manuell ausführen.${NC}"

        ;;
esac

echo -e "${GREEN}RaspberryPi SIMPLE DigitalSignage ist erfolgreich erstellt und konfiguriert!${NC}"
sleep 3
echo -e "Installation und Konfiguration erfolgreich abgeschlossen.
Twitter: @LinuxBuilders
Project-Page: https://github.com/mosesdeutschlaender/Simple-Digital-Signage
Bye!"

  sleep 7
sudo reboot