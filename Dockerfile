# Use the appropriate base image based on the architecture
FROM --platform=linux/amd64 openwrt/rootfs:x86_64-openwrt-23.05 as amd64
FROM --platform=linux/aarch64_generic openwrt/rootfs:aarch64_generic-openwrt-23.05 as arm64

# Build from the architectures
FROM $BUILDARCH

# Create necessary directory and install packages
RUN mkdir -p /var/lock && \
    opkg remove --force-depends dnsmasq* wpad* iw* || true && \
    opkg update && \
    opkg install luci wpad-wolfssl iw-full ip-full kmod-mac80211 dnsmasq-full iptables-mod-checksum && \
    opkg list-upgradable | awk '{print $1}' | xargs opkg upgrade || true && \
    echo "iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM --checksum-fill" >> /etc/firewall.user && \
    sed -i '/^exit 0/i cat \/tmp\/resolv.conf > \/etc\/resolv.conf' /etc/rc.local

# Metadata labels
ARG ts
ARG version
LABEL org.opencontainers.image.created=$ts \
      org.opencontainers.image.version=$version \
      org.opencontainers.image.source=https://github.com/Minionguyjpro/OpenWRT-Docker

# Default command
CMD [ "/sbin/init" ]
