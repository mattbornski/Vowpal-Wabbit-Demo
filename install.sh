#!/bin/bash

# Helper functions
lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}
ensure_brew(){
   brew --help > /dev/null || ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
}

# Variables for making decisions
UNAME=`lowercase \`uname\``
vw --version > /dev/null 2>&1
VW_NOT_INSTALLED=$?

if [ "$VW_NOT_INSTALLED" != "0" ] ; then
  if [ "$UNAME" == "darwin" ] ; then
    ensure_brew
    brew install automake boost libtool
  fi
  
  git clone https://github.com/JohnLangford/vowpal_wabbit.git
  
  pushd vowpal_wabbit
  
  if [ "$UNAME" == "darwin" ] ; then
    sed -e 's/^libtoolize/glibtoolize/' -i '' autogen.sh
  fi
  
  # The first call to autogen appears to fail but has side effects which causes the second call to succeed.
  ./autogen.sh
  ./autogen.sh
  
  make
  
  make test
  
  make install
  
  popd
fi