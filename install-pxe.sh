#!/bin/bash

CONTAINER_NAME="pxe-server"
CONTAINER_VOLUME="/var/lib/$CONTAINER_NAME"
PXE_DIR="/etc/$CONTAINER_NAME"

if [ ! -n "$(docker --version | awk "/Docker version/ && /build/")" ];
then echo "Docker not installed"; exit
fi

IDi=$(docker images | grep $CONTAINER_NAME |  awk '{print $3}')
docker rmi $IDi -f 2>/dev/null

if [ "$1" == "-r" ]; then 
    systemctl stop $CONTAINER_NAME 2>/dev/null
    rm -r $CONTAINER_VOLUME $PXE_DIR \
       /etc/systemd/system/$CONTAINER_NAME.service 2>/dev/null
    systemctl daemon-reload
    echo "$CONTAINER_NAME removed!"
elif [ "$1" == "-i" ]; then
    mkdir $PXE_DIR
    mkdir $CONTAINER_VOLUME
    cp -r pxe_conf/* $PXE_DIR
    cp -r tftpboot $CONTAINER_VOLUME

    echo "Building Docker image..."
    cd $PXE_DIR
    docker build -t $CONTAINER_NAME . >/dev/null

    echo "Creating the PXE service..."
    ln -rs pxe-server.service -t /etc/systemd/system
    systemctl daemon-reload
    systemctl start $CONTAINER_NAME
    systemctl enable pxe-server
    echo "$CONTAINER_NAME installed!" 
    echo "Run 'systemctl status $CONTAINER_NAME' for details"
else
    echo -e "Usage:\n  $0 -i : to install pxe\n  $0 -r : to remove pxe"
fi