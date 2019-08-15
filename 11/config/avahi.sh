#!/bin/bash

# After nss-mdns >0.10 we need to reconfigure the allowed hosts to support
# multiple sub-domain resolution
cat > /etc/mdns.allow <<EOF
.local.
.local
EOF

# Configure the mDNS hostname on avahi
if [ -n "${MDNS_HOSTNAME}" ]; then

  # MDNS_HOSTNAME could be elasticsearch.local or elasticsearch.sub.local
  IFS='.' read -ra MDNS_HOSTNAME_PARTS <<< "${MDNS_HOSTNAME}"

  # Save the first part as host part
  HOST_PART="${MDNS_HOSTNAME_PARTS[0]}"

  # Shift the first part
  MDNS_HOSTNAME_PARTS=("${MDNS_HOSTNAME_PARTS[@]:1}")

  # Join the rest to the domain part
  DOMAIN_PART=$(IFS='.'; echo "${MDNS_HOSTNAME_PARTS[*]}")

  # Set the host and domain part on the avahi config
  sed \
    -e "s/.*\(host-name=\).*/\1${HOST_PART}/g" \
    -e "s/.*\(domain-name=\).*/\1${DOMAIN_PART}/g" \
    -i /etc/avahi/avahi-daemon.conf

  echo "Configured mDNS hostname to ${MDNS_HOSTNAME}"
fi

# Configure all mDNS CNAMEs on avahi
if [ -n "${MDNS_CNAMES}" ]; then

  # MDNS_CNAMES could be a single domain, or a comma-separated list
  IFS=',' read -ra CNAMES <<< "${MDNS_CNAMES}"

  for CNAME in "${CNAMES[@]}"; do
    # Construct the command
    COMMAND='/usr/bin/avahi-publish -f -a -R'
    COMMAND+=" \"${CNAME}\" \`hostname -i\`"

    # Write a new supervisord unit file
    cat > "/etc/supervisor/conf.d/${CNAME}.conf" <<EOF
[program:${CNAME}]
priority=20
directory=/tmp
command=/bin/sh -c '${COMMAND}'
user=root
autostart=false
autorestart=true
stopsignal=KILL
stopwaitsecs=1
EOF

    # Reload the supervisord config files and start
    # the current publish service
    supervisorctl update
    supervisorctl start "${CNAME}"
  done
fi

# Disable the rlimits from default debian
sed \
  -e 's/^\(rlimit\)/#\1/g' \
  -i /etc/avahi/avahi-daemon.conf

# If a avahi daemon is running, kill it
avahi-daemon -c && avahi-daemon -k

# Clean up orphans
rm -rf /run/avahi-daemon/{pid,socket}

# Start avahi
exec avahi-daemon --no-rlimits
