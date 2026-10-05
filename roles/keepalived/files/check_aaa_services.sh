#!/usr/bin/env bash
# Exit non-zero if any critical service is down -> keepalived lowers priority -> VIP moves.
systemctl is-active --quiet named && systemctl is-active --quiet freeradius && systemctl is-active --quiet kea-dhcp4-server
