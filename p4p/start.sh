#/bin/bash

if [ ! -d $P4PROOT ]; then
    echo "P4P root directory $P4PROOT does not exist, creating..."
    mkdir -p $P4PROOT
fi

if [ ! -d $P4PCACHE ]; then
    echo "P4P cache directory $P4PCACHE does not exist, creating..."
    mkdir -p $P4PCACHE
fi

if [ ! -d $P4SSLDIR ]; then
    echo "P4P SSL directory $P4SSLDIR does not exist, creating..."
    mkdir -p $P4SSLDIR
fi

echo "Making sure the P4SSLDIR has correct permission."
chmod 700 $P4SSLDIR

if [ ! -f $P4SSLDIR/privatekey.txt ]; then
    print_info "SSL certificate does not exist, creating one..."
    p4p -Gc
fi

p4p -p $P4PORT -t $P4TARGET -R $P4PROOT -r $P4PCACHE -L $P4LOG -u $SERVICE_USER
