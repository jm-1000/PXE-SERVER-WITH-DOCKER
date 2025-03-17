#!/bin/bash

CONTAINER_NAME="pxe-server"
CONTAINER_VOLUME="/var/lib/$CONTAINER_NAME/tftpboot:/tftpboot"
PXE_INTERFACE="pxe_br"
get_ip="ip add sh $PXE_INTERFACE | grep -m 1 'inet ' | cut -d' ' -f6 | cut -d/ -f1"
get_id="docker container ls -a | grep $CONTAINER_NAME |  awk '{print $1}'"

track_ip() {
    CURRENT_IP=$(eval $get_ip)
    while true; do
        if [ "$CURRENT_IP" != "$(eval $get_ip)" ]; then
            service $1 restart
            exit 0
        fi
        sleep 5
    done
}

if [ "$1" == "--stop" ] || [ "$1" == "-S" ]; then
    docker stop $CONTAINER_NAME 2>/dev/null
elif [ "$1" == "--delete" ] || [ "$1" == "-D" ]; then
    echo "Removing the previous installation"
    docker rm $(eval $get_id) -f 2>/dev/null
elif [ "$1" == "--trackIp" ]; then
    track_ip $CONTAINER_NAME &
else
    docker rm $(eval $get_id) -f 2>/dev/null
    echo "Running the container"
    docker run \
        -d --name $CONTAINER_NAME \
        -v $CONTAINER_VOLUME \
        --network=host \
        --memory=512m \
        --cpus=1 \
        --cap-add=NET_ADMIN \
        -e PXE_IP=$(eval $get_ip) \
        $CONTAINER_NAME | awk '{print "Container ID: " $1}'
    echo "Getting logs..."
    sleep 5
    docker logs $CONTAINER_NAME
    while true; do
        if [ ! -n "$(docker ps | grep $CONTAINER_NAME)" ]; then
            exit 0
        fi
        sleep 5
    done
fi
