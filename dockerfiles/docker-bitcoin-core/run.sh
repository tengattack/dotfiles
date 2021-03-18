#!/bin/sh

docker rm bitcoin-core1
docker run --name=bitcoin-core1 --restart=always -p 8332:8332 -v /volume1/Private/Backup/cryptocoins/Bitcoin:/home/bitcoin/.bitcoin -d docker-bitcoin-core:0.20 -rpcuser=bitcoin -rpcpassword=1PS2kV5KyJkj1Eeb -proxy=192.168.6.6:1083
