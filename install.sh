#!/usr/bin/bash
set -e

export BASEDIR=$(pwd)
export START_TIME=$(date +%s)
source "$BASEDIR/config.sh"

# ------------------------------------------------------------------------------
# trap on exit
# ------------------------------------------------------------------------------
function on_exit {
if [[ "$COMPLETED" != true ]]; then
  echo -e "\nSomething went wrong. The installation couldn't be completed!"
  exit 1
fi

echo -e "\nCompleted successfully"
echo Installation Duration: $DURATION
exit 0
}

COMPLETED=false
trap on_exit EXIT

# ------------------------------------------------------------------------------
# BASE PACKAGES
# ------------------------------------------------------------------------------
apt-get update
apt-get -y install wget bind9-dnsutils procps

# ------------------------------------------------------------------------------
# SUBSCRIPTS
# ------------------------------------------------------------------------------
cd "$BASEDIR/scripts"

for sub in $(ls *.sh); do
  bash $sub
done

# ------------------------------------------------------------------------------
# INSTALLATION DURATION
# ------------------------------------------------------------------------------
END_TIME=$(date +%s)
DURATION=$(date -u -d "0 $END_TIME seconds - $START_TIME seconds" +"%H:%M:%S")
COMPLETED=true
