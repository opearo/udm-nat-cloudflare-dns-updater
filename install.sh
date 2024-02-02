#!/bin/bash

set -e

SCRIPT_NAME="420-cloudflare-dns-updater.sh"

# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
  DATA_DIR="/mnt/data"
  ;;
2*)
  DATA_DIR="/data"
  ;;
3*)
  DATA_DIR="/data"
  ;;
*)
  echo "ERROR: No persistent storage found." 1>&2
  exit 1
  ;;
esac

echo 'Installing ...'
mkdir -p "${DATA_DIR}/cronjobs"

# install pre-req
(
  cd "${DATA_DIR}/on_boot.d" && \
  curl -s https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/on-boot-script/examples/udm-files/on_boot.d/25-add-cron-jobs.sh -O && \
  chmod +x 25-add-cron-jobs.sh && \
  echo "installed 25-add-cron-jobs.sh"
)

# install script
(
  cd "${DATA_DIR}/on_boot.d" && \
  curl -s "https://raw.githubusercontent.com/opearo/udm-nat-cloudflare-dns-updater/main/${SCRIPT_NAME}" -O && \
  chmod +x "${SCRIPT_NAME}" && \
  echo "installed ${SCRIPT_NAME}"
) 

# read inputs
read -p '-> Enter Cloudflare DNS name: ' dns_name
read -p '-> Enter Cloudflare DNS record id: ' dns_record_id
read -p '-> Enter Cloudflare DNS zone id: ' zone_id
read -sp '-> Enter Cloudflare Bearer token: ' passvar

echo

random_minute=$((${RANDOM} % 60))
cron_schedule="*/${random_minute} */1 * * *"
crontab_file="${DATA_DIR}/cronjobs/${SCRIPT_NAME%???}"

# create crontab file
> "${crontab_file}"
printf 'CDNS_HOSTNAME="%s"\n' "${dns_name}" >> "${crontab_file}"
printf 'CDNS_TOKEN="%s"\n' "${passvar}" >> "${crontab_file}"
printf 'CDNS_RECORD_ID="%s"\n' "${dns_record_id}" >> "${crontab_file}"
printf 'CDNS_ZONE_ID="%s"\n' "${zone_id}" >> "${crontab_file}"
printf '%s root %s\n' "${cron_schedule}" "${DATA_DIR}/on_boot.d/${SCRIPT_NAME}" >> "${crontab_file}"
echo "$(basename ${crontab_file}) crontab file installed"

echo "-> Reboot your UDM to apply changes."
echo "Done."
exit 0
