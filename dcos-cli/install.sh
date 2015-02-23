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

echo "Fetching latest DCOS CLI wheel...";
echo "";

curl -O https://downloads.mesosphere.io/dcos-cli/${SECRET}.whl /tmp/${SECRET}.whl

echo "Installing DCOS CLI from wheel...";
echo "";

pip install /tmp/${SECRET}.whl

echo "Done!";
