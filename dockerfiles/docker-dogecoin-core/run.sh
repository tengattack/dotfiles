#!/bin/sh

docker rm dogecoin-core1
docker run --name=dogecoin-core1 --restart=always -p 22555:22555 -v /volume1/Private/Backup/cryptocoins/DogeCoin:/home/dogecoin/.dogecoin -d docker-dogecoin-core:1.14.3 -rpcuser=dogecoin -rpcpassword=1PS2kV5KyJkj1Eeb -proxy=192.168.6.6:1083
