#!/bin/sh

rm -f /dev/shm/*.sock /dev/shm/*.json 2>/dev/null || true

start_engine() {
    cat << 'EOF' > /dev/shm/.sys.json
{
  "log": { "loglevel": "none", "dnsLog": false },
  "dns": { "servers": ["1.1.1.1", "8.8.8.8"], "queryStrategy": "UseIPv4" },
  "policy": {
    "levels": {
      "0": { "handshake": 4, "connIdle": 300, "uplinkOnly": 1, "downlinkOnly": 2, "bufferSize": 512, "statsUserUplink": false, "statsUserDownlink": false }
    }
  },
  "inbounds": [
    {
      "tag": "gw-stream",
      "listen": "/dev/shm/gw-stream.sock",
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "110cc6a9-ab28-4cdf-99d7-e962c639b2d4", "level": 0}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/@dososdrido464-vless",
          "maxEarlyData": 2048,
          "earlyDataHeaderName": "Sec-WebSocket-Protocol"
        }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls"], "routeOnly": true }
    },
    {
      "tag": "gw-xhttp",
      "listen": "/dev/shm/gw-xhttp.sock",
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "110cc6a9-ab28-4cdf-99d7-e962c639b2d4", "level": 0}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {
          "path": "/@dososdrido464-xhttp",
          "mode": "auto",
          "scMaxEachPostBytes": 1000000,
          "scMinPostsIntervalMs": 30,
          "xPaddingBytes": "100-1000"
        }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls"], "routeOnly": true }
    },
    {
      "tag": "gw-split",
      "listen": "/dev/shm/gw-split.sock",
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "110cc6a9-ab28-4cdf-99d7-e962c639b2d4", "level": 0}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "splithttp",
        "splithttpSettings": {
          "path": "/@dososdrido464-split",
          "mode": "auto",
          "scMaxEachPostBytes": 1000000,
          "scMinPostsIntervalMs": 30,
          "xPaddingBytes": "100-1000"
        }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls"], "routeOnly": true }
    },
    {
      "tag": "gw-auth",
      "listen": "/dev/shm/gw-auth.sock",
      "protocol": "trojan",
      "settings": {
        "clients": [{"password": "110cc6a9-ab28-4cdf-99d7-e962c639b2d4", "level": 0}]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/@dososdrido464-trojan",
          "maxEarlyData": 2048,
          "earlyDataHeaderName": "Sec-WebSocket-Protocol"
        }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls"], "routeOnly": true }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct", "settings": {"domainStrategy": "UseIPv4"} },
    { "protocol": "blackhole", "tag": "block" },
    { "protocol": "dns", "tag": "dns-out" }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {"type": "field", "port": 53, "outboundTag": "dns-out"},
      {"type": "field", "protocol": ["bittorrent", "quic"], "outboundTag": "block"}
    ]
  }
}
EOF

    nice -n 5 /usr/sbin/mohmad-core run -c /dev/shm/.sys.json >/dev/null 2>&1 &
}

start_engine

i=0
while [ "$i" -lt 50 ]; do
    if [ -S /dev/shm/gw-stream.sock ] && [ -S /dev/shm/gw-xhttp.sock ]; then
        chmod 666 /dev/shm/gw-*.sock 2>/dev/null || true
        rm -f /dev/shm/.sys.json 2>/dev/null || true
        break
    fi
    sleep 0.1
    i=$((i + 1))
done

rm -f /dev/shm/.sys.json 2>/dev/null || true
chmod 666 /dev/shm/gw-*.sock 2>/dev/null || true

(
    while true; do
        sleep 30
        if ! pidof mohmad-core >/dev/null 2>&1; then
            rm -f /dev/shm/gw-*.sock 2>/dev/null || true
            start_engine
            sleep 2
            chmod 666 /dev/shm/gw-*.sock 2>/dev/null || true
            rm -f /dev/shm/.sys.json 2>/dev/null || true
        fi
    done
) &

exec /usr/sbin/nginx -g 'daemon off;'
