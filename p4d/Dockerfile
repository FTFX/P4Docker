FROM ubuntu:focal

# Perforce Helix Core Server version
ARG MAJOR_VERSION=2021
ARG MINOR_VERSION=2
ARG PATCH_VERSION=2220431

# Environment variables
ENV P4PORT=ssl:1666
ENV P4ROOT=/srv/p4d
ENV P4LOG=/srv/p4d/logs/log
ENV SUPER_USER=super
ENV SUPER_PASSWD=helix123456
ENV ENABLE_UNICODE=1
ENV SERVICE_NAME=helix
ENV CASE_SENSITIVE=1

# Install packages
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - && \
    echo 'deb http://package.perforce.com/apt/ubuntu focal release' > /etc/apt/sources.list.d/perforce.list && \
    apt-get update && \
    apt-get install -y helix-p4d=${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}~focal && \
    echo "${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}" > /var/run/P4D.VERSION && \
    apt-get remove -y wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the script and allow it to run
COPY ./start.sh /
RUN chmod +x /start.sh

# Run the script to upgrade (if needed) and start p4d service
CMD ["bash", "/start.sh"]
