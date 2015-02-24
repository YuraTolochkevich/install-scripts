#!/bin/bash

set -o errexit -o pipefail

usage()
{ # Show usage information.
  echo "install.sh <shared_secret>";
}

if [ "$#" -eq 2 ]; then
  usage;
  exit 1;
fi

args=( "$@" );

SECRET=${args[0]};

echo "Installing DCOS CLI from wheel...";
echo "";

BUILD_DIR="/tmp/dcos-cli/build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
tree $BUILD_DIR
pushd $BUILD_DIR

WHEEL_FILE="dcos-0.1.0-py2.py3-none-any.whl"
curl --fail -O https://downloads.mesosphere.io/dcos-cli/${SECRET}/${WHEEL_FILE}
pip install ${WHEEL_FILE}
rm ${WHEEL_FILE}

popd

echo "Done!";
