# ------------------------------------------------------------------------------
# INIT.SH
# ------------------------------------------------------------------------------
set -e

echo
echo "--------------------------- INIT ---------------------------"

[[ -z "$JITSI_FQDN" ]] && echo "JITSI_FQDN not found" && exit 1
[[ -z "$(dig +short $JITSI_FQDN)" ]] && echo "unresolvable JITSI_FQDN" && exit 1
[[ -z "$JIBRI_PASSWD" ]] && echo "JIBRI_PASSWD not found" && exit 1
[[ -z "$JIBRI_SIP_PASSWD" ]] && echo "JIBRI_SIP_PASSWD not found" && exit 1

KERNEL=$(apt-get --simulate dist-upgrade | grep "Inst linux-image-" || true)
if [[ -n "$KERNEL" ]]; then
  cat <<EOF
Your kernel is not up-to-date. Please upgrade the kernel first, reboot with the
new kernel and then try again.

$KERNEL
EOF
  exit 1
fi

# return true if all checks pass
exit 0
