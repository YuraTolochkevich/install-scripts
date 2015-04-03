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
VIRTUAL_ENV_PATH=$(python -c "import os; print(os.path.realpath('"${ARGS[1]}"'))")
MARATHON_HOST=${ARGS[2]}
MARATHON_PORT=${ARGS[3]}

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
dcos config append package.sources https://github.com/mesosphere/universe.git
dcos config set package.cache /tmp/cache

echo "Done installing and configuring DCOS CLI"
echo "Please add $VIRTUAL_ENV_PATH/bin to your PATH"
echo "For Linux add: '. $ENV_SETUP' to your .profile"
