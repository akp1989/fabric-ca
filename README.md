# CA Server setup - Fabric 1.4.4

Production implementation of fabric network needs usage of fabric provided CA servers or any third party servers to generate the crypto materials.

To enable a server side TLS enabled fabric network we will use the following CA componenets
* TLS CA server (common for whole fabric network) 
* Intermediate CA server (Optional for each organization or for all organization)
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
  * hosts - Add the IP address of the host where the server is deployed (192.168.0.221) and the hostname and address of the orderer organization (to use for the peer and channel commands in Client or CLI)
* operations.listenAddress - Change the port (Optional if in case the port clashes with any other existing port)

From the server path run the following command to start a TLS server

```
docker-compose up -d
```
Once the server is started it will generate the following files in the server path

* ca-cert.pem (This is the root certificate of the TLS server which will be used for all the TLS communication)
* tls-cert.pem
* msp folder

## TLS Client setup and Certificate generation

Refer the path ./TLSCA/Client for the configurations of the fabric client

Copy the fabric-ca-client binary for the corresponding version (fabric 1.4.4)

Use the follwing commands to enroll the bootstrap admin identity with the TLS CA server
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/tlsadmin
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/tlsadmin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)

./fabric-ca-client enroll -d -u https://admin:adminroot@192.168.0.221:7001  --enrollment.profile tls --csr.cn 'tlsca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.ucd.com,192.168.0.221' 
```

* include the hostname and address of the orderer organization (*.ceadar.ucd.com and 192.168.0.221) so that the root certificate can be used as TLS root cert for peer and channel transaction via client or cli

Register the TLS credentials for the Intermediate and org servers
```
./fabric-ca-client register -d --id.name rcaadmin --id.secret rcaadminpw --id.type peer -u https://192.168.0.221:7001 
./fabric-ca-client register -d --id.name icaadmin --id.secret icaadminpw --id.type peer -u https://192.168.0.221:7001

```
Enroll the TLS ID's to bootstrap the 
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/rcadmin-bootstraptls/msp
./fabric-ca-client enroll -d -u https://rcaadmin:rcaadminpw@192.168.0.221:7001 --id.type peer --enrollment.profile tls --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,127.0.0.1,0.0.0.0,192.168.0.221,*.ceadar.ucd.com'

export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/icaadmin-bootstraptls/msp
./fabric-ca-client enroll -d -u https://icaadmin:icaadminpw@192.168.0.221:7001 --id.type peer --enrollment.profile tls --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,127.0.0.1,0.0.0.0,192.168.0.221,*.ceadar.ucd.com' 


Use the following commands to register the TLS users for each of the organizational peers and orderer peers
```
./fabric-ca-client register -d --id.name orderer1-orderer.ceadar.ucd.com --id.secret orderer1root --id.type orderer -u https://192.168.0.221:7001 --csr.cn 'orderer1-orderer.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.ucd.com,192.168.0.221' 

./fabric-ca-client register -d --id.name peer0.orga.ceadar.ucd.com --id.secret peer0OrgaPW --id.type peer -u https://192.168.0.221:7001 --csr.cn 'peer0.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129' 

./fabric-ca-client register -d --id.name peer0.orgb.ceadar.ucd.com --id.secret peer0OrgbPW --id.type peer -u https://192.168.0.221:7001 --csr.cn 'peer0.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orgb.ceadar.ucd.com,192.168.0.171' 
```

The following things has to be noted when we are registering TLS Id's for organizational peers
* id.type shoule be peer or orderer based on the organization
* include address of the peer's machine under the csr.hosts (192.168.0.129 for OrgA and 192.168.0.171 for OrgB)

Now the steps for bootstrapping the TLS CA server and registering the TLS id's for all the nodes are completed


## Using RootServer (so that orgca will be an intermediate server)
If we are using a root CA server then the organizational CA-Server can be an intermediate server

While starting the Root server use the TLS credentials from /TLSCA/Client/profiles/rcadmin-bootstraptls/msp
Copy the signcert and key to the root server home path ./RootCA/Server/tls and create the reference in the server-config.yaml under TLS section. The server will start with the given TLS credentials and the TLS servers root cert can be used for all the communication
Refer the path ./RootCA/Server for the configuration file to start any Root CA server
The following sections has to be checked in the fabric-ca-server-config.yaml file

* Check for the port number of the server (7009 for Root CA server. Same has to be configured under the ports section of docker-compose.yaml)
* Set tls.enabled as true (To enable the TLS connection for the server)
* tls.certfile to be set as tls/cert.pem 
* tls.key to be set as tls/key.pem
* ca.name (Give any name for the TLS server)
* Change the csr section
  * cn  - common name (orgaca.ceadar.ucd.com)
  * names.c - Country code (IE) 
  * names.ST - State (Dublin) 
  * names.O - Name of the organization (UCD) 
  * names.OU - Organization unit (CeADAR) 
  * hosts - Add the IP address of the host where the server is deployed (192.168.0.129)
From the server path run the following command to start a RootCA server

```
docker-compose up -d
```
## Root server client setup
Refer the path ./TLSCA/Client for the configurations of the fabric client

Copy the fabric-ca-client binary for the corresponding version (fabric 1.4.4)

Use the follwing commands to enroll the bootstrap admin identity with the Orgroot CA server
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/orgrootadmin
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/orgrootadmin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)

./fabric-ca-client enroll -d -u https://rcadmin:rcadminpw@192.168.0.221:7009  --csr.cn 'orgrootadmin.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.ceadar.ucd.com,192.168.0.221' 
```


#Register the intermediate CA bootstrap identity
./fabric-ca-client register -d --id.name icadmin.root --id.secret icadminrootpw --id.type admin -u https://192.160.0.221:7009 --id.attrs '"hf.Registrar.Roles=user,admin","hf.Revoker=true","hf.IntermediateCA=true"'

* Important to maintain the roles for the intermediate server credentials while registering 
* The id will only be registered at the root server. It will be used as root server credentials in the intermediate servers down the config while start up
* It is necessary to keep the root server on every time the corresponding intermediate CA's are brought up for the above mentioned ID's enrolling purpose



## Organizational CA server setup 
While starting the Organizational CA server use the TLS credentials from /TLSCA/Client/profiles/icadmin-bootstraptls/msp
Copy the signcert and key to the root server home path ./OrgCA/Server/tls and create the reference in the server-config.yaml under TLS section. The server will start with the given TLS credentials and the TLS servers root cert can be used for all the communication
Additionally add the tls servers root certificate renamed as tls-ca-cert.pem under ./OrgCA/Server/tls/tls-ca-cert.pem so that the organizational server can communicate with the Root server during startup

For each organization a unique CA server will be setup. The same set of steps will be followed for each and every organizational peers (both orderer and peers)

Refer the path ./OrgCA/Server/ for the configuration file to start any Organizational CA server

The following sections has to be checked in the fabric-ca-server-config.yaml file

* Check for the port number of the server (7010 for CA server. Same has to be configured under the ports section of docker-compose.yaml)
* Set tls.enabled as true (To enable the TLS connection for the server)
* tls.certfile to be set as tls/cert.pem 
* tls.key to be set as tls/key.pem
* ca.name (Give any name for the TLS server)
* Change the csr section
  * cn  - common name (orgaca.ceadar.ucd.com)
  * names.c - Country code (IE) 
  * names.ST - State (Dublin) 
  * names.O - Name of the organization (UCD) 
  * names.OU - Organization unit (CeADAR) 
  * hosts - Add the IP address of the host where the server is deployed (192.168.0.129)
* While using the root server edit the intermediate 
  * parentserver.url: https://icadmin.root:icadminrootpw@192.168.0.221:7009
  * parentserver.caname: orgroot.ceadar.ucd.com
  * enrollment.profile: ca
  * tls.certfiles: tls/tls-ca-cert.pem

From the server path run the following command to start a TLS server

```
docker-compose up -d
```
The server will refer to the parentserver during startup if specified
Once the server is started it will generate the following files in the server path

* msp folder

## Organizational Client setup and Certificate generation

Refer the path ./OrgCA/Client for the configurations of the fabric client

Copy the fabric-ca-client binary for the corresponding version (fabric 1.4.4)


Use the following commands to enroll the bootstrap admin identity with the Organizational CA server
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/orgacaadmin
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/orgacaadmin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server) 

./fabric-ca-client enroll -d -u https://admin:adminroot@192.168.0.129:7010 --csr.cn 'orgaca.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129'
```

Register the peer/orderer user and admin user for each organization
```
./fabric-ca-client register -d --id.name peer0.orga.ceadar.ucd.com --id.secret peer0OrgaPW --id.type peer -u https://192.168.0.129:7010 --csr.cn 'peer0.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129' 

./fabric-ca-client register -d --id.name admin.orga.ceadar.ucd.com --id.secret orgaAdminPW --id.type admin -u https://192.168.0.129:7010 --csr.cn 'admin.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129' 

./fabric-ca-client register -d --id.name user1.orga.ceadar.ucd.com --id.secret peer0User1PW --id.type client -u https://192.168.0.129:7010 --csr.cn 'user1.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129' 
```


Enroll the TLS-ID for the given peer with the TLS CA server

```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/peer-orga-tls
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/peer-orga-tls/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certsca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)  

./fabric-ca-client enroll -d -u https://peer0.orga.ceadar.ucd.com:peer0OrgaPW@192.168.0.221:7001 --enrollment.profile tls --csr.cn 'peer0.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129'
```

Enroll the peer id for Orga
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/peer0-orga
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/peer0-orga/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certsca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)
./fabric-ca-client enroll -d -u https:/peer0.orga.ceadar.ucd.com:peer0OrgaPW@192.168.0.129:7010 --id.type peer --csr.cn 'peer0.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129'
```

Enroll the admin for Orga 

For organization with multiple peers generate admin at any one peer and copy it to rest of the peer
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/admin-orga
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/admin-orga/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certsca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)
./fabric-ca-client enroll -d -u https://admin.orga.ceadar.ucd.com:orgaAdminPW@192.168.0.129:7010 --id.type admin --csr.cn 'admin.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129'
```
Enroll the user1 for Orga 

For organization with multiple peers generate admin at any one peer and copy it to rest of the peer
```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/user1-orga
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/user1-orga/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)
./fabric-ca-client enroll -d -u https://user1.orga.ceadar.ucd.com:peer0User1PW@192.168.0.129:7010 --id.type admin --csr.cn 'user1.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129'
```

To re-enroll a given user, export all environment variables as used in the enroll command for that id and add an extra parameter --csr.keyrequest.reusekey. This will re-enroll the id with the same private key

For eg: to re-enroll the peer id of peer0-orga

```
export FABRIC_CA_CLIENT_HOME=$PWD/profiles/peer0-orga
export FABRIC_CA_CLIENT_MSPDIR=$PWD/profiles/peer0-orga/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tls-certs/ca-cert.pem (The ca-cert.pem has to be copied from the TLS CA server)
./fabric-ca-client enroll -d -u https:/peer0.orga.ceadar.ucd.com:peer0OrgaPW@192.168.0.129:7010 --id.type peer --csr.cn 'peer0.orga.ceadar.ucd.com' --csr.names 'C=IE,ST=Dublin,O=UCD,OU=CeADAR' --csr.hosts 'localhost,*.orga.ceadar.ucd.com,192.168.0.129' --csr.keyrequest.reusekey
```