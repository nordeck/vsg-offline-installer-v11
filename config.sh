# Jitsi domain
export JITSI_FQDN="jitsi.nordeck.corp"

# The password of jibri@auth.$JITSI_FQDN account of Prosody
# https://github.com/nordeck/bullseye-lxc-jitsi/blob/main/machines/nordeck-sip-template/etc/jitsi/jibri/jibri.conf#L57
export JIBRI_PASSWD="my-jibri-password"

# The password of sip@sip.$JITSI_FQDN account of Prosody
# https://github.com/nordeck/bullseye-lxc-jitsi/blob/main/machines/nordeck-sip-template/etc/jitsi/jibri/jibri.conf#L63
export JIBRI_SIP_PASSWD="my-sip-password"

# If this is set as true, builder tools will be removed after building
# v4l2loopback module. Updating kernel may break the system in this case since
# the module will not match the new kernel anymore.
export RUN_REMOVE_BUILDER=false

# Globals
export ARCH=$(dpkg --print-architecture)
export DEBIAN_FRONTEND=noninteractive
export FILES="$BASEDIR/files"
export PACKAGES="$BASEDIR/packages"
export ENV="$BASEDIR/environment"

# ------------------------------------------------------------------------------
# ENVIRONMENT DEPENDENT FILES
# ------------------------------------------------------------------------------
# Update the files which are inside the environment folder according to your
# environment.
#
# - env.sidecar
#
#   Sidecar env file. The default one is OK if you don't have a specific
#   requirement.
#
#
# - sidecar.key and sidecar.pem
#
#   These key pairs should match each other for jitsi-component-selector and
#   jitsi-component-sidecar. Otherwise they cannot communicate.
#   https://github.com/nordeck/bullseye-lxc-jitsi/blob/main/installer-sub-scripts/nordeck-jitsi/311-component-selector.sh#L177-L191
#
#
# - jms-CA.crt
#
#   CA certificate if JMS uses a self-signed certificate
# ------------------------------------------------------------------------------
