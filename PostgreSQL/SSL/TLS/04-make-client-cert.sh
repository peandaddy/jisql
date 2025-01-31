#!/bin/sh
set -e

if [ ! -e ./clientcert ]
then
  mkdir clientcert
fi

cd clientcert


# target server hostname; multi SAN names; sign by RootCA or intermediate CA(default)
arg=$1
arg2=$2

SUBJ='/C=US/ST=CA/L=LA/O=test/OU=eng'


# rootca: signed by rootca; otherwise the intermediate CA
if [ "X$arg2" = "Xrootca" ]
then
  echo "Use ROOT CA to sign!" >&2
  capath=`cat ../capath.txt`
  capw=`cat $capath/private/capw.dat`
  cacertname='cacert.pem'
  cacertkey='cakey.pem'
elif [ "X$arg2" = "Xintermediate" ]
then
  capath=`cat ../intercapath.txt`
  capw=`cat $capath/private/icapw1.dat`
  cacertname='intermediate1.pem'
  cacertkey='intermediate1.key'
elif [ -n "$arg2" ]
then
  echo "Arg2 string is empty!!" >&2
  echo "Please enter either rootca or intermediate"
  # return 1
  exit 1
fi


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
  return 1
  
fi

# generate the CSR
openssl req -new -days 365 \
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

# generate the PKCS#8 version of the client key for jdbc use
openssl pkcs8 -topk8 -passout pass: -inform PEM -in $arg.key \
		-outform DER  -out $arg.pk8

cd ..

echo -e ""
echo -e "\033[0m================================================="
echo -e "Client Cert Created: \033[0;35m$arg.crt"
echo -e "\033[0mPlease copy root CA cert cacert.pem or ca-chain.cert.pem if signed by intermediate CA"
echo -e "and \033[0;34m$arg.crt \033[0m & \033[0;34m$arg.key \033[0m or \033[0;34m$arg.pk8"
echo -e "\033[0m================================================="


