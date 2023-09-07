#!/usr/bin/env bash
#
# Generates certs for SAML use, entirely interactive :D
#
# Ty Mees (T.D.Mees@uu.nl) 2023-09-07

set -e

echo "Welcome to the SAML self-signed cert generator script! We will ask you some questions, and then generate all you need for you!"
echo "Most questions have sensible defaults, indicated by the value inside [<x>]. If the default is fine, just press enter"
echo ""

echo "First off, let's get some cert info"
read -p 'What the FQDN of your app?: ' FQDN

if [[ -z "${FQDN// }" ]]; then
  echo "No FQDN specified, exiting"
  exit 1
fi

echo "If your app has multiple hostnames, list them here (using a space as a delimiter)."
echo "If not, just press enter to advance."
read -a FQDN_ALT

read -p 'How long (in days) should the cert be valid? [1825]' VALID_DAYS

read -p "Where you you want the generated files to be placed? [./certs]" OUTDIR

if [[ -z "${VALID_DAYS// }" ]]; then VALID_DAYS='1825'; fi
if [[ -z "${OUTDIR// }" ]]; then OUTDIR='./certs'; fi

echo ""
echo "Now onto the organisational info"
read -p 'Your country? [NL]' COUNTRY
read -p 'Your province/state? [Utrecht]' STATE
read -p 'Your city? [Utrecht]' CITY
read -p 'Your organisation? [Universiteit Utrecht]' ORGANISATION
read -p 'Your department? [Humanities IT]' DEPARTMENT

if [[ -z "${COUNTRY// }" ]]; then COUNTRY='NL'; fi
if [[ -z "${STATE// }" ]]; then STATE='Utrecht'; fi
if [[ -z "${CITY// }" ]]; then CITY='Utrecht'; fi
if [[ -z "${ORGANISATION// }" ]]; then ORGANISATION='Universiteit Utrecht'; fi
if [[ -z "${DEPARTMENT// }" ]]; then DEPARTMENT='Humanities IT'; fi

echo ""
echo "Please review the entered data:"
echo -e "Output dir: \t\t ${OUTDIR}"
echo -e "FQDN: \t\t\t ${FQDN}"
echo -e "Alternative FQDS's: \t ${FQDN_ALT[*]}"
echo -e "Cert lifetime: \t\t ${VALID_DAYS} days"
echo -e "Country: \t\t ${COUNTRY}"
echo -e "Province/state: \t ${STATE}"
echo -e "Organisation: \t\t ${ORGANISATION}"
echo -e "Department: \t\t ${DEPARTMENT}"
echo ""

read -p "Does this look okay (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  echo "Okay, let's generate stuff!";
else
  echo "Please run this script again";
  exit
fi

echo ""

if [ ! -d "$OUTDIR" ]; then
  echo "$OUTDIR does not exist."

  read -p "Does you want to create it (y/n)?" CONT
  if [ "$CONT" = "y" ]; then
    mkdir -p $OUTDIR;
  else
    echo "Cannot continue then"
    exit
  fi
fi

PRIVATE_KEY_FILE="${OUTDIR}/${FQDN}.key"
CONFIG_FILE="${OUTDIR}/${FQDN}.cfg"
CSR_FILE="${OUTDIR}/${FQDN}.csr"
CERT_FILE="${OUTDIR}/${FQDN}.crt"

echo "Generating private key ${PRIVATE_KEY_FILE}"
openssl genrsa -out $PRIVATE_KEY_FILE 4096
echo ""

echo "Generating openssl config file ${CONFIG_FILE}"
tee -a $CONFIG_FILE << END
[ req ]
default_bits            = 4096
default_keyfile         = ${FQDN}.key
distinguished_name      = req_distinguished_name
attributes              = req_attributes
prompt                  = no
req_extensions          = v3_req

[ req_distinguished_name ]
C                       = ${COUNTRY}
O                       = ${ORGANISATION}
OU                      = ${DEPARTMENT}
ST                      = ${STATE}
L                       = ${CITY}
CN                      = ${FQDN}

[ req_attributes ]

[ v3_req ]
subjectAltName=@alt_names
keyUsage = digitalSignature

[alt_names]
DNS.1 = ${FQDN}
END

for index in "${!FQDN_ALT[@]}";
do
  file_index=`expr $index + 2`
  echo "DNS.${file_index} = ${FQDN_ALT[$index]}" >> $CONFIG_FILE
done
echo ""

echo "Generating CSR ${CSR_FILE}"
openssl req -new -sha256 -config $CONFIG_FILE -key $PRIVATE_KEY_FILE -out $CSR_FILE
echo ""

echo "Generating certificate"
openssl x509 -req -sha384 -days $VALID_DAYS -in $CSR_FILE -signkey $PRIVATE_KEY_FILE -out $CERT_FILE -extfile $CONFIG_FILE -extensions v3_req
echo ""

echo "Done!"