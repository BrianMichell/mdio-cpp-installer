#!/bin/bash

SRC_DIR="build/_deps"
INSTALL_DIR=$1


mkdir -p $INSTALL_DIR/lib/drivers
for file in $(cat ../drivers_list.txt); do
   driver=$(find $SRC_DIR -name $file -print)
   echo installing $driver...
   cp $driver $INSTALL_DIR/lib/drivers
done

echo 'Installing .h include files...'
StartSearchDir="${SRC_DIR}"
BaseDestDir="${INSTALL_DIR}/include"
cd $StartSearchDir
for H in `find -regex ".*\.\(hpp\|h\|inc\)$"`; do 
  PathFileDir=$(dirname $H)
  mkdir -p "${BaseDestDir}/${PathFileDir}"     # no error, make parents too
  cp -p "$H" "${BaseDestDir}/${PathFileDir}/"  # preserve ownership...
done

exit 0
