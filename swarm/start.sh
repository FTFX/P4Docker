#/bin/bash

###############################################################################
# Print functions                                                             #
###############################################################################
print_error() {
    echo "[Error] $1"
}

print_warning() {
    echo "[Warning] $1"
}

print_info() {
    echo "[Info] $1"
}

watch_logs() {
    tail -f $p4_log
}
###############################################################################


# Configure Swarm if this is the first time running
if [ ! -f /opt/perforce/swarm/data/config.php ]; then
    print_info "Swarm have not been configure, configuring now..."
    /opt/perforce/swarm/sbin/configure-swarm.sh -p $P4PORT -P $SWARM_PORT -u $SWARM_P4USERNAME -w $SWARM_P4USERPASSWORD -e $SWARM_EMAILHOST -H $SWARM_HOSTNAME
fi

# Always trust P4D
if [ ! -z "$ALWAYS_TRUST_P4D" ] && [ "$ALWAYS_TRUST_P4D" == "true" ]; then
    print_info "Always trusting p4d, because the ALWAYS_TRUST_P4D environment variable is set to true."
    /opt/perforce/swarm/data/p4trust
fi

# Start Swarm
print_info "Starting Swarm..."
service apache2 start
print_info "Swarm started, only error message will be output."
tail -f /var/log/apache2/swarm.error_log
