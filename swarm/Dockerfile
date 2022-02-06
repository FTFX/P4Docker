FROM ubuntu:focal

# Perforce Helix Core Server version
ARG MAJOR_VERSION=2021
ARG MINOR_VERSION=2
ARG PATCH_VERSION=2218684

# Environment variables
ENV P4PORT=ssl:1666
ENV SWARM_P4USERNAME=swarm
ENV SWARM_P4USERPASSWORD=password
ENV SWARM_HOSTNAME=www.swarm.internaldomain
ENV SWARM_EMAILHOST=mx.yourdomain.com
ENV SWARM_PORT=80
ENV ALWAYS_TRUST_P4D=false

# For Azure deployment
RUN mkdir -p /home/Data/swarm && \
    mkdir -p /opt/perforce/swarm && \
    ln -s /home/Data/swarm /opt/perforce/swarm/data

# Install packages
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - && \
    echo 'deb http://package.perforce.com/apt/ubuntu focal release' > /etc/apt/sources.list.d/perforce.list && \
    apt-get update && \
    apt-get install -y zip && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y tzdata && \
    apt-get install -y helix-swarm=${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}~focal && \
    apt-get install -y helix-swarm-optional=${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}~focal && \
    echo "${MAJOR_VERSION}.${MINOR_VERSION}-${PATCH_VERSION}" > /var/run/P4S.VERSION && \
    apt-get remove -y wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the script and allow it to run
COPY ./start.sh /
RUN chmod +x /start.sh

# Run the script to upgrade (if needed) and start p4d service
CMD ["bash", "/start.sh"]
