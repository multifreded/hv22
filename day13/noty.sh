#!/bin/bash

# curl(1) command with cookie handling
curlCmd="curl -b ./cookie -c ./cookie"
gimmiJson='Content-Type: application/json'

serverAddr="f74adf1e-36e0-4db4-b169-19aed2f0ebfe.idocker.vuln.land"
loginUrl="https://$serverAddr/api/login"
noteUrl="https://$serverAddr/api/note"
userUrl="https://$serverAddr/api/user"

# Manual POST
if [ "$1" = "post" ]; then
    $curlCmd -L -X POST https://$serverAddr/$2 -H "$gimmiJson" -d "$3"
    printf '\n'
    exit 0
fi

# Manual GET
$curlCmd -L https://$serverAddr/$1
printf '\n'
