#!/bin/bash

script=$0
INSTALL_DIR=$1
TAG_VERSION=$2

if [[ -z "$INSTALL_DIR"]]; then
    echo "Please select a directory for MDIO to be installed to."
    exit 1
fi

if [[ -z "$TAG_VERSION"]]; then
    echo "A version tag was not supplied. Attempting to install the latest version."
    TAG_VERSION="main"
fi

# Clone the repository and checkout the specific tag
git clone https://github.com/TGSAI/mdio-cpp.git
cd mdio-cpp
git checkout $TAG_VERSION

BUILD_ROOT=$(dirname $(dirname $script))
if [ "$BUILD_ROOT" = "." ]; then
    BUILD_ROOT=${PWD}
fi

# Copy items required to pre-compile MDIO and deps into the main cmake
cat ../CMakeLists.txt >> mdio/CMakeLists.txt

./../build_mdio.sh $INSTALL_DIR

./../install_components.sh $INSTALL_DIR