# ------------------------------------------------------------------------------
# SCALE-DOWN.SH
# ------------------------------------------------------------------------------
set -e

echo
echo "------------------------ SCALE DOWN ------------------------"

# scale-down script
cp $FILES/usr/local/bin/scale-down /usr/local/bin/
chmod 755 /usr/local/bin/scale-down

sed -i "s~^SCALER_URL=.*~SCALER_URL=\"https://$JITSI_FQDN/scaler\"~" \
  /usr/local/bin/scale-down

# scale-down systemd unit
cp $FILES/etc/systemd/system/scale-down.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable scale-down.service
systemctl start scale-down.service
