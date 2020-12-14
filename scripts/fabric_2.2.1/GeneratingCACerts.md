# Steps for creating the Crypto materials 

## Version of the CA - Server:
CA binaries version 1.4.9 should be used.
Check the server files (docker-compose.yaml and fabric-ca-server-config.yaml) to make sure the correct verison of binaries is mentioned

## Including the SANS parameter in the tls root certificate:
Include the SANS parameter "*.ceadar.org" in the TLS server config file under csr->hosts

## Starting the server:
Use the docker-compose files to bring up the org and tls server (./server/orgca and ./server/tlsca)

## Copy the root certificates of the servers for client usage:
Copy the root CA cert  of TLS server (./server/tlsca/ca-cert.pem) to TLS-client folder (./tlsclient/tls-certs)  and root CA cert of org servers (./server/orgca/ca-cert.pem) to the corresponding Org client folder  (./client/tls-certs)
 
## Generate the CA certificates:

Use the following scripts to generate the CA certificates

### Orderer:
For orderer use the following script command
````
./generatecrypto.sh orderer -a localhost -p 7710 -t 7701 -d ceadar.org -o orderer1 -s 127.0.0.1,*.ceadar.org
./generatecrypto.sh orderer -a localhost -p 7710 -t 7701 -d ceadar.org -o orderer2 -s 127.0.0.1,*.ceadar.org
./generatecrypto.sh orderer -a localhost -p 7710 -t 7701 -d ceadar.org -o orderer3 -s 127.0.0.1,*.ceadar.org
````
The scripts will generate the artifcats inside ./org_crypto folder under the orderer name

Create a new MSP folder for orderer ./org_crypto/orderer

Copy the following msp folder contents from any of the orderer into ./org_crypto/orderer
* ./msp/admincerts
* ./msp/cacerts
* ./msp/tlscacerts

Now copy the admin certs from the common msp folder ./org_crypto/orderer/msp/admincerts to all the orderer's msp folder

### Organizational peers:
For organizations use the following script command
```
./generatecrypto.sh peer -a localhost -p 7710 -t 7701 -d ceadar.org -o org1 -s 127.0.0.1,*.org1.ceadar.org
./generatecrypto.sh peer -a localhost -p 7710 -t 7701 -d ceadar.org -o org2 -s 127.0.0.1,*.org2.ceadar.org
./generatecrypto.sh peer -a localhost -p 7710 -t 7701 -d ceadar.org -o org3 -s 127.0.0.1,*.org3.ceadar.org
./generatecrypto.sh peer -a localhost -p 7710 -t 7701 -d ceadar.org -o org4 -s 127.0.0.1,*.org4.ceadar.org
```
The scripts will generate the artifcats inside ./org_crypto folder under the organization name