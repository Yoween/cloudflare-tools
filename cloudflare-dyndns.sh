#!/bin/bash

#####################################
#      Cloudflare DynDNS Tool       #
#===================================#
# This tool automatically updates   #
# the DNS A record for a subdomain  #
# in a Cloudflare account to the    #
# current IP address of the         #
# computer. Run this on your home   #
# network on a schedule and your    #
# home DNS entry will always be     #
# up to date.                       #
#####################################

set -e

DOMAIN="example.org"
EMAIL="cloudflare.user@email.com"
API_KEY="your-global-api-key"
API_TOKEN="your-api-token"  # replace with your actual API token

# Choose authentication method: 'global_key' or 'token'
auth_method="token"  # change to 'global_key' to use global API key

if [ "$auth_method" = "global_key" ]; then
    AUTH_HEADER="X-Auth-Email: $EMAIL, X-Auth-Key: $API_KEY"
elif [ "$auth_method" = "token" ]; then
    AUTH_HEADER="Authorization: Bearer $API_TOKEN"
fi

get_new_ip() {
    curl -s https://icanhazip.com
}

get_zone_id() {
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=active&page=1&per_page=20&order=status&direction=desc&match=all" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" | jq -r '.result[0].id'
}

get_dns_records() {
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&page=1&per_page=20&order=type&direction=desc&match=all" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" | jq -r '.result[].name'
}

update_dns() {
    local DOMAIN_NAME=$1
    local DNS_RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN_NAME&page=1&per_page=20&order=type&direction=desc&match=all" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" | jq -r '.result[0]')
    local DNS_ID=$(echo $DNS_RECORD | jq -r '.id')
    local OLD_IP=$(echo $DNS_RECORD | jq -r '.content')

    if [ "$NEW_IP" != "$OLD_IP" ]; then
        echo "Old IP: $OLD_IP"
        echo "New IP: $NEW_IP"

        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_ID" \
        -H "Content-Type: application/json" \
        -H "$AUTH_HEADER" \
        -d "{\"type\":\"A\",\"name\":\"$DOMAIN_NAME\",\"content\":\"$NEW_IP\",\"proxied\":true}" | jq -r '.success'
    else
        echo "Same IP for $DOMAIN_NAME: $NEW_IP"
    fi
}

NEW_IP=$(get_new_ip)
ZONE_ID=$(get_zone_id)

DNS_RECORDS=$(get_dns_records)

for record in $DNS_RECORDS; do
    update_dns $record
done