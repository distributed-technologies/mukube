WORKING_DIR=$1
TEMPLATES_DIR=$2

OUTPUT_DIR=$WORKING_DIR/etc/systemd/network

mkdir -p $OUTPUT_DIR

eval "cat <<EOF
$(<$TEMPLATES_DIR/10-systemd-network.network )
EOF
" > $OUTPUT_DIR/10-systemd-network.network

# Configure the DNS by creating the resolved.conf 
if [[ $CONFIGURE_DNS = "true" ]]
then
    if [ -z "$CLUSTER_DNS" ]
    then
        echo "[error] CLUSTER_DNS is required when CONFIGURE_DNS is true"
        exit 1
    fi
    eval "cat <<EOF
$(<$TEMPLATES_DIR/resolved.conf)
EOF
" > $WORKING_DIR/etc/systemd/resolved.conf
fi
