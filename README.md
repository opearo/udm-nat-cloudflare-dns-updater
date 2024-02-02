# udm-nat-google-dyndns-updater
Update your Cloudflare DNS record with the Cloudflare API (even behind NAT)


## Changelog

- 2024-02-02 - added scripts

## Pre-requisites

This installation requires [UDM / UDMPro Boot Script](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

## Compatibility

- Tested on [UDM PRO](https://store.ui.com/us/en/pro/category/all-unifi-gateway-consoles/products/udm-pro)

## Installation

SSH into the UDM/Pro/SE and run:

```shell
/bin/bash <(curl -s https://raw.githubusercontent.com/opearo/udm-nat-cloudflare-dns-updater/main/install.sh)
```

During installation you'll be prompted for:
- Cloudflare DNS name: the dns name of the zone you want to update
- Cloudflare DNS record id: the DNS record id you want to update
- Cloudflare DNS zone id: the id of the zone the record belongs to
- Cloudflare API Bearer token
