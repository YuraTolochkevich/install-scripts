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

pip install https://downloads.mesosphere.io/dcos-cli/${SECRET}.whl

echo "Done!";
