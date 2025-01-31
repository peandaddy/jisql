#!/bin/sh
set -e

capath=`cat ./capath.txt`

if [ ! -e $capath/private/capw.dat ]
then
	echo Need the root CA and root CA created first
	exit 1
fi

SUBJ="/C=US/ST=CA/L=LA/O=test/OU=eng"
mkdir intermediate
cd intermediate
DIR=`pwd`
cp /etc/pki/tls/openssl.cnf .

echo $DIR > ../intercapath.txt

# Add v3_intermediate_ca extention syntax
sed -i '$a\[ v3_intermediate_ca ]\
subjectKeyIdentifier = hash\
authorityKeyIdentifier = keyid:always,issuer \
basicConstraints = critical, CA:true, pathlen:0' openssl.cnf

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

# Bind name value for further parameter use
caserial=`cat serial`

# we will sign with the root CA private key
# Get Root CA private password created previously
capw=`cat $capath/private/capw.dat`


# make and record a new password for this CA
icapw=`openssl rand -hex 30`
echo $icapw > private/icapw1.dat

# generate the CSR
openssl req -new -passout pass:$icapw -text \
        -out intermediate.csr \
		-keyout private/intermediate1.key \
		-subj "$SUBJ/CN=Intermediate CA $caserial" 

# protect the key
chmod og-rwx private/intermediate1.key

# sign the CRS, generating the certificate for the new CA
# To create an intermediate certificate, use the root CA 
# with the v3_intermediate_ca extension instead of v3_ca 
# to sign the intermediate CSR. Even though I think v3_ca will work too
openssl x509 -req -in intermediate.csr -days 3650 \
  -extfile openssl.cnf -extensions v3_intermediate_ca \
  -CA $capath/cacert.pem -CAkey $capath/private/cakey.pem  -passin pass:$capw \
  -CAcreateserial -out intermediate1.pem
# move the CSR
mv intermediate.csr ./csr

# CREATE the certificate chain file
cat ./intermediate1.pem $capath/cacert.pem > \
    ./certs/ca-chain.cert.pem

cd ..