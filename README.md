# CA Server setup - Fabric 1.4.4

Production implementation of fabric network needs usage of fabric provided CA servers or any third party servers to generate the crypto materials.

To enable a server side TLS enabled fabric network we will use the following CA componenets
* TLS CA server (common for whole fabric network) 
* Organizational CA servers (Specific for each organization)

## TLS CA server setup 

The TLS server can be run on any one of the particiapting organization. For the reference purpose it is run on the orderer node of the organization

Refer the path ./TLSCA/Server/ for the configuration file to start a TLS CA server

The following sections has to be checked in the fabric-ca-server-config.yaml file

* Check for the port number of the server (7001 for TLS CA server. Same has to be configured under the ports section of docker-compose.yaml)
* Set tls.enabled as true (To enable the TLS connection for the server)
* ca.name (Give any name for the TLS server)
* Remove the ca profile under signing.profiles (Only for the TLS server)
* Change the csr section
  * cn  - common name (tlsca.ceadar.ucd.com)
  * names.c - Country code (IE) 
  * names.ST - State (Dublin) 
  * names.O - Name of the organization (UCD) 
  * names.OU - Organization unit (CeADAR) 
  * hosts - Add the IP address of the host where the server is deployed (192.168.0.221)
* operations.listenAddress - Change the port (Optional if in case the port clashes with any other existing port)

From the server path run the following command to start a TLS server

```
docker-compose up -d
```
Once the server is started it will generate the following files in the server path

* ca-cert.pem 
* tls-cert.pem
* msp folder

## TLS Client setup and Certificate generation

Refer the path ./TLSCA/Client for the configurations of the fabric client

Copy the fabric-ca-client binary for the corresponding version (fabric 1.4.4)

Use the follwing commands to enroll the bootstrap admin identity with the TLS CA server
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/tlsadmin
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/tlsadmin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server path post server startup)

./fabric-ca-client enroll -d -u https://admin:adminroot@192.168.0.221:7001  --enrollment.profile tls --csr.cn 'tlsca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.221' 
```

Use the following commands to register the TLS users for each of the organizational peers and orderer peers
```
./fabric-ca-client register -d --id.name orderer1-tls --id.secret orderer1root --id.type orderer -u https://192.168.0.221:7001 --csr.cn 'orderer1.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.221' 

./fabric-ca-client register -d --id.name peer0-orga-tls --id.secret peerroot --id.type peer -u https://192.168.0.221:7001 --csr.cn 'orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129' 

./fabric-ca-client register -d --id.name peer0-orgb-tls --id.secret peerroot --id.type peer -u https://192.168.0.221:7001 --csr.cn 'orgb.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.171' 
```

The following things has to be noted when we are registering TLS Id's for organizational peers
* id.type shoule be peer or orderer based on the organization
* include address of the peer's machine under the csr.hosts (192.168.0.129 for OrgA and 192.168.0.171 for OrgB)

Now the steps for bootstrapping the TLS CA server and registering the TLS id's for all the nodes are completed


## Organizational CA server setup 

For each organization a unique CA server will be setup. The same set of steps will be followed for each and every organizational peers (both orderer and peers)

Refer the path ./OrgCA/Server/ for the configuration file to start any Organizational CA server

The following sections has to be checked in the fabric-ca-server-config.yaml file

* Check for the port number of the server (7010 for CA server. Same has to be configured under the ports section of docker-compose.yaml)
* Set tls.enabled as true (To enable the TLS connection for the server)
* ca.name (Give any name for the TLS server)
* Change the csr section
  * cn  - common name (orgaca.ceadar.ucd.com)
  * names.c - Country code (IE) 
  * names.ST - State (Dublin) 
  * names.O - Name of the organization (UCD) 
  * names.OU - Organization unit (CeADAR) 
  * hosts - Add the IP address of the host where the server is deployed (192.168.0.129)

From the server path run the following command to start a TLS server

```
docker-compose up -d
```
Once the server is started it will generate the following files in the server path

* ca-cert.pem 
* tls-cert.pem
* msp folder

## Organizational Client setup and Certificate generation

Refer the path ./OrgCA/Client for the configurations of the fabric client

Copy the fabric-ca-client binary for the corresponding version (fabric 1.4.4)


Use the follwing commands to enroll the bootstrap admin identity with the Organizational CA server
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/orgacaadmin
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/orgacaadmin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem

./fabric-ca-client enroll -d -u https://admin:adminroot@192.168.0.129:7010 --csr.cn 'orgaca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129'
```

Register the peer/orderer user and admin user for each organization
```
./fabric-ca-client register -d --id.name peer0-orga --id.secret peer0OrgaPW --id.type peer -u https://192.168.0.129:7010 --csr.cn 'orgaca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129' 

./fabric-ca-client register -d --id.name admin-orga --id.secret orgaAdminPW --id.type admin -u https://192.168.0.129:7010 --csr.cn 'orgaca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129' 

./fabric-ca-client register -d --id.name peer0-user1 --id.secret peer0User1PW --id.type user -u https://192.168.0.129:7010 --csr.cn 'orgaca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129' 
```


Enroll the TLS-ID for the given peer with the TLS CA server

```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/peer-orga-tls
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/peer-orga-tls/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/tlsca-cert.pem*
(This is the CA certificate copied from the TLSCA server path since we are enrolling against the TLS CA server)

./fabric-ca-client enroll -d -u https://peer0-orga-tls:peerroot@192.168.0.221:7001 --enrollment.profile tls --csr.cn 'orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129'
```

Enroll the peer id for Orga
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/peer0-orga
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/peer0-orga/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem
./fabric-ca-client enroll -d -u https://peer0-orga:peer0OrgaPW@192.168.0.129:7010 --id.type peer --csr.cn 'orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129 '
```

Enroll the admin for Orga 

For organization with multiple peers generate admin at any one peer and copy it to rest of the peer
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/admin-orga
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/admin-orga/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem
./fabric-ca-client enroll -d -u https://admin-orga:orgaAdminPW@192.168.0.129:7010 --id.type admin --csr.cn 'orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.com,192.168.0.129 '
```
