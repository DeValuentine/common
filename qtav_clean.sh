#/!/bin/bash

USERNAME="valentine" # change this value if needed 

HOMEDIR="/home/$USERNAME"
HOMEDIR="/home/$USERNAME"
FF_DIR_SOURCE="$HOMEDIR/FFMPEG/src"
FF_DIR_BUILD="$HOMEDIR/FFMPEG/build"
FF_DIR_BIN="$HOMEDIR/FFMPEG/bin"
FF_LOG_FILE="$HOMEDIR/logs/ffmpeg_deploy.log"
FF_DIRS="$FF_DIR_SOURCE $FF_DIR_BUILD $FF_DIR_BIN"

rm -rf "$HOMEDIR/FFMPEG"
rm -rf "$HOMEDIR/qtav"
