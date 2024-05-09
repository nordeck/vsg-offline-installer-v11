# vsg-offline-installer-v11

SIP-Jibri (aka video-sip-gateway) offline installer for Debian 11 Bullseye.

## Installation

Use a Debian 11 Bullseye box with
[standard packages](https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#priority)
only. It will not work if non-standard packages are installed, such as desktop
environment.

### Update

Update your system and reboot it if there is a new kernel before starting
installation.

```bash
apt-get update
apt-get dist-upgrade

reboot
```

### Download

```bash
VERSION="v20240509"

wget https://github.com/nordeck/vsg-offline-installer-v11/archive/refs/tags/$VERSION.tar.gz
tar zxf $VERSION.tar.gz

cd vsg-offline-installer-v11-$(echo $VERSION | tr -d v)
```

### Configuration

- Update files in [environment](./environment) folder according to your
  environment.

- Update [config.sh](./config.sh) according to your JMS setup.

### Installation

Run [install.sh](./install.sh)

```bash
bash install.sh
```
