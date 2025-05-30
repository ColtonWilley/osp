#!/bin/bash

# Script to generate ML-DSA NIST Level 2,3 and 5 certificate chains.
#
# Copyright 2024 wolfSSL Inc. All rights reserved.
# Original Author: Anthony Hu.
#
# Execute this script after building OQS's OpenSSL provider using the
# scripts/fullbuild.sh script. Note that you will need to modify the paths
# in the following variables.

OPENSSL_EXEC=openssl 
PROVIDER_PATH=./_build/lib/
PROVIDER_NAME=oqsprovider

# No need to modify anything below here.

# Generate conf files.
printf "\
[ req ]\n\
prompt                 = no\n\
distinguished_name     = req_distinguished_name\n\
\n\
[ req_distinguished_name ]\n\
C                      = CA\n\
ST                     = ON\n\
L                      = Waterloo\n\
O                      = wolfSSL Inc.\n\
OU                     = Engineering\n\
CN                     = Root Certificate\n\
emailAddress           = root@wolfssl.com\n\
\n\
[ ca_extensions ]\n\
subjectKeyIdentifier   = hash\n\
authorityKeyIdentifier = keyid:always,issuer:always\n\
keyUsage               = critical, keyCertSign\n\
basicConstraints       = critical, CA:true\n" > root.conf

printf "\
[ req ]\n\
prompt                 = no\n\
distinguished_name     = req_distinguished_name\n\
\n\
[ req_distinguished_name ]\n\
C                      = CA\n\
ST                     = ON\n\
L                      = Waterloo\n\
O                      = wolfSSL Inc.\n\
OU                     = Engineering\n\
CN                     = Entity Certificate\n\
emailAddress           = entity@wolfssl.com\n\
\n\
[ x509v3_extensions ]\n\
subjectAltName = IP:127.0.0.1\n\
subjectKeyIdentifier   = hash\n\
authorityKeyIdentifier = keyid:always,issuer:always\n\
keyUsage               = critical, digitalSignature\n\
extendedKeyUsage       = critical, serverAuth,clientAuth\n\
basicConstraints       = critical, CA:false\n" > entity.conf

###############################################################################
# Dilithium NIST Level 2
###############################################################################

# Generate root key and entity private keys.
${OPENSSL_EXEC} genpkey -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -algorithm mldsa44 -outform pem -out mldsa44_root_key.pem
${OPENSSL_EXEC} genpkey -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -algorithm mldsa44 -outform pem -out mldsa44_entity_key.pem

# Generate the root certificate
${OPENSSL_EXEC} req -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -x509 -config root.conf -extensions ca_extensions -days 1095 -set_serial 20 -key mldsa44_root_key.pem -out mldsa44_root_cert.pem

# Generate the entity CSR.
${OPENSSL_EXEC} req -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -new -config entity.conf -key mldsa44_entity_key.pem -out mldsa44_entity_req.pem

# Generate the entity X.509 certificate.
${OPENSSL_EXEC} x509 -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -req -in mldsa44_entity_req.pem -CA mldsa44_root_cert.pem -CAkey mldsa44_root_key.pem -extfile entity.conf -extensions x509v3_extensions -days 1095 -set_serial 21 -out mldsa44_entity_cert.pem

###############################################################################
# Dilithium NIST Level 3
###############################################################################

# Generate root key and entity private keys.
${OPENSSL_EXEC} genpkey -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -algorithm mldsa65 -outform pem -out mldsa65_root_key.pem
${OPENSSL_EXEC} genpkey -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -algorithm mldsa65 -outform pem -out mldsa65_entity_key.pem

# Generate the root certificate
${OPENSSL_EXEC} req -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -x509 -config root.conf -extensions ca_extensions -days 1095 -set_serial 30 -key mldsa65_root_key.pem -out mldsa65_root_cert.pem

# Generate the entity CSR.
${OPENSSL_EXEC} req -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -new -config entity.conf -key mldsa65_entity_key.pem -out mldsa65_entity_req.pem

# Generate the entity X.509 certificate.
${OPENSSL_EXEC} x509 -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -req -in mldsa65_entity_req.pem -CA mldsa65_root_cert.pem -CAkey mldsa65_root_key.pem -extfile entity.conf -extensions x509v3_extensions -days 1095 -set_serial 31 -out mldsa65_entity_cert.pem

###############################################################################
# Dilithium NIST Level 5
###############################################################################

# Generate root key and entity private keys.
${OPENSSL_EXEC} genpkey -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -algorithm mldsa87 -outform pem -out mldsa87_root_key.pem
${OPENSSL_EXEC} genpkey -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -algorithm mldsa87 -outform pem -out mldsa87_entity_key.pem

# Generate the root certificate
${OPENSSL_EXEC} req -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -x509 -config root.conf -extensions ca_extensions -days 1095 -set_serial 50 -key mldsa87_root_key.pem -out mldsa87_root_cert.pem

# Generate the entity CSR.
${OPENSSL_EXEC} req -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -new -config entity.conf -key mldsa87_entity_key.pem -out mldsa87_entity_req.pem

# Generate the entity X.509 certificate.
${OPENSSL_EXEC} x509 -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -req -in mldsa87_entity_req.pem -CA mldsa87_root_cert.pem -CAkey mldsa87_root_key.pem -extfile entity.conf -extensions x509v3_extensions -days 1095 -set_serial 51 -out mldsa87_entity_cert.pem

###############################################################################
# Verify all generated certificates.
###############################################################################
${OPENSSL_EXEC} verify -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -no-CApath -check_ss_sig -CAfile mldsa44_root_cert.pem mldsa44_entity_cert.pem
${OPENSSL_EXEC} verify -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -no-CApath -check_ss_sig -CAfile mldsa65_root_cert.pem mldsa65_entity_cert.pem
${OPENSSL_EXEC} verify -provider default -provider-path ${PROVIDER_PATH} -provider ${PROVIDER_NAME} -no-CApath -check_ss_sig -CAfile mldsa87_root_cert.pem mldsa87_entity_cert.pem

