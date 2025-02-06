#!/bin/bash
CONTAINER_NAME="pxe-server"
CONTAINER_NET_NAME="pxe-network"
IP_PXE_SRV="192.168.112.39"
NET="192.168.112.0/24"
GW="192.168.112.1"
MACVLAN_IFACE="enx7cc2c63be448"

echo "Removing the previous installation"
ID=$(docker container ls -a | grep $CONTAINER_NAME |  awk '{print $1}')
docker rm $ID -f 2>/dev/null
IDi=$(docker images | grep $CONTAINER_NAME |  awk '{print $3}')
docker rmi $IDi -f 2>/dev/null

docker network rm $CONTAINER_NET_NAME 2>/dev/null

echo "Building the image"
docker build -t $CONTAINER_NAME .

docker network create \
    -d macvlan \
    -o parent=$MACVLAN_IFACE \
    --subnet=$NET \
    --gateway=$GW \
    $CONTAINER_NET_NAME | awk '{print "NET ID: " $1}'

echo "Running the container"
docker run \
    -d --name $CONTAINER_NAME \
    --memory=512m \
    --cpus=1 \
    --network=$CONTAINER_NET_NAME \
    --ip=$IP_PXE_SRV \
    -p 67:67/udp \
    -p 69:69/udp \
    --cap-add=NET_ADMIN \
    -e IP_PXE_SRV=$IP_PXE_SRV \
    $CONTAINER_NAME | awk '{print "Container ID: " $1}'

echo "Getting logs..."
sleep 5
docker logs $CONTAINER_NAME