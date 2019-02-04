#!/bin/bash

SERVER="localhost"
USER="apiuser"
PASS="apiuser"
TYPE="pdf"

#get token and save it to variable
TOKEN=$(curl -s -k -X POST -d '{"username":"'${USER}'","password":"'${PASS}'"}' -c sc_cookie.txt https://${SERVER}/rest/token | jq . | grep token | awk '{print $2}' | sed s/\,// )
#echo "token is ${TOKEN}"

#get scan result ("jq ." - is for human readable format )
#useless
#client need info from other page
#curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/scanResult?fields=name,description,status,finishTime | jq .

# return the greater ID of report from reports list
G_ID=$(curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report?fields=completed | jq '.response.usable' | jq 'max_by(.id)' | awk '{print $2}' | sed s/\"//g | tr -d '\n' )

#echo "greatest ID is ${G_ID}"

# https://docs.tenable.com/sccv/api/Report.html#ReportRESTReference-/report/{id}/download
# 1 = id of report
curl -k -X POST -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report/${G_ID}/download > ${G_ID}.${TYPE}

# https://docs.tenable.com/sccv/api/Report-Definition.html#ReportDefinitionRESTReference-/reportDefinition
# 1 = id of report
# curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/reportDefinition?id=${G_ID}
