#!/bin/bash

cd /opt
wget http://go.googlecode.com/files/go1.2.1.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.2.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
export GOROOT=$HOME/go
export PATH=$PATH:$GOROOT/bin