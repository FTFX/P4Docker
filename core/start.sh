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


###############################################################################
# Start and Stop p4d functions                                                #
###############################################################################
start_p4d() {
    print_info "Starting p4d..."
    p4dctl start -a
}

stop_p4d() {
    print_info "Stopping p4d..."
    p4dctl stop -a
}
trap "stop_p4d" SIGINT SIGTERM
###############################################################################


###############################################################################
# Initialize and upgrade p4 database related functions                        #
###############################################################################
create_version_indicator_file() {
    su - perforce -c "echo $p4_program_version > $p4_root/VERSION"
}

upgrade_p4_database() {
    print_info "Upgrading Perforce Helix Core Database..."
    p4dctl exec -t p4d $p4_service_name -- -xu
    create_version_indicator_file
}

initialize_p4() {
    print_info "So here are the parameters we are about to use to init p4:"
    print_info "SERVICE_NAME: $p4_service_name"
    print_info "P4ROOT: $p4_root"
    print_info "P4PORT: $p4_port"
    print_info "SUPER_USER: $p4_superuser_name"
    print_info "SUPER_PASSWD: $p4_superuser_passwd"
    print_info "ENABLE_UNICODE: $p4_enable_unicode"
    print_info "CASE_SENSITIVE: $p4_case_sensitive"
    print_info "Initializing Perforce Service..."
    if [ -z "$p4_enable_unicode" ] || [ "$p4_enable_unicode" -eq 0 ]; then
        parameter_unicode=""
    else
        parameter_unicode="--unicode"
    fi
    if [ -z "$p4_case_sensitive" ] || [ "$p4_case_sensitive" -eq 0 ]; then
        parameter_case_sensitive="--case=n"
    else
        parameter_case_sensitive="--case=y"
    fi
    /opt/perforce/sbin/configure-helix-p4d.sh $p4_service_name -n -p $p4_port -r $p4_root -u $p4_superuser_name -P $p4_superuser_passwd $parameter_unicode $parameter_case_sensitive
}
###############################################################################


###############################################################################
# Initialize the script                                                       #
###############################################################################
# Prepare and get the parameters from environment variables
if [ -z "$P4PORT" ]; then
    print_error "P4PORT is not set."
    exit 1
else
    p4_port=$P4PORT
fi

if [ -z "$P4ROOT" ]; then
    print_error "P4ROOT is not set."
    exit 1
else
    p4_root=$P4ROOT
fi

if [ -z "$P4LOG" ]; then
    print_warning "P4LOG is not set, using default log path $p4_root/logs/log, this might not what you want."
    p4_log=$p4_root/logs/log
else
    p4_log=$P4LOG
fi

if [ -z "$SUPER_USER" ]; then
    print_error "SUPER_USER is not set."
    exit 1
else
    p4_superuser_name=$SUPER_USER
fi

if [ -z "$SUPER_PASSWD" ]; then
    print_error "SUPER_PASSWD is not set."
    exit 1
else
    p4_superuser_passwd=$SUPER_PASSWD
fi

if [ -z "$SERVICE_NAME" ]; then
    print_error "SERVICE_NAME is not set."
    exit 1
else
    p4_service_name=$SERVICE_NAME
fi

if [ -z "$ENABLE_UNICODE" ] || [ "$ENABLE_UNICODE" = "0" ]; then
    p4_enable_unicode=0
else
    p4_enable_unicode=1
fi

if [ -z "$CASE_SENSITIVE" ] || [ "$CASE_SENSITIVE" = "0" ]; then
    p4_case_sensitive=0
else
    p4_case_sensitive=1
fi

#==============================================================================
# Prepare and get the parameters from version files
# Get Perforce Helix Core program version
if [ ! -f /var/run/P4D.VERSION ]; then
    print_error "/var/run/P4D.VERSION is missing, this should not happen."
    print_error "| This file should be generated during docker build."
    print_error "| The file content is defined in the dockerfile,"
    print_error "| you can check the dockerfile to see why this file was not generated."
    exit 1
else
    p4_program_version=$(cat /var/run/P4D.VERSION)
fi

#------------------------------------------------------------------------------
# The following is trying to get the p4 database version
# First, check if P4ROOT exists, if not, create it.
if [ ! -f $p4_root ]; then
    print_info "The directory $p4_root does not exist, creating $p4_root..."
    mkdir -p $p4_root
fi
# And always make sure P4ROOT has correct ownership and permission.
# Because user might mount a volume to P4ROOT, and if P4ROOT does not exist,
# docker will automatically create P4ROOT directory with root:root ownership when the container is initializing.
# So we always change the ownership to perforce:perforce.
chown perforce:perforce $p4_root
chmod 700 $p4_root

# Initialize the p4 service if P4ROOT is empty.
if [ -z "$(ls -A $p4_root)" ]; then
    print_info "P4ROOT is empty, creating p4 service..."
    initialize_p4
fi

# Then we try to get the p4 database version.
if [ ! -f $p4_root/VERSION ]; then
    print_info "Version indicator file not found, creating one..."
    create_version_indicator_file
fi
p4_data_version=$(cat $p4_root/VERSION)
###############################################################################


###############################################################################
# main()                                                                      #
###############################################################################
# Begine to compare the program version and data version, and upgrade the database if needed.
## Start to compare if it already exists.
p4_program_version_major=$(echo $p4_program_version | sed -E 's/([0-9]+)\.([0-9]+)-([0-9]+)/\1/')
p4_program_version_minor=$(echo $p4_program_version | sed -E 's/([0-9]+)\.([0-9]+)-([0-9]+)/\2/')
p4_program_version_patch=$(echo $p4_program_version | sed -E 's/([0-9]+)\.([0-9]+)-([0-9]+)/\3/')
print_info "Program major version = $p4_program_version_major"
print_info "Program minor version = $p4_program_version_minor"
print_info "Program patch version = $p4_program_version_patch"
print_info "Program version = $p4_program_version"

p4_data_version_major=$(echo $p4_data_version | sed -E 's/([0-9]+)\.([0-9]+)-([0-9]+)/\1/')
p4_data_version_minor=$(echo $p4_data_version | sed -E 's/([0-9]+)\.([0-9]+)-([0-9]+)/\2/')
p4_data_version_patch=$(echo $p4_data_version | sed -E 's/([0-9]+)\.([0-9]+)-([0-9]+)/\3/')
print_info "Data major version = $p4_data_version_major"
print_info "Data minor version = $p4_data_version_minor"
print_info "Data patch version = $p4_data_version_patch"
print_info "Data version = $p4_data_version"

if [ $p4_program_version_major -gt $p4_data_version_major ] || [ $p4_program_version_minor -gt $p4_data_version_minor ]; then
    print_info "Program version is higher than data version, upgrading..."
    upgrade_p4_database
elif [ $p4_program_version_major -lt $p4_data_version_major ] || [ $p4_program_version_minor -lt $p4_data_version_minor ]; then
    print_error "Data version is higher than program version, panic."
    exit 1
fi

start_p4d
watch_logs
###############################################################################
