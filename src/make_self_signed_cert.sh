#!/bin/bash
#set -x
encoding="DER"
while getopts "pdh" opts; do
    case $opts in
        p)
            encoding="PEM"
            ;;
        d)
            encoding="DER"
            ;;
        h)
            echo "$0 -d set ecnoding to DER -p sets encodig to PEM"
            ;;
    esac
done

echo "Encoding $encoding"

if [ $encoding == "DER" ]; then

openssl genpkey -out server_privkey.der -outform DER -algorithm RSA -pkeyopt rsa_keygen_bits:2048
openssl req -new -key server_privkey.der -inform DER -out ca.der -subj /CN=localhost  -outform DER
openssl x509 -req -days 3650 -in ca.der  -signkey server_privkey.der -inform DER -out server.der -outform DE
fi

if [ $encoding == "PEM" ]; then
#openssl genrsa -out server_privkey.pem 2048
openssl genpkey -out server_privkey.pem -outform PEM -algorithm RSA -pkeyopt rsa_keygen_bits:2048
openssl req -new -key server_privkey.pem -inform PEM -out ca.der -subj /CN=localhost  -outform DER
openssl x509 -req -days 3650 -in ca.der  -signkey server_privkey.pem -inform DER -out server.der -outform DER
fi
echo "remember to change CMakelists.txt"
