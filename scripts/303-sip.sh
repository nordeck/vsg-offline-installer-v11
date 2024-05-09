# ------------------------------------------------------------------------------
# SIP.SH
# ------------------------------------------------------------------------------
set -e

echo
echo "--------------------------- SIP --------------------------"

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------
apt-get -y install curl jq
apt-get -y install gnupg unzip unclutter
apt-get -y install libnss3-tools
apt-get -y install va-driver-all vdpau-driver-all
apt-get -y install openjdk-11-jre-headless
apt-get -y --install-recommends install ffmpeg
apt-get -y install x11vnc
apt-get -y install sudo
apt-get -y install chromium chromium-driver chromium-sandbox

# pjsua related
apt-get -y install libv4l-0

# jibri
cp $PACKAGES/jibri_*.deb /var/cache/apt/archives/
apt-get -y install /var/cache/apt/archives/jibri_*.deb
apt-mark hold jibri

# removed packages
apt-get -y purge upower

# ------------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# ------------------------------------------------------------------------------
# chromium managed policies
mkdir -p /etc/chromium/policies/managed
cp $FILES/etc/chromium/policies/managed/*.json /etc/chromium/policies/managed/

# sudo
cp $FILES/etc/sudoers.d/jibri.vm /etc/sudoers.d/jibri
chmod 440 /etc/sudoers.d/jibri

# ------------------------------------------------------------------------------
# JIBRI
# ------------------------------------------------------------------------------
cp /etc/jitsi/jibri/xorg-video-dummy.conf \
    /etc/jitsi/jibri/xorg-video-dummy.conf.org
cp /etc/jitsi/jibri/pjsua.config /etc/jitsi/jibri/pjsua.config.org
cp /opt/jitsi/jibri/pjsua.sh /opt/jitsi/jibri/pjsua.sh.org
cp /opt/jitsi/jibri/finalize_sip.sh /opt/jitsi/jibri/finalize_sip.sh.org
cp /home/jibri/.asoundrc /home/jibri/.asoundrc.org

# resolution 1280x720
sed -ri 's/^(\s*)Modes "1920/\1#Modes "1920/' \
    /etc/jitsi/jibri/xorg-video-dummy.conf
sed -ri 's/^(\s*)#Modes "1280/\1Modes "1280/' \
    /etc/jitsi/jibri/xorg-video-dummy.conf

# xorg DISPLAY :1
cp $FILES/etc/systemd/system/sip-xorg.service \
  /etc/systemd/system/sip-xorg.service
systemctl daemon-reload
systemctl enable sip-xorg.service

# icewm DISPLAY :1
cp $FILES/etc/systemd/system/sip-icewm.service \
  /etc/systemd/system/sip-icewm.service
systemctl daemon-reload
systemctl enable sip-icewm.service

# jibri groups
chsh -s /usr/bin/bash jibri
usermod -aG adm,audio,video,plugdev jibri
chown jibri:jibri /home/jibri

# jibri, icewm
mkdir -p /home/jibri/.icewm
cp $FILES/home/jibri/.icewm/theme /home/jibri/.icewm/
cp $FILES/home/jibri/.icewm/prefoverride /home/jibri/.icewm/
cp $FILES/home/jibri/.icewm/ringing.png /home/jibri/.icewm/
cp $FILES/home/jibri/.icewm/startup /home/jibri/.icewm/
chmod 755 /home/jibri/.icewm/startup

# jibri config
cp $FILES/etc/jitsi/jibri/jibri.conf /etc/jitsi/jibri/
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/" /etc/jitsi/jibri/jibri.conf
sed -i "s/___JIBRI_PASSWD___/$JIBRI_PASSWD/" /etc/jitsi/jibri/jibri.conf
sed -i "s/___JIBRI_SIP_PASSWD___/$JIBRI_SIP_PASSWD/" /etc/jitsi/jibri/jibri.conf

# asoundrc
cp $FILES/home/jibri/.asoundrc /home/jibri/

# sip ephemeral config service
cp $FILES/usr/local/sbin/sip-ephemeral-config.vm \
  /usr/local/sbin/sip-ephemeral-config
chmod 744 /usr/local/sbin/sip-ephemeral-config
cp $FILES/etc/systemd/system/sip-ephemeral-config.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable sip-ephemeral-config.service

# jibri service
sed -i '/google-chrome/d' /etc/systemd/system/jibri.service
systemctl enable jibri.service
systemctl start jibri.service

# jibri, vnc
# vnc is not enabled by default. it is needed while testing.
mkdir -p /home/jibri/.vnc
x11vnc -storepasswd jibri /home/jibri/.vnc/passwd
chown jibri:jibri /home/jibri/.vnc -R

# jibri, Xdefaults
cp $FILES/home/jibri/.Xdefaults /home/jibri/
chown jibri:jibri /home/jibri/.Xdefaults

# ------------------------------------------------------------------------------
# VIRTUAL CAMERAS
# ------------------------------------------------------------------------------
cp $FILES/etc/systemd/system/virtual-camera-0.service.vm \
    /etc/systemd/system/virtual-camera-0.service
cp $FILES/etc/systemd/system/virtual-camera-1.service.vm \
    /etc/systemd/system/virtual-camera-1.service
systemctl daemon-reload

# ------------------------------------------------------------------------------
# PJSUA
# ------------------------------------------------------------------------------
cp $PACKAGES/pjsua_* /usr/local/bin/pjsua
chmod 755 /usr/local/bin/pjsua

# pjsua config
cp $FILES/etc/jitsi/jibri/pjsua.config.vm /etc/jitsi/jibri/pjsua.config

# pjsua scripts
cp $FILES/opt/jitsi/jibri/pjsua.sh /opt/jitsi/jibri/pjsua.sh
cp $FILES/opt/jitsi/jibri/finalize_sip.sh.vm /opt/jitsi/jibri/finalize_sip.sh

# fake chromedriver
cp $FILES/usr/local/bin/chromedriver /usr/local/bin/
chmod 755 /usr/local/bin/chromedriver

# the capture device for chromium
cp $FILES/etc/chromium.d/alsa-capture /etc/chromium.d/

# ------------------------------------------------------------------------------
# SERVICES
# ------------------------------------------------------------------------------
systemctl stop sip-xorg.service
systemctl stop jibri-xorg.service

find /var/log/jitsi -type f -delete
rm -rf /home/jibri/.config/chromium

systemctl start sip-ephemeral-config.service
systemctl start jibri.service
