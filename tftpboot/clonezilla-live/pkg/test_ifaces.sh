#!/bin/bash

DHCP_OK=""
PING_OK=""
INTERFACES=($(ls /sys/class/net | grep -v lo))
REGEX="addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"

test_dhcp () {
  local INTERFACE=$1
  echo -e "Testant interface \033[36m$INTERFACE\033[0m"
  ifconfig $INTERFACE up
  sleep 4
  GET_IP="ifconfig $INTERFACE | grep -m1 'inet ' | cut -d' ' -f10"
  dhclient $INTERFACE > /dev/null 2>&1 & 
    sleep 4
    if [ ! "$(eval $GET_IP)" != "" ]; then 
      sleep 4
    fi
    if [ "$(eval $GET_IP)" != "" ]; then
      echo -e "\033[32mAdresse $(eval $GET_IP) obtenue via DHCP. \n\033[0mTest de connéctivité..."
      if [[ "$DHCP_OK" != *"$INTERFACE"* ]]; then
          DHCP_OK="$DHCP_OK $INTERFACE"
        fi

      EXTERNAL_IP=$(ip route | grep -m1 default | awk '{print $3}')
      ping -c 3 $EXTERNAL_IP > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo -e "\033[32mPing $EXTERNAL_IP : réussite.\033[0m"
        if [[ "$PING_OK" != *"$INTERFACE"* ]]; then
          PING_OK="$PING_OK $INTERFACE"
        fi
      else
        echo -e "\033[33mPing $EXTERNAL_IP : échec.\033[0m"
        PING_OK="$PING_OK $(printf '%*s\n' "${#INTERFACE}" '')"
      fi
      ifconfig $INTERFACE down
    else
      echo -e "\033[31mAucune adresse IP obtenue via DHCP.\033[0m"
    fi
    killall dhclient > /dev/null 2>&1 
    sleep 1
}

test_interfaces () {
  i=1
  IFACES="Interfaces :\033[36m "
  for INTERFACE in ${INTERFACES[@]}; do  
    IFACES+="[$i] $INTERFACE  "
    i=$(( $i + 1 ))
    ifconfig $INTERFACE down > /dev/null 2>&1 
  done
  while true; do
    echo "$(printf '%*s\n' "${#IFACES}" '' | tr ' ' '*')"
    echo -e "Brancher le cable Ethernet sur l'interface choisie.\n\n$IFACES\033[0m\n"
    read -p "Saisir le numéro de l'interface (Entrée pour terminer) : " RESPONSE
    if ! [ -n "$RESPONSE" ]; then 
      break
    elif [ -n "${INTERFACES[$(( $RESPONSE - 1 ))]}" ] && [[ $RESPONSE =~ ^[0-9]+$ ]]; then
      test_dhcp "${INTERFACES[$(( $RESPONSE - 1 ))]}"
    fi
  done
  for INTERFACE in ${INTERFACES[@]}; do  
    ifconfig $INTERFACE up > /dev/null 2>&1
  done
  TXT=$(printf '%*s\n' "${#DHCP_OK}" '' | tr ' ' '-')
  echo -e "\n-----------------------$TXT"
  echo "|          | DHCP | $DHCP_OK  |"
  echo "| Réussite |------|---$TXT|"
  echo "|          | Ping | $PING_OK  |"
  echo "-----------------------$TXT"
  echo -e "\nBrancher le cable Ethernet sur l'interface eth0."
  for ((i=0; i<20; i++)); do
    if read -n1 -t 1; then break ;fi
    sleep 1
  done 
  clear
}

clear
echo -e "\n***********************************************************************"
echo "                          *  TEST INTERFACES  *                        "
echo "***********************************************************************"
echo -e "\033[36mAttendre 10s ou taper quelque chose pour faire le test des interfaces\033[0m" 
txt="."
while [ "$(echo -n $txt | wc -c)" != 10 ]; do
  printf "\r %s" $txt
  txt+="."  
  sleep 1
  if read -n1 -t 1; then 
    test_interfaces
    break  
  fi
done
echo -e "\n\nExecuting custom-ocs..."
./custom-ocs
if [ $? -eq 0 ]; then
  reboot
fi