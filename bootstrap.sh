#!/bin/bash

# Echo for your debugging pleasure
set -e

cd /home/hadoop
git clone https://github.com/JohnLangford/vowpal_wabbit.git
pushd vowpal_wabbit
git checkout v7.1

sudo apt-get install libboost-program-options-dev libtool

./autogen.sh

make

make test

make install || sudo make install

popd
