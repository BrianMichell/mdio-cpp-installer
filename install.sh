#!/bin/bash

script=$0
INSTALL_DIR=$1
TAG_VERSION=$2

if [ -z "$INSTALL_DIR" ]; then
    echo "Please select a directory for MDIO to be installed to."
    exit 1
fi

if [ -z "$TAG_VERSION" ]; then
    echo "A version tag was not supplied. Attempting to install the latest version."
    TAG_VERSION="main"
fi

# Clone the repository and checkout the specific tag
git clone https://github.com/TGSAI/mdio-cpp.git
cd mdio-cpp
git checkout $TAG_VERSION


# Check if the git checkout was successful
if [ $? -ne 0 ]; then
    echo "Failed to checkout tag $TAG_VERSION."
    exit 1
fi

# Append "IntelLLVM" to the end of line 10 in the specified file
# Check if the file exists and has at least 10 lines
if [ -f "cmake/FindEXT_TENSORSTORE.cmake" ] && [ $(wc -l < cmake/FindEXT_TENSORSTORE.cmake) -ge 10 ]; then
    # Append "IntelLLVM" to the end of line 10 in the specified file
    sed -i '10s/$/_IntelLLVM/' cmake/FindEXT_TENSORSTORE.cmake
     # Check if the sed command was successful
    if [ $? -ne 0 ]; then
        echo "Failed to append IntelLLVM to line 10 of cmake/FindEXT_TENSORSTORE.cmake."
        exit 1
    fi
else
    echo "File cmake/FindEXT_TENSORSTORE.cmake does not exist or does not have at least 10 lines."
    exit 1
fi

BUILD_ROOT=$(dirname $(dirname $script))
if [ "$BUILD_ROOT" = "." ]; then
    BUILD_ROOT=${PWD}
fi

# Copy items required to pre-compile MDIO and deps into the main cmake
cat ../CMakeLists.txt >> mdio/CMakeLists.txt

echo "Building MDIO"
./../build_mdio.sh $INSTALL_DIR $BUILD_ROOT

echo "Installing MDIO"
./../install_components.sh $INSTALL_DIR