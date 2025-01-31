#!/bin/bash
set -e

rm -rf cadir
mkdir cadir
cd cadir
DIR=`pwd`
cp /etc/pki/tls/openssl.cnf .
echo $DIR > ../capath.txt
# make subdirectories
mkdir certs private newcerts crl csr
# a csr directory to hold certificate signing requests
# crlnumber is used to keep track of certificate revocation lists
chmod 700 .; echo 1000 > serial; touch index.txt; echo 01 > crlnumber
# Replace dir value
# Set to 'no' to allow creation of several certs with same subject.
sed -i -e "s,^dir.*,dir = $DIR," -e 's/#unique_subject/unique_subject/' openssl.cnf
# 1. this is required for SANs
# 2. In order to keep this extension when the intermediate CA signs this CSR,
# copy_extensions = copy must be present in section in following openssl.cnf file
sed -i -e 's/# copy_extensions/copy_extensions/' openssl.cnf
cd ..
