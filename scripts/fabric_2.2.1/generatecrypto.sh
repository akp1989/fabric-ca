function enrollCAAdmin() {
  IDNAME=caadmin
  CSR_CNAME=\'$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME\'
  export FABRIC_CA_CLIENT_HOME=$PWD/client/profiles/$IDNAME
  export FABRIC_CA_CLIENT_MSPDIR=$PWD/client/profiles/$IDNAME/msp
  export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/client/tls-certs/ca-cert.pem
  if [ ! -d ${FABRIC_CA_CLIENT_MSPDIR} ];  then
  ./client/fabric-ca-client enroll -d -u https://admin:adminroot@$SERVER_ADDRESS:$SERVER_PORT --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS 
  printf "\n\n\n-------> CA Admin was successfully enrolled \n\n\n"
  else
  printf "\n\n\n-------> CA Admin was already enrolled \n\n\n"
  fi
  
  
}

function registerTLSCredentials() {
  IDNAME=tlscaadmin
  CSR_CNAME=\'$IDNAME.$DOMAIN_NAME\'
  export FABRIC_CA_CLIENT_HOME=$PWD/tlsclient/profiles/$IDNAME
  export FABRIC_CA_CLIENT_MSPDIR=$PWD/tlsclient/profiles/$IDNAME/msp
  export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/tlsclient/tls-certs/ca-cert.pem
  if [ ! -d ${FABRIC_CA_CLIENT_MSPDIR} ];  then
  ./client/fabric-ca-client enroll -d -u https://admin:adminroot@$SERVER_ADDRESS:$TLS_PORT --csr.cn $CSR_CNAME --csr.names $CSR_NAME
  printf "\n\n\n-------> TLSCA Admin was successfully enrolled \n\n\n"
  else
  printf "\n\n\n-------> TLSCA Admin was already enrolled \n\n\n"
  fi
  
  
  
}

function enrollTLSCredentials() {
  if [ "$MODE" == "peer" ]; then
    IDNAME=tls-peer0
	IDTYPE=peer
    CSR_CNAME=\'$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME\'
    CSR_CNAME_TMP=$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME
  else
  	IDTYPE=orderer
    IDNAME=tls-orderer
    CSR_CNAME=\'$ORGANIZATION_NAME.$DOMAIN_NAME\'
    CSR_CNAME_TMP=$ORGANIZATION_NAME.$DOMAIN_NAME  
  fi
  
  ./client/fabric-ca-client register -d --id.name $CSR_CNAME_TMP --id.secret orgroot --id.type $IDTYPE -u https://$SERVER_ADDRESS:$TLS_PORT --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS
  printf  "\n\n\n-------> The TLS credentials for $IDNAME was successfully registered for $ORGANIZATION_NAME.$DOMAIN_NAME \n\n\n"
  export FABRIC_CA_CLIENT_HOME=$PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME
  export FABRIC_CA_CLIENT_MSPDIR=$PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME/msp
  ./client/fabric-ca-client enroll -d -u https://$CSR_CNAME_TMP:orgroot@$SERVER_ADDRESS:$TLS_PORT --enrollment.profile tls --id.type $IDTYPE --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS
  printf  "\n\n\n-------> The TLS credentials for $IDNAME was successfully enrolled for $ORGANIZATION_NAME.$DOMAIN_NAME \n\n\n"
}
function registerPeerCredentials() {
  if [ "$MODE" == "peer" ]; then
    IDNAME=peer0
	IDTYPE=peer
  else
  	IDTYPE=orderer
    IDNAME=orderer 
  fi
  CSR_CNAME=\'$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME\'
  CSR_CNAME_TMP=$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME
  ./client/fabric-ca-client register -d --id.name $CSR_CNAME_TMP --id.secret orgroot --id.type $IDTYPE -u https://$SERVER_ADDRESS:$SERVER_PORT --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS
  printf  "\n\n\n-------> The peer credentials for $IDNAME was successfully registered for $ORGANIZATION_NAME.$DOMAIN_NAME \n\n\n"
  
  CSR_CNAME=\'admin.$ORGANIZATION_NAME.$DOMAIN_NAME\'
  CSR_CNAME_TMP=admin.$ORGANIZATION_NAME.$DOMAIN_NAME
  ./client/fabric-ca-client register -d --id.name $CSR_CNAME_TMP --id.secret adminroot --id.type admin -u https://$SERVER_ADDRESS:$SERVER_PORT --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS
  printf  "\n\n\n-------> The admin credentials for $IDNAME was successfully registered for $ORGANIZATION_NAME.$DOMAIN_NAME \n\n\n"
}

function enrollPeerCredentials() {
  if [ "$MODE" == "peer" ]; then
    IDNAME=peer0
	IDTYPE=peer
  else
  	IDTYPE=orderer
    IDNAME=orderer 
  fi
  CSR_CNAME=\'$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME\'
  CSR_CNAME_TMP=$IDNAME.$ORGANIZATION_NAME.$DOMAIN_NAME
  export FABRIC_CA_CLIENT_HOME=$PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME
  export FABRIC_CA_CLIENT_MSPDIR=$PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME/msp
  export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/client/tls-certs/ca-cert.pem
  ./client/fabric-ca-client enroll -d -u https://$CSR_CNAME_TMP:orgroot@$SERVER_ADDRESS:$SERVER_PORT --id.type $IDTYPE --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS
  	echo "----->The id $CSR_CNAME has been enrolled with  $ORGANIZATION_NAME.$DOMAIN_NAME "
  printf  "\n\n\n-------> The peer credentials for $IDNAME was successfully enrolled for $ORGANIZATION_NAME.$DOMAIN_NAME \n\n\n"
  CSR_CNAME=\'admin.$ORGANIZATION_NAME.$DOMAIN_NAME\'
  CSR_CNAME_TMP=admin.$ORGANIZATION_NAME.$DOMAIN_NAME
  export FABRIC_CA_CLIENT_HOME=$PWD/client/profiles/admin-$ORGANIZATION_NAME
  export FABRIC_CA_CLIENT_MSPDIR=$PWD/client/profiles/admin-$ORGANIZATION_NAME/msp
  export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/client/tls-certs/ca-cert.pem
  ./client/fabric-ca-client enroll -d -u https://$CSR_CNAME_TMP:adminroot@$SERVER_ADDRESS:$SERVER_PORT --id.type admin --csr.cn $CSR_CNAME --csr.names $CSR_NAME --csr.hosts $CSR_HOSTS
  printf  "\n\n\n-------> The admin credentials for $IDNAME was successfully enrolled for $ORGANIZATION_NAME.$DOMAIN_NAME \n\n\n"

}

function populateAdminUser() {
  
  ADMIN_USER_MSP="$ORG_ROOT_DIR/$ORGANIZATION_NAME/adminuser" 
  if [ ! -d  $ADMIN_USER_MSP ]; then
  mkdir $ADMIN_USER_MSP
  mkdir $ADMIN_USER_MSP/msp
  cp ./config.yaml $ADMIN_USER_MSP/msp/
  mkdir $ADMIN_USER_MSP/msp/cacerts
  mkdir $ADMIN_USER_MSP/msp/keystore
  mkdir $ADMIN_USER_MSP/msp/signcerts
  mkdir $ADMIN_USER_MSP/msp/tlscacerts
  printf "\n-------->Created the msp directories for $ORGANIZATION_NAME admin msp\n"
  fi
  cp $PWD/client/tls-certs/ca-cert.pem $ADMIN_USER_MSP/msp/cacerts/ca-cert.pem
  cp $PWD/tlsclient/tls-certs/ca-cert.pem $ADMIN_USER_MSP//msp/tlscacerts/tlsca-cert.pem
  cp -R $PWD/client/profiles/admin-$ORGANIZATION_NAME/msp/signcerts $ADMIN_USER_MSP/msp/
  cp -R $PWD/client/profiles/admin-$ORGANIZATION_NAME/msp/keystore  $ADMIN_USER_MSP/msp/
  printf "\n-------->Populated the msp directories for $ORGANIZATION_NAME admin msp\n"
}

function populateTLSUser() {
  if [ "$MODE" == "peer" ]; then
    IDNAME=tls-peer0
  else
  	IDNAME=tls-orderer
  fi
  TLS_USER_MSP="$ORG_ROOT_DIR/$ORGANIZATION_NAME/msp-$IDNAME"
  if [ ! -d  $TLS_USER_MSP ]; then
  mkdir $TLS_USER_MSP
  cp ./config.yaml $TLS_USER_MSP/
  mkdir $TLS_USER_MSP/cacerts
  mkdir $TLS_USER_MSP/keystore
  mkdir $TLS_USER_MSP/signcerts
  mkdir $TLS_USER_MSP/tlscacerts
  printf "\n-------->Created the msp directories for $IDNAME of $ORGANIZATION_NAME\n"
  fi
  cp $PWD/client/tls-certs/ca-cert.pem $TLS_USER_MSP/cacerts/ca-cert.pem
  cp $PWD/tlsclient/tls-certs/ca-cert.pem $TLS_USER_MSP/tlscacerts/tlsca-cert.pem
  cp -R $PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME/msp/signcerts $TLS_USER_MSP
  KEY_FILE=$(ls client/profiles/$IDNAME-$ORGANIZATION_NAME/msp/keystore/ -t1 | head -n 1)	
  cp -R $PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME/msp/keystore/$KEY_FILE  $TLS_USER_MSP/keystore/key.pem
  printf "\n-------->Populated the msp directories for $IDNAME of $ORGANIZATION_NAME\n"
}

function populatePeerUser() {
  if [ "$MODE" == "peer" ]; then
    IDNAME=peer0
  fi
  PEER_USER_MSP="$ORG_ROOT_DIR/$ORGANIZATION_NAME/msp-$IDNAME"
  if [ ! -d  $PEER_USER_MSP ]; then
  mkdir $PEER_USER_MSP
  cp ./config.yaml $PEER_USER_MSP/
  mkdir $PEER_USER_MSP/cacerts
  mkdir $PEER_USER_MSP/keystore
  mkdir $PEER_USER_MSP/signcerts
  mkdir $PEER_USER_MSP/tlscacerts
  printf "\n-------->Created the msp directories for $IDNAME of $ORGANIZATION_NAME\n"
  fi
  cp $PWD/client/tls-certs/ca-cert.pem $PEER_USER_MSP/cacerts/ca-cert.pem
  cp $PWD/tlsclient/tls-certs/ca-cert.pem $PEER_USER_MSP/tlscacerts/tlsca-cert.pem
  cp -R $PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME/msp/signcerts $PEER_USER_MSP
  cp -R $PWD/client/profiles/$IDNAME-$ORGANIZATION_NAME/msp/keystore  $PEER_USER_MSP
  printf "\n-------->Populated the msp directories for $IDNAME of $ORGANIZATION_NAME\n"
}

function populatePeerMSP() {
  PEER_MSP="$ORG_ROOT_DIR/$ORGANIZATION_NAME/msp"
  if [ ! -d  $PEER_MSP ]; then
  mkdir $PEER_MSP
  cp ./config.yaml $PEER_MSP/
  mkdir $PEER_MSP/admincerts
  mkdir $PEER_MSP/cacerts
  mkdir $PEER_MSP/tlscacerts
  printf "\n-------->Created the msp directories for $ORGANIZATION_NAME peer msp\n"
  fi
  cp $PWD/client/tls-certs/ca-cert.pem $PEER_MSP/cacerts/ca-cert.pem
  cp $PWD/tlsclient/tls-certs/ca-cert.pem $PEER_MSP/tlscacerts/tlsca-cert.pem
  FILE_NAME=$(ls $ORG_ROOT_DIR/$ORGANIZATION_NAME/adminuser/msp/signcerts/ -t1 | head -n 1)	
  cp $ORG_ROOT_DIR/$ORGANIZATION_NAME/adminuser/msp/signcerts/$FILE_NAME $PEER_MSP/admincerts/$FILE_NAME
  printf "\n-------->Populated the msp directories for $ORGANIZATION_NAME peer msp\n"
}
function populateOrdererMSP() {
  ORDERER_MSP="$ORG_ROOT_DIR/$ORGANIZATION_NAME/msp"
  if [ ! -d  $ORDERER_MSP ]; then
  mkdir $ORDERER_MSP
  cp ./config.yaml $ORDERER_MSP/
  mkdir $ORDERER_MSP/admincerts
  mkdir $ORDERER_MSP/cacerts
  mkdir $ORDERER_MSP/tlscacerts
  printf "\n-------->Created the msp directories for $ORGANIZATION_NAME orderer msp\n"
  fi
  cp $PWD/client/tls-certs/ca-cert.pem $ORDERER_MSP/cacerts/ca-cert.pem
  cp $PWD/tlsclient/tls-certs/ca-cert.pem $ORDERER_MSP/tlscacerts/tlsca-cert.pem
  cp -R $PWD/client/profiles/orderer-$ORGANIZATION_NAME/msp/signcerts $ORDERER_MSP
  cp -R $PWD/client/profiles/orderer-$ORGANIZATION_NAME/msp/keystore $ORDERER_MSP
  FILE_NAME=$(ls $PWD/client/profiles/admin-$ORGANIZATION_NAME/msp/signcerts/ -t1 | head -n 1)	
  cp $PWD/client/profiles/admin-$ORGANIZATION_NAME/msp/signcerts/$FILE_NAME $ORDERER_MSP/admincerts/$FILE_NAME
  printf "\n-------->Populated the msp directories for $ORGANIZATION_NAME orderer msp\n"
}

function printHelp() {
  echo "Usage: "
  echo "  generatecrypto.sh <mode> [-a <Server address>] [-p <Server port>] [-o <Organization name>] [-t <tlsserver-port>] [-d <domain name>] [-s <SANS parameter ip>]"
  echo "    <mode> - one of 'peer', 'orderer'"
  echo "      - 'peer' - Peer certificates"
  echo "      - 'orderer' - Orderer certificates"
  echo "    -a <Server address> - The address of the certificate authority server to be used "
  echo "    -p <port> - The port number of the certificate authority server to be used"
  echo "    -o <orgname> - The name of the organaization to be used"
  echo "    -t <tls port> - The port number of the TLS authority server to be used"
  echo "    -d <domain name> - Domain name of the organization "
  echo "    -s <SANS parameter IP> - IP address of the organization "
  echo "  generatecrypto.sh -h (print this message)"

}




MODE=$1
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "orderer" ]; then
  echo $MODE
elif [ "$MODE" == "peer" ]; then
  echo $MODE
else
  printHelp
  exit 1
fi

while getopts "h?a:p:o:d:s:t:" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  a)
    SERVER_ADDRESS=$OPTARG
    ;;
  p)
    SERVER_PORT=$OPTARG
    ;;
  t)
    TLS_PORT=$OPTARG
	;;
  o)
    ORGANIZATION_NAME=$OPTARG
	;;
  d)
    DOMAIN_NAME=$OPTARG
	;;
  s)
    SERVER_HOST_ADDRESS=$OPTARG
	;;
  esac
done


# Announce what was requested
ORG_ROOT_DIR=$PWD/org_crypto
CSR_HOSTS=localhost,$SERVER_HOST_ADDRESS
CSR_NAME='C=IE,ST=Dublin,O=UCD,OU=CeADAR'

enrollCAAdmin
registerPeerCredentials
enrollPeerCredentials
registerTLSCredentials
enrollTLSCredentials


if [ ! -d  ${ORG_ROOT_DIR} ]; then
  mkdir $ORG_ROOT_DIR
  echo "Created the organization root directory"
fi

#Create the directory for the organization
 
if [ ! -d  "$ORG_ROOT_DIR/$ORGANIZATION_NAME" ]; then
  mkdir $ORG_ROOT_DIR/$ORGANIZATION_NAME
  echo "Created the organization CA directory for $ORGANIZATION_NAME"
fi

populateTLSUser
if [ "$MODE" == "peer" ]; then
populateAdminUser
populatePeerUser
populatePeerMSP
else
populateOrdererMSP
fi