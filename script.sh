#!/usr/bin/env bash

read -e -p $'\033[1;2;26;26;26mTarget:\033[0m ' target

read -e -p $'\033[1;2;26;26;26mVirustotal API:\033[0m ' VT

read -e -p $'\033[1;2;26;26;26mOTX API:\033[0m ' OTX

filename="${target//./}"

curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$VT&domain=$target" |
jq -r '.resolutions[]?.ip_address // empty' |
sort -u >> ip_$filename.txt

curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$VT&domain=$target" |
jq -r '.subdomains[]? // empty' |
sort -u >> sub_domain_$filename.txt

curl -s "https://urlscan.io/api/v1/search/" \
--data-urlencode "q=domain:$target" \
--data-urlencode "size=1000" |
jq -r '.results[]?.page?.ip // empty' |
sort -u >> ip_$filename.txt

curl -s \
-H "X-OTX-API-KEY: $OTX" \
"https://otx.alienvault.com/api/v1/indicators/hostname/$target/url_list?limit=500&page=1" |
jq -r '.url_list[]?.url // empty' >> url_$filename.txt

echo -e "\nIPs:"
cat ip_$filename.txt | while s= read -r line; do
    echo -e "\033[1;2;0;130;121m${line}\033[0m"
done

echo -e "\nSubdomains:"

cat sub_domain_$filename.txt | while s= read -r line; do
    echo -e "\033[1;2;0;69;94m${line}\033[0m"
done

echo -e "\nURLs:"

cat url_$filename.txt | while s= read -r line; do
    echo -e "\033[1;38;2;135;0;0m${line}\033[0m"
done