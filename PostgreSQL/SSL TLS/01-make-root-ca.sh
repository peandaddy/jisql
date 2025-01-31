#!/bin/sh
set -e

SUBJ="/C=US/ST=CA/L=LA/O=test/OU=eng"
# switch to the CA dir
cd cadir

capw=`openssl rand -hex 30`
echo $capw > private/capw.dat

# generate the Root CA cert and key , 10 years
openssl req -passout pass:$capw -new -x509 -days 3650 \
 -config openssl.cnf -extensions v3_ca \
 -subj "$SUBJ/CN=My-Root-CA" \
 -keyout private/cakey.pem -out cacert.pem
cd ..