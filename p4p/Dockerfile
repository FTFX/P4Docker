FROM ubuntu:focal

# Perforce Helix Core Server version
ARG MAJOR_VERSION=2021
ARG MINOR_VERSION=2
ARG PATCH_VERSION=2220431

# Environment variables
ENV P4PORT=ssl:1666
ENV P4TARGET=ssl:perforce:1666
ENV P4PCACHE=/srv/p4p/cache/
ENV P4PROOT=/srv/p4p/root/
ENV P4LOG=/srv/p4p/logs/log
ENV P4SSLDIR=/srv/p4p/ssl/
ENV SERVICE_USER=proxy

# Install packages
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - && \
    echo 'deb http://package.perforce.com/apt/ubuntu focal release' > /etc/apt/sources.list.d/perforce.list && \
    apt-get update && \
    apt-get install -y helix-proxy=${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}~focal helix-cli && \
    echo "${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}" > /var/run/P4P.VERSION && \
    apt-get remove -y wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the script and allow it to run
COPY ./start.sh /
RUN chmod +x /start.sh

# Run the script to upgrade (if needed) and start p4d service
CMD ["bash", "/start.sh"]
