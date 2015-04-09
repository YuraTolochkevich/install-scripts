#!/bin/bash

set -o errexit -o pipefail

usage()
{ # Show usage information.
  echo "install.sh <shared_secret> <installation_path> <marathon_host> [<marathon_port>]"
}

if [ "$#" -lt 3 ]; then
  usage;
  exit 1;
fi

ARGS=( "$@" );

SECRET=${ARGS[0]}
VIRTUAL_ENV_PATH=$(python -c "import os; print(os.path.realpath('"${ARGS[1]}"'))")
MARATHON_HOST=${ARGS[2]}
MARATHON_PORT=${ARGS[3]:-8080}
UNIVERSE_URI="https://github.com/mesosphere/universe/archive/ea.zip"

command -v virtualenv >/dev/null 2>&1 || { echo >&2"Cannot find virtualenv. Aborting."; exit 1; }

VIRTUALENV_VERSION=$(virtualenv --version)
VERSION_REGEX="s#[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)#\1#"

eval MAJOR=`echo $VIRTUALENV_VERSION | sed -e $VERSION_REGEX`
if [ $MAJOR -lt 12 ];
	then echo "Virtualenv version must be 12 or greater. Aborting.";
	exit 1;
fi

echo "Installing DCOS CLI from wheel...";
echo "";

# Let's first setup a virtualenv: we are assuming that the path is absolute
mkdir -p $VIRTUAL_ENV_PATH
virtualenv $VIRTUAL_ENV_PATH

# Install the dcos-cli
DCOS_WHEEL_FILE="dcos-0.1.0-py2.py3-none-any.whl"
DCOSCLI_WHEEL_FILE="dcoscli-0.1.0-py2.py3-none-any.whl"

# Install the DCOS package
curl --silent --fail -O "https://downloads.mesosphere.io/dcos-cli/${SECRET}/${DCOS_WHEEL_FILE}"
"$VIRTUAL_ENV_PATH/bin/pip" install --quiet ${DCOS_WHEEL_FILE}
rm ${DCOS_WHEEL_FILE}

# Install the DCOS CLI package
curl --silent --fail -O "https://downloads.mesosphere.io/dcos-cli/${SECRET}/${DCOSCLI_WHEEL_FILE}"
"$VIRTUAL_ENV_PATH/bin/pip" install --quiet ${DCOSCLI_WHEEL_FILE}
rm ${DCOSCLI_WHEEL_FILE}

ENV_SETUP="$VIRTUAL_ENV_PATH/bin/env-setup"
source $ENV_SETUP
dcos config set marathon.host $MARATHON_HOST
dcos config set marathon.port $MARATHON_PORT
if ! `dcos config show package.sources 2>&1 | grep -q "$UNIVERSE_URI"`; then
    dcos config append package.sources $UNIVERSE_URI
fi
dcos config set package.cache /tmp/dcos/package-cache

echo "Finished installing and configuring DCOS CLI."
echo "Please add $VIRTUAL_ENV_PATH/bin to your PATH."
echo "On Linux systems, run the line below to automatically set up your PATH: "
echo "echo \"source $ENV_SETUP\" >> ~/.profile"
echo "Once your PATH is set up, type dcos help to get started."
