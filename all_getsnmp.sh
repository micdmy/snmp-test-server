#!/bin/bash

# This is a script to run on client (it may be your host machine).
# You may use it to test if server works.
# This script makes snmp get requests to server using snmp v3.
# It makes 31 requests with different Auth / Priv Types.
# It uses Username / Auth / Priv values 
# as they are defined in 'snmpd.conf'. (They follow the patteern).
# If you change snmpd.conf, you must adapt this script.

# Requires snmpget installed (Usually in 'net-snmp' package).

# Usage: ./all_getsnmp.sh <server_ip>
# Example: ./all_getsnmp.sh 192.168.200.1

SERVER_IP="$1"
REQUESTED_OID="sysDescr.0"

if [ -z "$SERVER_IP" ]; then
  echo "Usage: $0 <server_ip>"
  exit 1
fi

# Auth types with correct case for snmpget
AUTH_TYPES=("Md5" "Sha1" "Sha224" "Sha256" "Sha384" "Sha512")

# Priv types with correct case for snmpget
PRIV_TYPES=("Des" "AES128" "AES192" "AES256")

# --- AuthPriv combinations ---
for AUTH in "${AUTH_TYPES[@]}"; do
  for PRIV in "${PRIV_TYPES[@]}"; do
  
    # Username pattern: lowercase auth + lowercase priv
    USERNAME="$(echo "${AUTH,,}${PRIV,,}")"

    # Lowercase versions for password derivation
    AUTH_LOWER="$(echo "$AUTH" | tr '[:upper:]' '[:lower:]')"
    PRIV_LOWER="$(echo "$PRIV" | tr '[:upper:]' '[:lower:]')"

    A_PASSWD="authpass${AUTH_LOWER}${PRIV_LOWER}"
    P_PASSWD="privpass${AUTH_LOWER}${PRIV_LOWER}"

    echo "Testing Auth=${AUTH}, Priv=${PRIV}, User=${USERNAME}", APass=${A_PASSWD}, PPass=${P_PASSWD}
    #set -x
    snmpget \
      -v 3 \
      -l authPriv \
      -u "$USERNAME" \
      -a "$AUTH" \
      -A "${A_PASSWD}" \
      -x "$PRIV" \
      -X "${P_PASSWD}" \
      "$SERVER_IP" \
      ${REQUESTED_OID} \
      > /dev/null
    #set +x
  done
done

# --- AuthNoPriv combinations ---
for AUTH in "${AUTH_TYPES[@]}"; do
  USERNAME="$(echo "${AUTH,,}")nopriv"
  AUTH_LOWER="$(echo "$AUTH" | tr '[:upper:]' '[:lower:]')"
  A_PASSWD="authpass${AUTH_LOWER}nopriv"

  echo "Testing Auth=${AUTH}, NoPriv, User=${USERNAME}, Apass=${A_PASSWD}"

  snmpget \
    -v 3 \
    -l authNoPriv \
    -u "$USERNAME" \
    -a "$AUTH" \
    -A ${A_PASSWD} \
    "$SERVER_IP" \
    ${REQUESTED_OID} \
    > /dev/null
done

# --- NoAuthNoPriv ---
echo "Testing NoAuthNoPriv user"
snmpget \
  -v 3 \
  -l noAuthNoPriv \
  -u "noauthnopriv" \
  "$SERVER_IP" \
  ${REQUESTED_OID} \
  > /dev/null
