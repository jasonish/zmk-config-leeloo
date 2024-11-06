#! /bin/sh

set -e
set -x

if [ -z "${SHIELD}" ]; then
    echo "ERROR: SHIELD must be set."
    exit 1
fi

rm -rf .west && west init -l /app/config
west update
west zephyr-export

case "$1" in
    left)
	SHIELD="${SHIELD}_left nice_view_adapter nice_view"
	DEST="left"
	;;
    right)
	SHIELD="${SHIELD}_right nice_view_adapter nice_view"
	DEST="right"
	;;
    reset)
	SHIELD="settings_reset"
	DEST="reset"
	;;
    *)
	echo "error: no or bad shield specified"
	exit 1
	;;
esac

west build -s zmk/app -d build/${DEST} -b nice_nano_v2 -- \
     -DZMK_CONFIG=/app/config -DSHIELD="${SHIELD}"
mv ./build/${DEST}/zephyr/zmk.uf2 ./output/${DEST}.uf2
