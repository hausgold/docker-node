FROM node:24
LABEL org.opencontainers.image.authors="containers@hausgold.de"

# You can change this environment variable on run's with -e
ENV MDNS_HOSTNAME=node.local
ENV NODE_OPTIONS="--max_old_space_size=8192"

# Install system packages
RUN apt-get update -yqqq && \
  apt-get install -y \
    dbus avahi-daemon avahi-utils libnss-mdns haproxy supervisor

# Copy custom scripts
COPY config/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Configure haproxy
COPY config/haproxy.conf /etc/haproxy/haproxy.cfg

# Configure supervisord
COPY config/supervisor/* /etc/supervisor/conf.d/
RUN mkdir -p /var/log/supervisor

# Define the command to run per default
CMD ["/usr/bin/supervisord", "-nc", "/etc/supervisor/supervisord.conf"]
