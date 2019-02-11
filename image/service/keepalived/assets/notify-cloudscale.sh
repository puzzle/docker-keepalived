#!/bin/bash

# for ANY state transition.
# "notify" script is called AFTER the
# notify_* script(s) and is executed
# with 3 arguments provided by keepalived
# (ie don't include parameters in the notify line).
# arguments
# $1 = "GROUP"|"INSTANCE"
# $2 = name of group or instance
# $3 = target state of transition
#     ("MASTER"|"BACKUP"|"FAULT")

TYPE=$1
NAME=$2
STATE=$3

SERVERNAME="$(hostname)"

for info in $(complex-bash-env iterate "$SERVER_IDS")
do

        if [ $(complex-bash-env isRow "${!info}") = true ]; then

                key=$(complex-bash-env getRowKeyVarName "${!info}")
                value=$(complex-bash-env getRowValueVarName "${!info}")

		            currentserver=${!key}
                if [ "$currentserver" == "$SERVERNAME" ]; then
                        SERVER_ID=${!value}
                fi

        fi
done

echo "I'm $SERVERNAME, with ID: $SERVER_ID" > /proc/1/fd/1

case $STATE in
        "MASTER") echo "I'm the MASTER! Whup whup." > /proc/1/fd/1

                  for vip in $(complex-bash-env iterate KEEPALIVED_VIRTUAL_IPS)
                  do
                    VIRTUAL_IP=${!vip}
                    echo "Update $SERVER_ID with IP ${VIRTUAL_IP}" > /proc/1/fd/1
                    curl -H "Authorization: Bearer $API_TOKEN" -F server=$SERVER_ID https://api.cloudscale.ch/v1/floating-ips/{$VIRTUAL_IP} > /proc/1/fd/1
                  done

                  exit 0
                  ;;
        "BACKUP") echo "Ok, i'm just a backup, great." > /proc/1/fd/1
                  exit 0
                  ;;
        "FAULT")  echo "Fault, what ?" > /proc/1/fd/1
                  exit 0
                  ;;
        *)        echo "Unknown state" > /proc/1/fd/1
                  exit 1
                  ;;
esac
