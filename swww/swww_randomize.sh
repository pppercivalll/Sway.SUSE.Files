DEFAULT_INTERVAL=300 # In seconds

# Check args
if [ $# -lt 1 ] || [ ! -d "$1" ]; then
    printf "Usage:\n\t%s DIRECTORY [INTERVAL]\n" "$0"
    printf "\tChanges the wallpaper to a randomly chosen image in DIRECTORY every\n\tINTERVAL seconds (or every %d seconds if unspecified).\n" "$DEFAULT_INTERVAL"
    exit 1
fi

# Start swww-daemon if not running
if ! pgrep -x swww-daemon > /dev/null; then
    swww-daemon &
    sleep 1  # Give it a moment to initialize
fi

# Set transition variables
RESIZE_TYPE="crop"
export SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
export SWWW_TRANSITION_STEP="${SWWW_TRANSITION_STEP:-2}"

# Main loop
while true; do
    find "$1" -type f \
    | while read -r img; do
        echo "$(tr -dc a-zA-Z0-9 </dev/urandom | head -c 8):$img"
    done \
    | sort -n | cut -d':' -f2- \
    | while read -r img; do
        swww img --resize="$RESIZE_TYPE" "$img"
        sleep "${2:-$DEFAULT_INTERVAL}"
    done
done
