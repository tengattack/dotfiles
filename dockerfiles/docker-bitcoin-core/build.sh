#!/bin/sh

docker build --build-arg TARGETPLATFORM=linux/amd64 -t docker-bitcoin-core:0.20 .
