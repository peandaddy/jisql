#!/bin/sh
set -e

if [ ! -e ./servercert ]
then
  mkdir servercert
fi

cd servercert


# target server hostname; multi SAN names; sign by RootCA or intermediate CA(default)
arg=$1
arg2=$2
arg3=$3

SUBJ='/C=US/ST=CA/L=LA/O=test/OU=eng'

# these will be the hosts in the certificate
hosts=${CERTHOSTS:-"$arg2"}

cat > /tmp/san.cnf <<EOF
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = v3_req
[ req_distinguished_name ]
countryName           = US
stateOrProvinceName   = FL
localityName          = Miami
organizationName      = test
commonName            = $arg
[ v3_req ]
subjectAltName = @alt_names
[ alt_names ]
EOF

count=0
for f in $hosts
do
    count=`expr $count + 1`
    test $count = 1 && firsthost=$f
    echo "DNS.$count = $f" >> /tmp/san.cnf
done


# rootca: signed by rootca; otherwise the intermediate CA
if [ "X$arg3" = "Xrootca" ]
then
  echo "Use ROOT CA to sign!" >&2
  capath=`cat ../capath.txt`
  capw=`cat $capath/private/capw.dat`
  cacertname='cacert.pem'
  cacertkey='cakey.pem'
elif [ "X$arg3" = "Xintermediate" ]
then
  echo "Use Intermediate CA to sign!" >&2
  capath=`cat ../intercapath.txt`
  capw=`cat $capath/private/icapw1.dat`
  cacertname='intermediate1.pem'
  cacertkey='intermediate1.key'
elif [ -n "$arg3" ]
then
  echo "Arg3 string is empty!!" >&2
  # return 1
  exit 1
  
fi

# generate the CSR
openssl req -new -days 365 -config /tmp/san.cnf \
        -nodes -out $arg.csr \
        -keyout $arg.key -subj "$SUBJ/CN=$arg" 

# protect the key
chmod og-rwx $arg.key

# sign the CSR, generating the certificate
openssl ca -in $arg.csr  \
  -config $capath/openssl.cnf \
  -cert $capath/$cacertname -keyfile $capath/private/$cacertkey  \
  -passin pass:$capw -out $arg.crt -batch

# remove the CSR
rm $arg.csr

echo -e ""
echo -e "\033[0m================================================="
echo -e "Server Cert Created: \033[0;35m$arg.crt"
echo -e "\033[0mPlease copy root CA cert cacert.pem or ca-chain.cert.pem if signed by intermediate CA"
echo -e "and \e[34m$arg.crt \033[0m& \e[34m$arg.key" 
echo -e "\033[0m================================================="

