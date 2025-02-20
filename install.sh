#!/bin/bash

# This script is used to install the MDIO library and its dependencies.
# This script is not an official TGS product.
# This script is provided as-is without warranty of any kind.

# Usage:
# ./install.sh <install_dir> [<tag_version>] [<cmake_flags>...]
# Example:
# ./install.sh /usr/local/mdio-cpp/1.2.1 v0.1.2-pre-release -DCMAKE_CXX_FLAGS_ARCH_SPECIFIC:STRING="-std=c++17 -march=x86-64 -fPIC" -DCMAKE_C_FLAGS_ARCH_SPECIFIC:STRING="-march=x86-64 -fPIC" -DCMAKE_BUILD_TYPE=ARCH_SPECIFIC -DCMAKE_INSTALL_PREFIX=/usr/local/mdio-cpp/1.2.1

script=$0
INSTALL_DIR=$1
TAG_VERSION=$2

if [ -z "$INSTALL_DIR" ]; then
    echo "Please select a directory for MDIO to be installed to."
    exit 1
fi

# Check if the TAG_VERSION arg begins with a hyphen.
# If it does, it's assumed to be a CMake flag and the main branch will be used.
# If it doesn't, it's assumed to be a tag/branch and will be checked out.

# Check if TAG_VERSION is a valid tag or part of CMake flags
if [[ "$TAG_VERSION" =~ ^- ]]; then
    echo "Did not find a git tag in arguments. Using main branch."
    TAG_VERSION="main"
    CMAKE_FLAGS=("${@:2}")
else
    shift 2
    CMAKE_FLAGS=("$@")
fi

# Check for --curl flag
CURL_FLAG=false
for arg in "${CMAKE_FLAGS[@]}"; do
    if [ "$arg" = "--curl" ]; then
        CURL_FLAG=true
        # Remove --curl from CMAKE_FLAGS
        CMAKE_FLAGS=("${CMAKE_FLAGS[@]/$arg}")
    fi
done

if [ -z "$TAG_VERSION" ]; then
    echo "A version tag was not supplied. Attempting to install the latest version."
    TAG_VERSION="main"
fi

REPO_URL="https://github.com/TGSAI/mdio-cpp.git"
REPO_DIR="mdio-cpp"

# Clone the repository if it doesn't exist, otherwise pull the latest changes
if [ -d "$REPO_DIR" ]; then
    if [ -d "$REPO_DIR/.git" ]; then
        echo "Repository already exists. Fetching latest changes."
        cd $REPO_DIR
        git checkout main
        git reset --hard
        git fetch
        git checkout $TAG_VERSION
        git pull
    else
        echo "Directory exists but is not a valid git repository. Removing and cloning again."
        rm -rf $REPO_DIR
        git clone $REPO_URL
        cd $REPO_DIR
        git checkout $TAG_VERSION
    fi
else
    git clone $REPO_URL
    cd $REPO_DIR
    git checkout $TAG_VERSION
fi

BUILD_ROOT=$(dirname $(dirname $script))
if [ "$BUILD_ROOT" = "." ]; then
    BUILD_ROOT=${PWD}
fi

# Copy items required to pre-compile MDIO and deps into the main cmake
cat ../CMakeLists.txt >> mdio/CMakeLists.txt

# Add curl library configuration if --curl flag is present
if [ "$CURL_FLAG" = true ]; then
    echo "

add_library( curl SHARED dummy.cc)
TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE ( curl
CURL::libcurl
)
install(TARGETS curl DESTINATION lib)" >> mdio/CMakeLists.txt
fi

echo "Building MDIO"
./../build_mdio.sh $INSTALL_DIR $BUILD_ROOT $CMAKE_FLAGS

echo "Installing MDIO"
./../install_components.sh $INSTALL_DIR
