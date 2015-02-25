#!/bin/bash

set -o errexit -o pipefail

usage()
{ # Show usage information.
  echo "install.sh <shared_secret> <installation_path> <marathon_host> <marathon_port>"
}

if [ "$#" -ne 4 ]; then
  usage;
  exit 1;
fi

ARGS=( "$@" );

SECRET=${ARGS[0]}
VIRTUAL_ENV_PATH=$(python -c "import os; print(os.path.realpath('$(dirname "${ARGS[1]}")'))")
MARATHON_HOST=${ARGS[2]}
MARATHON_PORT=${ARGS[3]}

echo "Installing DCOS CLI from wheel...";
echo "";

# Let's first setup a virtualenv: we are assuming that the path is absolute
mkdir -p $VIRTUAL_ENV_PATH
virtualenv $VIRTUAL_ENV_PATH
source "$VIRTUAL_ENV_PATH/bin/activate"

# Install the dcos-cli
WHEEL_FILE="dcos-0.1.0-py2.py3-none-any.whl"
pip install <(curl --silent --fail "https://downloads.mesosphere.io/dcos-cli/${SECRET}/${WHEEL_FILE}")

# Deactivate the virtualenv
deactivate

ENV_SETUP="$VIRTUAL_ENV_PATH/bin/env-setup"
source $ENV_SETUP
dcos config marathon.host $MARATHON_HOST
dcos config marathon.port $MARATHON_PORT

echo "Done installing and configuring DCOS CLI"
echo "Please add $VIRTUAL_ENV_PATH/bin to your PATH"
echo "For Linux add: '. $ENV_SETUP' to your .profile"
