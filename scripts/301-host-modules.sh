# ------------------------------------------------------------------------------
# HOST-MODULES.SH
# ------------------------------------------------------------------------------
set -e

echo
echo "----------------------- HOST MODULES -----------------------"

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------
apt-get update
apt-get -y install uuid-runtime
apt-get -y install kmod alsa-utils
apt-get -y --no-install-recommends install linux-headers-$ARCH build-essential
apt-get -y --no-install-recommends install v4l2loopback-dkms v4l2loopback-utils

# ------------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# ------------------------------------------------------------------------------
# snd_aloop config
cp $FILES/etc/modprobe.d/alsa-loopback.vm.conf /etc/modprobe.d/
[[ -z "$(egrep '^snd_aloop' /etc/modules)" ]] && \
      cat $FILES/etc/modules.custom.alsa >>/etc/modules

# load snd_aloop
rmmod -f snd_aloop 2>/dev/null || true
modprobe snd_aloop || true

# v4l2loopback config
cp $FILES/etc/modprobe.d/v4l2loopback.vm.conf /etc/modprobe.d/
[[ -z "$(egrep '^v4l2loopback' /etc/modules)" ]] && \
      cat $FILES/etc/modules.custom.v4l2 >>/etc/modules

# load v4l2loopback
rmmod -f v4l2loopback 2>/dev/null || true
modprobe v4l2loopback || true

# ------------------------------------------------------------------------------
# CHECKING
# ------------------------------------------------------------------------------
if [[ -z "$(grep snd_aloop /proc/modules)" ]]; then
    cat <<EOF

This kernel ($(uname -r)) does not support snd_aloop module or it is not
up-to-date.

Please install the standard Linux kernel package and reboot with it.
Probably it is "linux-image-$ARCH" for your case.

EOF
    exit 1
fi

if [[ -z "$(grep v4l2loopback /proc/modules)" ]]; then
    cat <<EOF

This kernel ($(uname -r)) does not support v4l2loopback module or it is not
up-to-date.

Please install the standard Linux kernel package and reboot with it.
Probably it is "linux-image-$ARCH" for your case.

EOF
    exit 1
fi
