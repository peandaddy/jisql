# Scripts for creating SSL/TLS certificates for pgBouncer and PostgreSQL 
These scripts are tested for the purpose of configuring a non-commercial **root CA**, **intermediate CA**, and **server** and **client** certificates that are either signed by the root CA or the intermediate CA that the root CA chained and signed.

I believed this could be executed on any server. Five Shell scripts available. The Linux environment is required for its operation.

>If you change files in a Windows environment, it is better to use the **dos2unix** tool to resolve the CR/LF issue.

* 00-prepare-ca-folder.sh: It is safe to run. It is prepared to contain variable files and folders.
* 01-make-root-ca.sh: Make your own root CA.
* 02-make-intermediate-ca.sh: Make your own intermediate CA and have the earlier root CA sign it.
* 03-make-server-cert.sh: Make a certificate for the server you want to use.
* 04-make-client-cert.sh: Make a certificate for the client you want to use. If you configure **`pg_hba.cnf`** for cert access only with **`hostssl`** setup, this would be the postgresql login name.
```bash
./03-make-server-cert.sh "server name" "SAN name" "sign by root CA or intermediate"
./03-make-server-cert.sh "postgresql1" "postgresql1" "rootca"
./03-make-server-cert.sh "postgresql1" "postgresql1" "intermediate"
./03-make-server-cert.sh "postgresql1" "postgresql1 pgserver.com" "rootca"
./03-make-server-cert.sh "postgresql1" "sql1 sql2.us.com sql3 sql4.com" "rootca"
```

The scripts were changed based on Andrew Dunstan I am referring to. Well done, he came up with such a brilliant solution. 
https://github.com/adunstan/ssl-scripts/tree/master