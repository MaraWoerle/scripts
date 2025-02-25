#!/bin/bash

if [ ! -d server ]; then
  sh generate-server-config.sh
fi

serverconf=$(<server/server.conf)
echo "- Enter Client Name:"
read client

if [ ! -d client ]; then
  mkdir client
  echo "- Created client directory"
fi

if [ ! -f client/$client.crt ] && [ ! -f client/$client.key ]; then
  echo "- Generating ${client}.crt:"
  openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -keyout client/$client.key -nodes -sha256 -days 3650 -subj '/CN=$client' | tee client/$client.crt
fi

if [ ! -f client/$client.conf ]; then
  echo "- Adding ${client}.conf:"
  address=$(echo "$serverconf" | grep "# server" | cut -f3 -d " ")
  fingerprint=$(echo "$serverconf" | grep "# fingerprint" | cut -f3 -d " ")
  cat client-config.conf | sed "/<key>/q;s/{remote}/$address/" | tee client/$client.conf
  cat client/$client.key | tee -a client/$client.conf
  echo -e "</key>\n<cert>" | tee -a client/$client.conf
  cat client/$client.crt | tee -a client/$client.conf
  cat client-config.conf | sed -e "1,/<cert>/d;s/{server-fingerprint}/$fingerprint/" | tee -a client/$client.conf
fi

fingerprint=$(openssl x509 -fingerprint -sha256 -noout -in client/$client.conf | cut -f2 -d "=")
if ! grep -q $fingerprint server/server.conf; then
  echo "- Adding Fingerprint to server.conf:"
  serverconf="$(<server/server.conf)"
  echo "$serverconf" | sed "/<peer-fingerprint>/q" | tee server/server.conf
  echo $fingerprint | tee -a server/server.conf
  echo "$serverconf" | sed -r "1,/<peer-fingerprint>/d" | tee -a server/server.conf
fi

echo "- Finished ${client}.conf"
