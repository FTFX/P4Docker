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


if [ ! -d $P4PROOT ]; then
    print_info "P4P root directory $P4PROOT does not exist, creating..."
    mkdir -p $P4PROOT
fi

if [ ! -d $P4PCACHE ]; then
    print_info "P4P cache directory $P4PCACHE does not exist, creating..."
    mkdir -p $P4PCACHE
fi

if [ ! -d $P4SSLDIR ]; then
    print_info "P4P SSL directory $P4SSLDIR does not exist, creating..."
    mkdir -p $P4SSLDIR
fi

print_info "Making sure the P4SSLDIR has correct permission."
chmod 700 $P4SSLDIR

if [ ! -f $P4SSLDIR/privatekey.txt ]; then
    print_info "SSL certificate does not exist, creating one..."
    p4p -Gc
fi

if [ ! -z "$ALWAYS_TRUST_P4D" ] && [ "$ALWAYS_TRUST_P4D" == "true" ]; then
    print_info "Always trusting p4d, because the ALWAYS_TRUST_P4D environment variable is set to true."
    p4 -p $P4TARGET trust -y
fi

p4p -p $P4PORT -t $P4TARGET -R $P4PROOT -r $P4PCACHE -L $P4LOG -u $SERVICE_USER
