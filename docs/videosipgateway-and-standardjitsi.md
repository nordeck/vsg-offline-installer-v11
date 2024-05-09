# Integrating a standard JMS and video-sip-gateway

This guide contains the customizations to allow `video-sip-gateway` works with a
standard JMS setup.

Assumed that:

- JMS uses the `token` authentication
- `allow_empty_token = false` in `prosody` (_this is the default value_)
- `jitsi-component-selector` is already installed on JMS
- `video-sip-gateway` is installed using the offline installer

## sidecar keys

The public and private keys should match on both sides. Copy keys created while
installing `jitsi-component-selector` to `video-sip-gateway`

```bash
cp /tmp/sidecar.key /etc/jitsi/sidecar/asap.key
cp /tmp/sidecar.pem /etc/jitsi/sidecar/asap.pem
chown jitsi-sidecar:jitsi /etc/jitsi/sidecar/asap{.key,.pem}
chmod 600 /etc/jitsi/sidecar/asap.key
chmod 644 /etc/jitsi/sidecar/asap.pem
```

## sidecar env

Update `/etc/jitsi/sidecar/env` depending on the environment.

```conf
ASAP_SIGNING_KEY_FILE=/etc/jitsi/sidecar/asap.key
COMPONENT_TYPE='SIP-JIBRI'
ENABLE_STOP_INSTANCE=true
WS_SERVER_URL='wss://jitsi.mydomain.corp'
INSTANCE_KEY=172.17.17.204
NODE_OPTIONS="--use-openssl-ca"
```

`NODE_OPTIONS` is needed if JMS has a self-signed certificate. If there is a
trusted certificate for JMS, no need to add this line.

Copy JMS' self-signed certificate into `/usr/local/share/ca-certificates/` and
run `update-ca-certificates` command.

## sip virtualhost

Create `sip` virtualhost for `prosody`:

/etc/prosody/conf.avail/sip.jitsi.mydomain.corp.cfg.lua

```lua
plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

VirtualHost "sip.jitsi.mydomain.corp"
    modules_enabled = {
        "limits_exception";
    }
    authentication = "internal_hashed"
```

```bash
ln -s /etc/prosody/conf.avail/sip.jitsi.mydomain.corp.cfg.lua /etc/prosody/conf.d/
```

## prosody accounts

Create `jibri` and `sip` accounts for `prosody` on JMS.

Check the account folders first. If they are already exist, `register` command
will overwrite their current passwords and these may affect the instances which
are already available.

```bash
ls /var/lib/prosody/*/accounts/

JITSI_FQDN="jitsi.mydomain.corp"
JIBRI_PASSWD="myjibripassword"
SIP_PASSWD="mysippassword"

prosodyctl register jibri auth.$JITSI_FQDN $JIBRI_PASSWD
prosodyctl register sip sip.$JITSI_FQDN $SIP_PASSWD
```

## jicofo

Add `SipBrewery` into `/etc/jitsi/jicofo/jicofo.conf`

```bash
JITSI_FQDN="jitsi.mydomain.corp"

hocon -f /etc/jitsi/jicofo/jicofo.conf \
    set jicofo.jibri-sip.brewery-jid "\"SipBrewery@internal.auth.$JITSI_FQDN\""

systemctl restart jicofo.service
```

As a result there should be an entry like the following in `jicofo.conf`:

```conf
jibri-sip: {
  brewery-jid: "SipBrewery@internal.auth.jitsi.mydomain.corp"
}
```

## jibri.conf

Update `jibri.conf`. Critical parts:

- `nickname` should be unique for each instance
- The password of `control-login` must be the same with `$JIBRI_PASSWD` of
  `prosody`
- The password of `call-login` must be the same with `$SIP_PASSWD` of `prosody`

```conf
    xmpp {
      environments = [{
        name = "my-environment"
        xmpp-server-hosts = ["jitsi.mydomain.corp"]
        xmpp-domain = "jitsi.mydomain.corp"

        control-muc {
          domain = "internal.auth.jitsi.mydomain.corp"
          room-name = "SipBreweryDummy"
          nickname = "08829a66-ce83-4af0-80b4-98f771346951"
        }

        sip-control-muc {
          domain = "internal.auth.jitsi.mydomain.corp"
          room-name = "SipBrewery"
          nickname = "08829a66-ce83-4af0-80b4-98f771346951"
        }

        control-login {
          domain = "auth.jitsi.mydomain.corp"
          username = "jibri"
          password = "myjibripassword"
        }

        call-login {
          domain = "sip.jitsi.mydomain.corp"
          username = "sip"
          password = "mysippassword"
        }

        strip-from-room-domain = "conference."
        usage-timeout = 0
        trust-all-xmpp-certs = true
      }]
    }
```

Restart services.

```bash
systemctl stop jibri-xorg
systemctl start jibri
```

## Checking on Jicofo

At this step, `sip` instance should be detected by `jicofo`:

```bash
curl -s 0:8888/stats | jq .sip_jibri_detector

>>> {
>>>   "count": 1,
>>>   "available": 1
>>> }
```

## Creating SIP session

A token is needed for this setup since the guest is not allowed to join.

`sip-custom-1-start.sh` is from this link:
https://github.com/nordeck/bullseye-lxc-jitsi/blob/main/docs/component-selector-api-examples/sip-custom-1-start.sh

```bash
export JWT="a-valid-token"
export JITSI_HOST="https://jitsi.mydomain.corp"
export JITSI_ROOM="myroom?jwt=$JWT"

bash sip-custom-1-start.sh "cisco"
```
