#! /bin/bash

set -e

case "$1" in
    leeloo|rev2)
        KEYBOARD="leeloo_rev2"
        ;;
    leeloo-micro|micro)
        KEYBOARD="leeloo_micro"
        ;;
    *)
        echo "ERROR: Keyboard must be specified or is unknown"
        exit 1
esac

if [ "$2" ]; then
    SIDES="$2"
else
    SIDES="left right"
fi

# Lets me use a private repo.
if [ "$SSH_AUTH_SOCK" != "" ]; then
    SSH_AUTH_VOLUME="-v $(readlink -f $SSH_AUTH_SOCK):/.ssh-agent -e SSH_AUTH_SOCK=/.ssh-agent"
else
    SSH_AUTH_VOLUME=
fi

TAG="private/zmk-flash:${KEYBOARD}"

podman build --tag ${TAG} .

mkdir -p .app/${KEYBOARD} output/${KEYBOARD}

for side in ${SIDES}; do
    podman run --rm -it ${SSH_AUTH_VOLUME} \
           -e SHIELD="${KEYBOARD}" \
           -v $(pwd)/.app/${KEYBOARD}:/app:z \
           -v $(pwd)/config:/app/config:z,ro \
           -v $(pwd)/output/${KEYBOARD}:/app/output:z \
           -v $(pwd):/src:z,ro \
           ${TAG} /src/_build.sh ${side}
done

LEFT=
RIGHT=

. ${KEYBOARD}.env

left_done=no
right_done=no

while true; do
    if test -e "${RIGHT}"; then
	echo "Found right"
	if test -e /run/media/${USER}/NICENANO; then
	    udisksctl unmount -b "${RIGHT}"
	fi
	udisksctl mount -b "${RIGHT}"
	cp output/${KEYBOARD}/right.uf2 /run/media/${USER}/NICENANO
	right_done=yes
    elif test -e "${LEFT}"; then
	echo "Found left, mounting"
	if test -e /run/media/${USER}/NICENANO; then
	    udisksctl unmount -b "${LEFT}"
	fi
	udisksctl mount -b "${LEFT}"
	echo "Copying firmware"
	cp output/${KEYBOARD}/left.uf2 /run/media/${USER}/NICENANO
	left_done=yes
	sleep 3
    elif [ "${left_done}" = "yes" -a "${right_done}" = "yes" ]; then
	break
    else
	echo "Waiting for device, hit CTRL-C if done."
	sleep 1
    fi
done
