# ------------------------------------------------------------------------------
# COMPONENT-SIDECAR.SH
# ------------------------------------------------------------------------------
set -e

echo
echo "-------------------- COMPONENT SIDECAR --------------------"

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------
apt-get -y install redis

# nodejs
cp $PACKAGES/nodejs_*.deb /var/cache/apt/archives/
apt-get -y install /var/cache/apt/archives/nodejs_*.deb
apt-mark hold nodejs

# jitsi-component-sidecar
cat <<EOF | debconf-set-selections
jitsi-component-sidecar jitsi-component-sidecar/selector-address string \
$JITSI_FQDN
EOF

cp $PACKAGES/jitsi-component-sidecar.deb /var/cache/apt/archives/
apt-get -y install /var/cache/apt/archives/jitsi-component-sidecar.deb

# ------------------------------------------------------------------------------
# CA certificate (if any)
# ------------------------------------------------------------------------------
if [[ -f $ENV/jms-CA.crt ]]; then
  cp $ENV/jms-CA.crt /usr/local/share/ca-certificates/
  update-ca-certificates
fi

# ------------------------------------------------------------------------------
# COMPONENT-SIDECAR
# ------------------------------------------------------------------------------
cp $ENV/sidecar.key /etc/jitsi/sidecar/asap.key
chmod 600 /etc/jitsi/sidecar/asap.key
cp $ENV/sidecar.pem /etc/jitsi/sidecar/asap.pem
chmod 644 /etc/jitsi/sidecar/asap.pem

cp $ENV/env.sidecar /etc/jitsi/sidecar/env
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/" /etc/jitsi/sidecar/env

chown jitsi-sidecar:jitsi /etc/jitsi/sidecar/*

# ------------------------------------------------------------------------------
# JITSI-COMPONENT-SIDECAR-CONFIG
# ------------------------------------------------------------------------------
cp $FILES/usr/local/sbin/jitsi-component-sidecar-config.vm \
    /usr/local/sbin/jitsi-component-sidecar-config
chmod 744 /usr/local/sbin/jitsi-component-sidecar-config
cp $FILES/etc/systemd/system/jitsi-component-sidecar-config.service \
  /etc/systemd/system/

systemctl daemon-reload
systemctl enable jitsi-component-sidecar-config.service
systemctl restart jitsi-component-sidecar-config.service
systemctl restart jitsi-component-sidecar.service
