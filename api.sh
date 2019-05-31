#!/bin/bash

SERVER="192.168.210.105"
USER="am"
PASS="UlEv@8329"
#TYPE="csv"

echo -en "\e[33;45;1m this script need jq and smbclient installed  \033[0m \n"

#get token and save it to variable
TOKEN=$(curl -s -k -X POST -d '{"username":"'${USER}'","password":"'${PASS}'"}' -c sc_cookie.txt https://${SERVER}/rest/token | jq . | grep token | awk '{print $2}' | sed s/\,// )
#echo "token is ${TOKEN}"

#get scan result ("jq ." - is for human readable format )
#useless
#client need info from other page
#curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/scanResult?fields=name,description,status,finishTime | jq .

# return the greater ID of report from reports list
echo -en "\e[32m search last Weekly_Report_SIEM on ${SERVER} and detect greatest ID \033[0m \n"
G_ID=$(curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report?fields=completed,name | jq '.response.usable' | jq -c '.[] | select(.name | . and contains("Weekly_Report_SIEM"))' | tail -1 | sed 's/[^0-9]*//g' )
#curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report?fields=completed,name | jq '.response.usable' | jq -c '.[] | select(.name | . and contains("Weekly_Report_SIEM"))' | tail -1 | sed 's/[^0-9]*//g'
#curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report | jq '.response.usable' | jq -c '.[] | select(.name | . and contains("Weekly_Report_SIEM"))' 

echo -en "\e[32m greatest ID is ${G_ID}\033[0m \n"

# https://docs.tenable.com/sccv/api/Report.html#ReportRESTReference-/report/{id}/download
# 1 = id of report
#curl -k -X POST -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report/${G_ID}/download > ${G_ID}.${TYPE}
echo -en "\e[32m download Weekly_Report_SIEM.csv\033[0m \n"
curl -k -X POST -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/report/${G_ID}/download > Weekly_Report_SIEM.csv

echo -en "\e[32m put Weekly_Report_SIEM.csv to smb share\033[0m \n"
smbclient -U guest%'' //192.168.0.250/Public -c 'cd Admin ; put Weekly_Report_SIEM.csv'

# https://docs.tenable.com/sccv/api/Report-Definition.html#ReportDefinitionRESTReference-/reportDefinition
# 1 = id of report
# curl -k -X GET -H "X-SecurityCenter: ${TOKEN}"  -H 'Content-Type: application/json' -b sc_cookie.txt https://${SERVER}/rest/reportDefinition?id=${G_ID}
