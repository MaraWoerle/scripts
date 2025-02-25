#!/bin/bash

if [ ! -d server ]; then
  mkdir server
  echo "- Created Server Dir"
fi

if [ ! -f server/server.crt ] && [ ! -f server/server.key ]; then
  echo "- Generating Server Certificate:"
  openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -keyout server/server.key -nodes -sha256 -days 3650 -subj '/CN=server' | tee server/server.crt
fi

if [ ! -f server/server.conf ]; then
  echo "- Enter Server Address:"
  read server
  echo "# server $server" > server/server.conf
  echo "- Server Fingerprint:"
  openssl x509 -fingerprint -sha256 -in server/server.crt -noout | cut -f2 -d "=" | sed "s/^/# fingerprint /" | tee -a server/server.conf
  echo "- Adding Server Config:"
  cat server-config.conf | tee -a server/server.conf
fi

echo "- Finished Server Config"
