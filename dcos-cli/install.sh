#!/bin/bash

set -o errexit -o pipefail

BUILD_DIR='/tmp/dcos-cli/build'

echo "Setting up build directory..."
echo ""

mkdir -p $BUILD_DIR
rm -rf $BUILD_DIR/*
cd $BUILD_DIR

echo "Retrieving latest source code..."
echo ""

git clone git@github.com:mesosphere/dcos-cli
pushd dcos-cli

echo "Setting up virtualenv..."
echo ""

make env
source env/bin/activate
pip install --upgrade pip

echo "Building packages..."
echo ""

make packages
deactivate

echo "Installing DCOS CLI from wheel..."
echo ""

pip install dist/*.whl

popd

echo "Done!"
