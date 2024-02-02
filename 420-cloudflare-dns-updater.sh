#!/bin/bash

# Configure variables
CDNS_HOSTNAME="${CDNS_HOSTNAME:?Require CDNS_HOSTNAME}"
CDNS_TOKEN="${CDNS_TOKEN:?Require CDNS_TOKEN}"
CDNS_RECORD_ID="${CDNS_RECORD_ID:?Require CDNS_RECORD_ID}"
CDNS_ZONE_ID="${CDNS_ZONE_ID:?Require CDNS_ZONE_ID}"

# Determine if update required
current_ip="$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')"
published_ip="$(dig +short ${CDNS_HOSTNAME} A)"

if [[ "${current_ip}" == "${published_ip}" ]];then
  # no update needed
  exit 0
fi

# Update Cloudflare DNS
update_comment="updated via udm-nat-cloudflare-dns-updater @ $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
update_response=$(
  curl -s -H "Authorization: Bearer ${CDNS_TOKEN}" \
	-XPOST "https://api.cloudflare.com/client/v4/zones/${CDNS_ZONE_ID}/dns_records/${CDNS_RECORD_ID}" \
	-d '{"content":"${current_ip}","name":"${CDNS_HOSTNAME}","type": "A","comment": "${update_comment}","ttl": 60}'
)

if ! echo "${update_response}" | jq -e 'select(.success == true)' >/dev/null 2>&1;then
  echo "ERROR: Received error response from Cloudflare DNS update: ${update_response}" 1>&2
  exit 1
fi
