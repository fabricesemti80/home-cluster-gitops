#!/usr/bin/env sh

set -o nounset
set -o errexit
ip4=$(curl -s https://ipv4.icanhazip.com/)
record4=$(
    curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$SECRET_CLOUDFLARE_ZONEID/dns_records?name=$SECRET_CLOUDFLARE_RECORD_NAME&type=A" \
        -H "X-Auth-Email: $SECRET_CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $SECRET_CLOUDFLARE_APIKEY" \
        -H "Content-Type: application/json"
)

old_ip4=$(echo "$record4" | sed -n 's/.*"content":"\([^"]*\).*/\1/p')
if [ "$ip4" = "$old_ip4" ]; then
    printf "%s - Success - IP Address '%s' has not changed" "$(date -u)" "$ip4"
    exit 0
fi

record4_identifier=$(echo "$record4" | sed -n 's/.*"id":"\([^"]*\).*/\1/p')
update4=$(
    curl -s -X PUT \
        "https://api.cloudflare.com/client/v4/zones/$SECRET_CLOUDFLARE_ZONEID/dns_records/$record4_identifier" \
        -H "X-Auth-Email: $SECRET_CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $SECRET_CLOUDFLARE_APIKEY" \
        -H "Content-Type: application/json" \
        --data "{\"id\":\"$SECRET_CLOUDFLARE_ZONEID\",\"type\":\"A\",\"proxied\":true,\"name\":\"$SECRET_CLOUDFLARE_RECORD_NAME\",\"content\":\"$ip4\"}"
)

echo "---------------------------------------------------------"
echo "Attempted update parameters:"
echo "---------------------------------------------------------"
echo "X-Auth-Email: $SECRET_CLOUDFLARE_EMAIL"
echo "cloudflare zone ID: $SECRET_CLOUDFLARE_ZONEID"
echo "record:  $SECRET_CLOUDFLARE_RECORD_NAME"
echo "current public IP: $ip4"
echo "---------------------------------------------------------"
echo "Actual result:"
echo "---------------------------------------------------------"
echo "$update4"
echo "---------------------------------------------------------"
echo "---------------------------------------------------------"

if echo "$update4" | grep -q '\"success\":false'; then
    printf "%s - Yikes - Updating IP Address '%s' has failed" "$(date -u)" "$ip4"
    echo "---------------------------------------------------------"
    echo "---------------------------------------------------------"
    exit 1
elif echo "$update4" | grep -q '\"method_not_allowed\"'; then
    printf "%s - Blabla - Updating IP Address '%s' has failed - did you put full FQDN of the record?? (eg. NOT 'foo' BUT 'foo.examle.com'...)" "$(date -u)" "$ip4"
    echo "---------------------------------------------------------"
    echo "---------------------------------------------------------"
    exit 1
else
    printf "%s - Success - IP Address '%s' has been updated" "$(date -u)" "$ip4"
    echo "---------------------------------------------------------"
    echo "---------------------------------------------------------"
    exit 0
fi
